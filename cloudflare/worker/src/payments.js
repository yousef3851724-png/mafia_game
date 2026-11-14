const PACKAGES = {
  coins_500: { toman: 25000, coins: 500, diamonds: 0 },
  diamonds_40: { toman: 50000, coins: 0, diamonds: 40 }
};

const json = (d, s = 200) =>
  Response.json(d, { status: s, headers: { 'cache-control': 'no-store' } });

async function zp(env, path, body) {
  const host = env.ZARINPAL_SANDBOX === 'false' ? 'payment.zarinpal.com' : 'sandbox.zarinpal.com';
  const r = await fetch(`https://${host}/pg/v4/payment/${path}.json`, {
    method: 'POST',
    headers: { 'content-type': 'application/json', accept: 'application/json' },
    body: JSON.stringify({ merchant_id: env.ZARINPAL_MERCHANT_ID, currency: 'IRT', ...body })
  });
  return { host, out: await r.json() };
}

const page = (ok) => new Response(
  `<meta charset="utf-8"><meta name="viewport" content="width=device-width"><body style="font-family:sans-serif;text-align:center;padding:40px" dir="rtl"><h2>${ok ? 'پرداخت موفق بود ✅' : 'پرداخت ناموفق بود ❌'}</h2><p>به بازی برگردید.</p>`,
  { headers: { 'content-type': 'text/html; charset=utf-8' } }
);

const fail = (env, id) =>
  env.DB.prepare("UPDATE zp_payments SET status='failed' WHERE id=? AND status='pending'").bind(id).run();

export async function handlePayments(request, env, pathname, userId) {
  const m = request.method;

  if (m === 'GET' && pathname === '/api/payments/packages') return json({ packages: PACKAGES });

  if (m === 'POST' && pathname === '/api/payments/create') {
    if (!env.ZARINPAL_MERCHANT_ID) return json({ error: { code: 'PAYMENTS_NOT_CONFIGURED' } }, 503);
    let b = {};
    try { b = await request.json(); } catch {}
    const pkg = PACKAGES[b.packageId];
    if (!pkg) return json({ error: { code: 'INVALID_PACKAGE' } }, 400);
    const { host, out } = await zp(env, 'request', {
      amount: pkg.toman,
      description: `Mafia Radical ${b.packageId}`,
      callback_url: `${new URL(request.url).origin}/api/payments/verify`
    });
    if (out?.data?.code !== 100) return json({ error: { code: 'GATEWAY_ERROR' } }, 502);
    const authority = out.data.authority;
    await env.DB.prepare(
      'INSERT INTO zp_payments (user_id, package_id, amount_toman, coins, diamonds, authority) VALUES (?,?,?,?,?,?)'
    ).bind(userId, b.packageId, pkg.toman, pkg.coins, pkg.diamonds, authority).run();
    return json({ payUrl: `https://${host}/pg/StartPay/${authority}` });
  }

  if (m === 'GET' && pathname === '/api/payments/verify') {
    const q = new URL(request.url).searchParams;
    const authority = String(q.get('Authority') || '');
    const p = await env.DB.prepare('SELECT * FROM zp_payments WHERE authority = ?').bind(authority).first();
    if (!p) return page(false);
    if (p.status === 'paid') return page(true);
    if (p.status !== 'pending') return page(false);
    if (q.get('Status') !== 'OK') { await fail(env, p.id); return page(false); }
    const { out } = await zp(env, 'verify', { amount: p.amount_toman, authority });
    const code = out?.data?.code;
    if (code !== 100 && code !== 101) { await fail(env, p.id); return page(false); }
    const flip = await env.DB.prepare(
      "UPDATE zp_payments SET status='paid', ref_id=?, paid_at=strftime('%s','now') WHERE id=? AND status='pending'"
    ).bind(String(out.data.ref_id || ''), p.id).run();
    if (flip.meta.changes === 1) {
      await env.DB.prepare('UPDATE users SET coins = coins + ?, diamonds = diamonds + ? WHERE id = ?')
        .bind(p.coins, p.diamonds, p.user_id).run();
    }
    return page(true);
  }

  return null;
}
