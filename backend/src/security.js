'use strict';

const jwt = require('jsonwebtoken');

function signAccessToken(player, config) {
  return jwt.sign(
    { sub: player.id, username: player.username },
    config.JWT_SECRET,
    { expiresIn: config.JWT_EXPIRES_IN, issuer: 'mafia-radical-api', audience: 'mafia-radical-app' }
  );
}

function verifyAccessToken(token, config) {
  const payload = jwt.verify(token, config.JWT_SECRET, {
    issuer: 'mafia-radical-api',
    audience: 'mafia-radical-app'
  });
  if (!payload || typeof payload.sub !== 'string') throw new Error('Invalid access token');
  return payload;
}

function requireAuth(config, pool) {
  return async (req, res, next) => {
    const header = req.get('authorization') || '';
    const match = /^Bearer\s+(.+)$/i.exec(header);
    if (!match) return res.status(401).json({ error: { code: 'UNAUTHENTICATED', message: 'ورود به حساب لازم است.' } });
    try {
      req.auth = verifyAccessToken(match[1], config);
    } catch (_) {
      return res.status(401).json({ error: { code: 'INVALID_TOKEN', message: 'نشست معتبر نیست؛ دوباره وارد شوید.' } });
    }
    try {
      if (pool) {
        const ban = await pool.query(
          'SELECT ends_at FROM player_bans WHERE player_id = $1 AND revoked_at IS NULL AND starts_at <= NOW() AND ends_at > NOW() ORDER BY ends_at DESC LIMIT 1',
          [req.auth.sub]
        );
        if (ban.rowCount) return res.status(403).json({ error: { code: 'ACCOUNT_BANNED', message: 'حساب کاربری به‌طور موقت مسدود است.', until: ban.rows[0].ends_at } });
      }
      return next();
    } catch (error) { return next(error); }
  };
}

module.exports = { signAccessToken, verifyAccessToken, requireAuth };
