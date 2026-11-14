import { handlePayments } from './payments.js';
import { hashPassword, safeEqual, signJwt, verifyJwt } from './auth.js';

const json = (data, status = 200) =>
  Response.json(data, { status, headers: { 'cache-control': 'no-store' } });
const err = (code, message, status) => json({ error: { code, message } }, status);
const validUser = (u) => typeof u === 'string' && /^[\w\u0600-\u06FF]{3,20}$/.test(u);
const validPass = (p) => typeof p === 'string' && p.length >= 6 && p.length <= 100;

async function body(request) {
  try { return await request.json(); } catch { return {}; }
}

export default {
  async fetch(request, env) {
    const { pathname } = new URL(request.url);
    const m = request.method;

    if (m === 'GET' && pathname === '/health') {
      return json({
        service: 'Mafia Radical API Worker',
        status: 'ok',
        database: env.DB ? 'configured' : 'not_configured',
        websocket: 'not_configured',
        phase: 'auth'
      });
    }

    if (!env.DB || !env.JWT_SECRET) return err('NOT_CONFIGURED', 'DB or JWT_SECRET missing', 503);

    if (pathname.startsWith('/api/payments/')) {
      let userId = null;
      if (pathname === '/api/payments/create') {
        const token = (request.headers.get('authorization') || '').replace(/^Bearer /, '');
        const pl = await verifyJwt(token, env.JWT_SECRET);
        if (!pl) return err('UNAUTHORIZED', 'توکن نامعتبر', 401);
        userId = pl.sub;
      }
      const r = await handlePayments(request, env, pathname, userId);
      if (r) return r;
    }

    if (m === 'POST' && pathname === '/api/auth/register') {
      const { username, password } = await body(request);
      if (!validUser(username)) return err('BAD_USERNAME', 'نام کاربری ۳ تا ۲۰ کاراکتر', 400);
      if (!validPass(password)) return err('BAD_PASSWORD', 'رمز حداقل ۶ کاراکتر', 400);
      const { hash, salt } = await hashPassword(password);
      const id = crypto.randomUUID();
      try {
        await env.DB.prepare('INSERT INTO users (id, username, password_hash, salt) VALUES (?, ?, ?, ?)')
          .bind(id, username, hash, salt).run();
      } catch (e) {
        if (String(e).includes('UNIQUE')) return err('USERNAME_TAKEN', 'این نام قبلاً گرفته شده', 409);
        throw e;
      }
      return json({ token: await signJwt({ sub: id, username }, env.JWT_SECRET), user: { id, username, coins: 100, diamonds: 0 } }, 201);
    }

    if (m === 'POST' && pathname === '/api/auth/login') {
      const { username, password } = await body(request);
      if (!validUser(username) || !validPass(password)) return err('BAD_CREDENTIALS', 'نام کاربری یا رمز اشتباه', 401);
      const u = await env.DB.prepare('SELECT * FROM users WHERE username = ?').bind(username).first();
      if (!u) return err('BAD_CREDENTIALS', 'نام کاربری یا رمز اشتباه', 401);
      const { hash } = await hashPassword(password, u.salt);
      if (!safeEqual(hash, u.password_hash)) return err('BAD_CREDENTIALS', 'نام کاربری یا رمز اشتباه', 401);
      return json({ token: await signJwt({ sub: u.id, username }, env.JWT_SECRET), user: { id: u.id, username, coins: u.coins, diamonds: u.diamonds } });
    }

    if (m === 'GET' && pathname === '/api/me') {
      const token = (request.headers.get('authorization') || '').replace(/^Bearer /, '');
      const p = await verifyJwt(token, env.JWT_SECRET);
      if (!p) return err('UNAUTHORIZED', 'توکن نامعتبر', 401);
      const u = await env.DB.prepare('SELECT id, username, coins, diamonds FROM users WHERE id = ?').bind(p.sub).first();
      return u ? json({ user: u }) : err('NOT_FOUND', 'کاربر پیدا نشد', 404);
    }

    return err('NOT_FOUND', 'route not found', 404);
  }
};
