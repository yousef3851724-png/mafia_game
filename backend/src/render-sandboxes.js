'use strict';

const express = require('express');
const rateLimit = require('express-rate-limit');
const { Render } = require('@renderinc/sdk');

const DIAGNOSTIC_COMMAND = 'node --version && npm --version && uname -s';
const MAX_OUTPUT_CHARS = 4000;

function createRenderSandboxesRouter({ pool, auth, RenderClient = Render }) {
  const router = express.Router();

  router.use(auth);
  router.use(rateLimit({
    windowMs: 10 * 60_000,
    limit: 2,
    standardHeaders: 'draft-8',
    legacyHeaders: false
  }));

  router.post('/diagnostics', async (req, res) => {
    let sandboxId;
    let sandboxes;

    try {
      // Sandbox operations are restricted to the original game creator.
      const actor = await pool.query(
        `SELECT 1
         FROM moderation_role_assignments
         WHERE player_id = $1
           AND role = 'creator'
           AND revoked_at IS NULL
           AND (expires_at IS NULL OR expires_at > NOW())
         LIMIT 1`,
        [req.auth.sub]
      );

      if (!actor.rowCount) {
        return res.status(403).json({
          error: { code: 'CREATOR_ONLY', message: 'فقط سازنده اصلی بازی اجازه اجرای Sandbox را دارد.' }
        });
      }

      if (!process.env.RENDER_API_KEY || !process.env.RENDER_WORKSPACE_ID) {
        return res.status(503).json({
          error: { code: 'SANDBOX_NOT_CONFIGURED', message: 'اتصال Render Sandbox روی سرور تنظیم نشده است.' }
        });
      }

      // No game data, database credentials, player tokens, or other secrets
      // are passed into this isolated environment.
      sandboxes = new RenderClient().sandboxes;
      const sandbox = await sandboxes.create({
        timeoutSeconds: 300,
        idleTimeoutSeconds: 300,
        networkPolicy: { type: 'deny-all' },
        wait: true
      });

      sandboxId = sandbox.id;

      const events = await sandboxes.exec(sandboxId, DIAGNOSTIC_COMMAND);
      let output = '';
      let exitCode = null;

      for await (const event of events) {
        if (event.type === 'output' && output.length < MAX_OUTPUT_CHARS) {
          output += event.data.slice(0, MAX_OUTPUT_CHARS - output.length);
        } else if (event.type === 'exit') {
          exitCode = event.exit_code;
        }
      }

      return res.status(exitCode === 0 ? 200 : 502).json({
        sandbox: { status: 'completed' },
        command: 'runtime-diagnostics',
        exitCode,
        output
      });
    } catch (error) {
      sandboxId ||= error?.sandboxId;
      // Do not log API credentials, command payloads, or raw provider responses.
      console.error('Render sandbox operation failed:', error?.name || 'unknown_error');
      return res.status(502).json({
        error: { code: 'SANDBOX_OPERATION_FAILED', message: 'اجرای آزمایشی Render Sandbox ناموفق بود.' }
      });
    } finally {
      if (sandboxId && sandboxes) {
        try {
          await sandboxes.terminate(sandboxId);
        } catch (error) {
          console.error('Render sandbox cleanup failed:', error?.name || 'unknown_error');
        }
      }
    }
  });

  return router;
}

module.exports = { createRenderSandboxesRouter };
