'use strict';
const express = require('express');
const { z } = require('zod');
const { withTransaction } = require('./db');

// Prices live on the server only. The app sends just a package id.
const PACKAGES = {
  coins_100: { toman: 20000, coins: 100 },
  coins_500: { toman: 90000, coins: 500 },
  coins_1000: { toman: 160000, coins: 1000 }
};

function createPaymentsRouter({ pool, auth, config }) {
  const router = express.Router();
  const host = config.ZARINPAL_SANDBOX ? 'sandbox.zarinpal.com' : 'payment.zarinpal.com';
  const call = async (path, body) => {
    const r = await fetch(`https://${host}/pg/v4/payment/${path}.json`, {
      method: 'POST',
      headers: { 'content-type': 'application/json', accept: 'application/json' },
      body: JSON.stringify({ merchant_id: config.ZARINPAL_MERCHANT_ID, currency: 'IRT', ...body })
    });
    return r.json();
  };

  router.get('/packages', (_req, res) => res.json({ packages: PACKAGES }));

  router.post('/create', auth, async (req, res, next) => {
    try {
      const { packageId } = z.object({ packageId: z.string() }).parse(req.body);
      const pkg = PACKAGES[packageId];
      if (!pkg) return res.status(400).json({ error: 'invalid_package' });
      if (!config.ZARINPAL_MERCHANT_ID) return res.status(503).json({ error: 'payments_not_configured' });
      const out = await call('request', {
        amount: pkg.toman,
        description: `Mafia Radical ${packageId}`,
        callback_url: `${config.PUBLIC_BASE_URL}/api/v1/payments/verify`
      });
      if (out?.data?.code !== 100) return res.status(502).json({ error: 'gateway_error' });
      const authority = out.data.authority;
      await pool.query(
        'INSERT INTO payments(player_id, package_id, amount_toman, coins, authority) VALUES ($1,$2,$3,$4,$5)',
        [String(req.user.id), packageId, pkg.toman, pkg.coins, authority]
      );
      res.json({ payUrl: `https://${host}/pg/StartPay/${authority}` });
    } catch (e) { next(e); }
  });

  // Gateway redirects the user's browser here. No JWT; trust only server-side verify.
  router.get('/verify', async (req, res, next) => {
    try {
      const authority = String(req.query.Authority || '');
      const ok = req.query.Status === 'OK';
      let paid = false;
      await withTransaction(pool, async client => {
        const q = await client.query('SELECT * FROM payments WHERE authority = $1 FOR UPDATE', [authority]);
        const p = q.rows[0];
        if (!p) return;
        if (p.status === 'paid') { paid = true; return; }
        if (!ok) { await client.query("UPDATE payments SET status='failed' WHERE id=$1", [p.id]); return; }
        const out = await call('verify', { amount: p.amount_toman, authority });
        const code = out?.data?.code;
        if (code === 100 || code === 101) {
          await client.query(
            "UPDATE payments SET status='paid', ref_id=$2, paid_at=NOW() WHERE id=$1 AND status='pending'",
            [p.id, String(out.data.ref_id || '')]
          );
          await client.query('UPDATE players SET coins = coins + $2 WHERE id::text = $1', [p.player_id, p.coins]);
          paid = true;
        } else {
          await client.query("UPDATE payments SET status='failed' WHERE id=$1", [p.id]);
        }
      });
      res.type('html').send(`<meta charset="utf-8"><meta name="viewport" content="width=device-width"><body style="font-family:sans-serif;text-align:center;padding:40px" dir="rtl"><h2>${paid ? 'پرداخت موفق بود ✅' : 'پرداخت ناموفق بود ❌'}</h2><p>به بازی برگردید.</p>`);
    } catch (e) { next(e); }
  });

  return router;
}
module.exports = { createPaymentsRouter };
