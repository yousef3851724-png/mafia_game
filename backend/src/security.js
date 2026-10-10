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

function requireAuth(config) {
  return (req, res, next) => {
    const header = req.get('authorization') || '';
    const match = /^Bearer\s+(.+)$/i.exec(header);
    if (!match) return res.status(401).json({ error: { code: 'UNAUTHENTICATED', message: 'ورود به حساب لازم است.' } });
    try {
      req.auth = verifyAccessToken(match[1], config);
      return next();
    } catch (_) {
      return res.status(401).json({ error: { code: 'INVALID_TOKEN', message: 'نشست معتبر نیست؛ دوباره وارد شوید.' } });
    }
  };
}

module.exports = { signAccessToken, verifyAccessToken, requireAuth };
