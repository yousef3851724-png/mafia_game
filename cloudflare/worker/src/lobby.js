import { DurableObject } from 'cloudflare:workers';

const CODE_RE = /^[A-Z0-9]{4,8}$/;
const AI_MODEL = '@cf/zai-org/glm-4.7-flash';
const send = (ws, data) => { try { ws.send(JSON.stringify(data)); } catch {} };

async function snapshot(env, roomId) {
  const { results } = await env.DB.prepare(
    `SELECT u.id, u.username, rp.seat, rp.is_ready
     FROM zp_room_players rp JOIN users u ON u.id = rp.player_id
     WHERE rp.room_id = ? ORDER BY rp.seat`
  ).bind(roomId).all();
  return results.map((r) => ({ id: r.id, username: r.username, seat: r.seat, ready: r.is_ready === 1 }));
}

async function moderateMessage(env, text) {
  if (!env.AI) return { available: false, flagged: false };
  const prompt = [
    'You are a concise safety moderator for a Persian-language social Mafia game.',
    'Classify only clear harassment, threats, targeted insults, hate, sexual harassment, or spam.',
    'Do not flag ordinary game banter, strategic accusations, role-play, or disagreement.',
    'Return ONLY JSON: {"flagged":boolean,"category":"none|harassment|threat|hate|sexual|spam","severity":"low|medium|high"}.',
    'Message: ' + JSON.stringify(text)
  ].join('\n');
  try {
    const result = await env.AI.run(AI_MODEL, {
      messages: [
        { role: 'system', content: 'Return valid JSON only. Be conservative; do not flag normal gameplay.' },
        { role: 'user', content: prompt }
      ],
      max_tokens: 80,
      temperature: 0
    });
    const raw = result?.response ?? result?.result?.response ?? '';
    const match = String(raw).match(/\{[\s\S]*\}/);
    if (!match) return { available: false, flagged: false };
    const parsed = JSON.parse(match[0]);
    const category = ['none', 'harassment', 'threat', 'hate', 'sexual', 'spam'].includes(parsed.category)
      ? parsed.category : 'none';
    const severity = ['low', 'medium', 'high'].includes(parsed.severity) ? parsed.severity : 'low';
    return { available: true, flagged: parsed.flagged === true && category !== 'none', category, severity };
  } catch {
    // Workers AI free quota exhaustion or temporary model errors must never break room chat.
    return { available: false, flagged: false };
  }
}

export async function handleLobby(request, env, pl, roomCodeRaw) {
  const code = String(roomCodeRaw || '').trim().toUpperCase();
  if (!CODE_RE.test(code)) return new Response('bad room', { status: 400 });
  const room = await env.DB.prepare('SELECT id, status FROM zp_rooms WHERE code = ?').bind(code).first();
  if (!room || room.status === 'closed') return new Response('room not found', { status: 404 });
  const member = await env.DB.prepare(
    'SELECT 1 AS x FROM zp_room_players WHERE room_id = ? AND player_id = ?'
  ).bind(room.id, pl.sub).first();
  if (!member) return new Response('not in room', { status: 403 });
  const u = new URL('https://lobby/connect');
  u.searchParams.set('roomId', room.id);
  u.searchParams.set('playerId', pl.sub);
  u.searchParams.set('username', pl.username || '');
  const stub = env.LOBBY.get(env.LOBBY.idFromName(room.id));
  return stub.fetch(new Request(u.toString(), request));
}

export class LobbyRoom extends DurableObject {
  async fetch(request) {
    const q = new URL(request.url).searchParams;
    const meta = { roomId: q.get('roomId'), playerId: q.get('playerId'), username: q.get('username') };
    const [client, server] = Object.values(new WebSocketPair());
    this.ctx.acceptWebSocket(server);
    server.serializeAttachment(meta);
    send(server, { type: 'players', players: await snapshot(this.env, meta.roomId) });
    return new Response(null, { status: 101, webSocket: client });
  }

  broadcast(data) {
    for (const ws of this.ctx.getWebSockets()) send(ws, data);
  }

  async webSocketMessage(ws, raw) {
    const a = ws.deserializeAttachment() || {};
    let msg;
    try { msg = JSON.parse(typeof raw === 'string' ? raw : new TextDecoder().decode(raw)); }
    catch { return send(ws, { type: 'error', code: 'INVALID_JSON' }); }
    if (!msg || typeof msg.type !== 'string') return send(ws, { type: 'error', code: 'INVALID_MESSAGE' });
    try {
      if (msg.type === 'ready') {
        if (typeof msg.ready !== 'boolean') return send(ws, { type: 'error', code: 'VALIDATION_ERROR' });
        const up = await this.env.DB.prepare(
          "UPDATE zp_room_players SET is_ready = ? WHERE room_id = ? AND player_id = ? AND (SELECT status FROM zp_rooms WHERE id = ?) = 'waiting'"
        ).bind(msg.ready ? 1 : 0, a.roomId, a.playerId, a.roomId).run();
        if (up.meta.changes !== 1) return send(ws, { type: 'error', code: 'ROOM_NOT_WAITING' });
        this.broadcast({ type: 'players', players: await snapshot(this.env, a.roomId) });
      } else if (msg.type === 'chat') {
        const text = typeof msg.text === 'string' ? msg.text.trim() : '';
        if (!text || text.length > 300) return send(ws, { type: 'error', code: 'INVALID_CHAT' });
        const moderation = await moderateMessage(this.env, text);
        if (moderation.flagged) {
          await this.env.DB.prepare(
            `INSERT INTO moderation_events
              (id, room_id, player_id, username, category, severity, message_excerpt, model)
             VALUES (?, ?, ?, ?, ?, ?, ?, ?)`
          ).bind(
            crypto.randomUUID(), a.roomId, a.playerId, String(a.username || '').slice(0, 32),
            moderation.category, moderation.severity, text.slice(0, 300), AI_MODEL
          ).run();
          send(ws, {
            type: 'chat_moderated',
            code: 'MESSAGE_HELD_FOR_REVIEW',
            message: 'پیام به دلیل احتمال تخلف برای بررسی مدیر ثبت شد.'
          });
          this.broadcast({
            type: 'moderation_notice',
            playerId: a.playerId,
            category: moderation.category,
            severity: moderation.severity
          });
          return;
        }
        this.broadcast({
          type: 'chat',
          playerId: a.playerId,
          username: a.username,
          text,
          sentAt: new Date().toISOString(),
          moderation: moderation.available ? 'checked' : 'unavailable'
        });
      } else {
        send(ws, { type: 'error', code: 'UNSUPPORTED_OPERATION', message: 'این عملیات هنوز در پروتکل آنلاین پیاده‌سازی نشده است.' });
      }
    } catch {
      send(ws, { type: 'error', code: 'SERVER_ERROR' });
    }
  }

  webSocketClose(ws) {
    try { ws.close(1000); } catch {}
  }
}
