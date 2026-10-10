'use strict';

const crypto = require('node:crypto');
const express = require('express');
const { z } = require('zod');

const grantSchema = z.object({
  role: z.enum(['admin', 'supervisor']),
  permissions: z.array(z.string().regex(/^[a-z][a-z0-9_.:-]{1,79}$/)).max(40).default([]),
  expiresAt: z.string().datetime().optional()
});
const reasonSchema = z.string().trim().min(3).max(2000);

function createModerationRouter({ pool, auth }) {
  const router = express.Router();
  router.use(auth);

  async function getActor(req) {
    const result = await pool.query(
      `SELECT a.id, a.role, a.permissions
       FROM moderation_role_assignments a
       WHERE a.player_id = $1 AND a.revoked_at IS NULL
         AND (a.expires_at IS NULL OR a.expires_at > NOW())
         AND NOT EXISTS (
           SELECT 1 FROM moderation_role_suspensions s
           WHERE s.assignment_id = a.id AND s.restored_at IS NULL AND s.ends_at > NOW()
         )
       ORDER BY CASE a.role WHEN 'creator' THEN 0 WHEN 'admin' THEN 1 ELSE 2 END
       LIMIT 1`,
      [req.auth.sub]
    );
    return result.rows[0] || null;
  }

  async function requirePermission(req, res, permission) {
    const actor = await getActor(req);
    if (!actor) {
      res.status(403).json({ error: { code: 'MODERATION_ACCESS_DENIED', message: 'دسترسی مدیریتی فعال ندارید.' } });
      return null;
    }
    if (actor.role !== 'creator' && !actor.permissions.includes(permission)) {
      res.status(403).json({ error: { code: 'PERMISSION_DENIED', message: 'مجوز لازم برای این عملیات را ندارید.' } });
      return null;
    }
    return actor;
  }

  async function audit(client, actor, eventType, targetPlayerId, reason, evidence = {}) {
    await client.query(
      `INSERT INTO moderation_audit_log
       (actor_player_id, actor_role, event_type, target_player_id, reason, evidence)
       VALUES ($1,$2,$3,$4,$5,$6::jsonb)`,
      [actor.player_id, actor.role, eventType, targetPlayerId || null, reason || null, JSON.stringify(evidence)]
    );
  }

  router.get('/roles', async (req, res, next) => {
    try {
      const actor = await requirePermission(req, res, 'roles.read');
      if (!actor) return;
      const result = await pool.query(
        `SELECT a.id, a.player_id, p.username, a.role, a.permissions, a.granted_at, a.expires_at,
                a.revoked_at, EXISTS (
                  SELECT 1 FROM moderation_role_suspensions s
                  WHERE s.assignment_id = a.id AND s.restored_at IS NULL AND s.ends_at > NOW()
                ) AS suspended
         FROM moderation_role_assignments a JOIN players p ON p.id = a.player_id
         ORDER BY a.granted_at DESC LIMIT 500`
      );
      res.json({ roles: result.rows });
    } catch (error) { next(error); }
  });

  router.post('/roles', async (req, res, next) => {
    try {
      const actor = await requirePermission(req, res, 'roles.grant');
      if (!actor) return;
      if (actor.role !== 'creator') return res.status(403).json({ error: { code: 'CREATOR_ONLY', message: 'فقط سازنده اصلی می‌تواند نقش اعطا کند.' } });
      const input = z.object({ playerId: z.string().uuid(), ...grantSchema.shape, reason: reasonSchema }).safeParse(req.body);
      if (!input.success) return res.status(400).json({ error: { code: 'VALIDATION_ERROR', message: 'اطلاعات نقش معتبر نیست.' } });
      const target = await pool.query('SELECT id FROM players WHERE id = $1', [input.data.playerId]);
      if (!target.rowCount) return res.status(404).json({ error: { code: 'PLAYER_NOT_FOUND', message: 'کاربر پیدا نشد.' } });
      const expiresAt = input.data.expiresAt ? new Date(input.data.expiresAt) : null;
      if (expiresAt && expiresAt <= new Date()) return res.status(400).json({ error: { code: 'INVALID_EXPIRY', message: 'زمان انقضا باید در آینده باشد.' } });
      const result = await pool.connect();
      try {
        await result.query('BEGIN');
        const inserted = await result.query(
          `INSERT INTO moderation_role_assignments(player_id, role, granted_by, permissions, expires_at)
           VALUES ($1,$2,$3,$4::jsonb,$5) RETURNING id, player_id, role, permissions, granted_at, expires_at`,
          [input.data.playerId, input.data.role, req.auth.sub, JSON.stringify(input.data.permissions), expiresAt]
        );
        await audit(result, { player_id: req.auth.sub, role: actor.role }, 'role_granted', input.data.playerId, input.data.reason,
          { assignmentId: inserted.rows[0].id, role: input.data.role, permissions: input.data.permissions });
        await result.query('COMMIT');
        return res.status(201).json({ assignment: inserted.rows[0] });
      } catch (error) {
        await result.query('ROLLBACK');
        throw error;
      } finally { result.release(); }
    } catch (error) { next(error); }
  });

  router.post('/roles/:assignmentId/revoke', async (req, res, next) => {
    try {
      const actor = await requirePermission(req, res, 'roles.revoke');
      if (!actor) return;
      if (actor.role !== 'creator') return res.status(403).json({ error: { code: 'CREATOR_ONLY', message: 'فقط سازنده اصلی می‌تواند دسترسی نقش را لغو کند.' } });
      const id = z.coerce.number().int().positive().safeParse(req.params.assignmentId);
      const body = z.object({ reason: reasonSchema }).safeParse(req.body);
      if (!id.success || !body.success) return res.status(400).json({ error: { code: 'VALIDATION_ERROR', message: 'شناسه یا دلیل معتبر نیست.' } });
      const client = await pool.connect();
      try {
        await client.query('BEGIN');
        const updated = await client.query(
          `UPDATE moderation_role_assignments SET revoked_at = NOW(), revoked_by = $2, revoke_reason = $3
           WHERE id = $1 AND revoked_at IS NULL AND role <> 'creator'
           RETURNING id, player_id, role`,
          [id.data, req.auth.sub, body.data.reason]
        );
        if (!updated.rowCount) {
          await client.query('ROLLBACK');
          return res.status(404).json({ error: { code: 'ROLE_ASSIGNMENT_NOT_FOUND', message: 'دسترسی فعال پیدا نشد.' } });
        }
        await audit(client, { player_id: req.auth.sub, role: actor.role }, 'role_revoked', updated.rows[0].player_id, body.data.reason, { assignmentId: id.data });
        await client.query('COMMIT');
        return res.json({ revoked: true, assignmentId: id.data });
      } catch (error) { await client.query('ROLLBACK'); throw error; }
      finally { client.release(); }
    } catch (error) { next(error); }
  });

  router.post('/roles/:assignmentId/suspend', async (req, res, next) => {
    try {
      const actor = await requirePermission(req, res, 'roles.suspend');
      if (!actor) return;
      if (actor.role !== 'creator' && actor.role !== 'admin') return res.status(403).json({ error: { code: 'ADMIN_ONLY', message: 'فقط سازنده یا ادمین مجاز است.' } });
      const id = z.coerce.number().int().positive().safeParse(req.params.assignmentId);
      const body = z.object({ hours: z.number().int().min(1).max(720), reason: reasonSchema }).safeParse(req.body);
      if (!id.success || !body.success) return res.status(400).json({ error: { code: 'VALIDATION_ERROR', message: 'شناسه، مدت یا دلیل معتبر نیست.' } });
      const assignment = await pool.query(
        `SELECT id, player_id, role FROM moderation_role_assignments
         WHERE id = $1 AND revoked_at IS NULL AND role = 'supervisor'`,
        [id.data]
      );
      if (!assignment.rowCount) return res.status(404).json({ error: { code: 'SUPERVISOR_NOT_FOUND', message: 'دسترسی فعال ناظر پیدا نشد.' } });
      const suspendedUntil = new Date(Date.now() + body.data.hours * 3600000);
      const client = await pool.connect();
      try {
        await client.query('BEGIN');
        const inserted = await client.query(
          `INSERT INTO moderation_role_suspensions(assignment_id, suspended_by, reason, ends_at)
           VALUES ($1,$2,$3,$4) RETURNING id, assignment_id, starts_at, ends_at`,
          [id.data, req.auth.sub, body.data.reason, suspendedUntil]
        );
        await audit(client, { player_id: req.auth.sub, role: actor.role }, 'role_suspended', assignment.rows[0].player_id, body.data.reason,
          { assignmentId: id.data, suspensionId: inserted.rows[0].id, hours: body.data.hours });
        await client.query('COMMIT');
        return res.status(201).json({ suspension: inserted.rows[0] });
      } catch (error) { await client.query('ROLLBACK'); throw error; }
      finally { client.release(); }
    } catch (error) { next(error); }
  });

  router.post('/bans', async (req, res, next) => {
    try {
      const actor = await getActor(req);
      if (!actor) return res.status(403).json({ error: { code: 'MODERATION_ACCESS_DENIED', message: 'دسترسی مدیریتی فعال ندارید.' } });
      const body = z.object({ playerId: z.string().uuid(), days: z.number().int(), reason: reasonSchema }).safeParse(req.body);
      if (!body.success) return res.status(400).json({ error: { code: 'VALIDATION_ERROR', message: 'اطلاعات بن معتبر نیست.' } });
      const allowedDays = actor.role === 'creator' ? Array.from({length: 30}, (_, i) => i + 1)
        : actor.role === 'admin' && actor.permissions.includes('moderation.ban') ? Array.from({length: 30}, (_, i) => i + 1)
        : actor.role === 'supervisor' && actor.permissions.includes('moderation.ban') ? [1, 3, 7] : [];
      if (!allowedDays.includes(body.data.days)) return res.status(403).json({ error: { code: 'BAN_DURATION_NOT_ALLOWED', message: 'مدت بن برای نقش شما مجاز نیست.' } });
      const target = await pool.query('SELECT id FROM players WHERE id = $1', [body.data.playerId]);
      if (!target.rowCount) return res.status(404).json({ error: { code: 'PLAYER_NOT_FOUND', message: 'کاربر پیدا نشد.' } });
      const banId = crypto.randomUUID();
      const client = await pool.connect();
      try {
        await client.query('BEGIN');
        const ban = await client.query(
          `INSERT INTO player_bans(id, player_id, issued_by, reason, ends_at)
           VALUES ($1,$2,$3,$4,NOW() + ($5 * INTERVAL '1 day'))
           RETURNING id, player_id, issued_by, reason, starts_at, ends_at`,
          [banId, body.data.playerId, req.auth.sub, body.data.reason, body.data.days]
        );
        await client.query(
          `INSERT INTO moderation_actions(id, target_player_id, actor_player_id, actor_role, action_type, reason, ends_at, metadata)
           VALUES ($1,$2,$3,$4,'ban',$5,$6,$7::jsonb)`,
          [crypto.randomUUID(), body.data.playerId, req.auth.sub, actor.role, body.data.reason, ban.rows[0].ends_at, JSON.stringify({ banId, days: body.data.days })]
        );
        await audit(client, { player_id: req.auth.sub, role: actor.role }, 'player_banned', body.data.playerId, body.data.reason, { banId, days: body.data.days });
        await client.query('COMMIT');
        return res.status(201).json({ ban: ban.rows[0] });
      } catch (error) { await client.query('ROLLBACK'); throw error; }
      finally { client.release(); }
    } catch (error) { next(error); }
  });

  router.get('/audit', async (req, res, next) => {
    try {
      const actor = await requirePermission(req, res, 'audit.read');
      if (!actor) return;
      const limit = Math.min(200, Math.max(1, Number.parseInt(req.query.limit, 10) || 50));
      const result = await pool.query(
        `SELECT id, actor_player_id, actor_role, event_type, target_player_id, room_id, reason, evidence, created_at
         FROM moderation_audit_log ORDER BY id DESC LIMIT $1`, [limit]
      );
      res.json({ events: result.rows });
    } catch (error) { next(error); }
  });

  return router;
}

module.exports = { createModerationRouter };
