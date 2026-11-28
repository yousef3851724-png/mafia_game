import { withPostgres } from './postgres-db.js';
import { bearerToken, verifyBackendAccessToken } from './postgres-auth.js';

const json = (data, status = 200) => Response.json(data, {
  status,
  headers: { 'cache-control': 'no-store' }
});

const failure = (status, code, message) => json({ error: { code, message } }, status);

async function health(env) {
  try {
    await withPostgres(env, (client) => client.query('SELECT 1'));
    return json({
      service: 'Mafia Radical API',
      status: 'ok',
      database: 'ok',
      databaseDriver: 'pg via Cloudflare Hyperdrive',
      websocket: 'not_migrated'
    });
  } catch (error) {
    const configured = error?.code !== 'HYPERDRIVE_NOT_CONFIGURED';
    return json({
      service: 'Mafia Radical API',
      status: 'degraded',
      database: configured ? 'unavailable' : 'not_configured'
    }, 503);
  }
}

export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    if (request.method === 'GET' && url.pathname === '/health') {
      return health(env);
    }

    if (request.method === 'GET' && url.pathname === '/api/v1/me') {
      const token = bearerToken(request);
      if (!token) return failure(401, 'UNAUTHENTICATED', 'ورود به حساب لازم است.');

      const identity = await verifyBackendAccessToken(token, env.JWT_SECRET);
      if (!identity) return failure(401, 'INVALID_TOKEN', 'نشست معتبر نیست؛ دوباره وارد شوید.');

      try {
        const result = await withPostgres(env, (client) => client.query(
          `SELECT id, username, referral_code, level, xp, coins, diamonds,
                  games_played, games_won, avatar_id, frame_id
           FROM players WHERE id = $1`,
          [identity.sub]
        ));
        const row = result.rows[0];
        if (!row) return failure(401, 'ACCOUNT_NOT_FOUND', 'حساب کاربری پیدا نشد.');

        return json({
          player: {
            id: row.id,
            username: row.username,
            referralCode: row.referral_code,
            level: row.level,
            xp: row.xp,
            coins: row.coins,
            diamonds: row.diamonds,
            gamesPlayed: row.games_played,
            gamesWon: row.games_won,
            avatarId: row.avatar_id,
            frameId: row.frame_id
          }
        });
      } catch {
        return failure(503, 'DATABASE_UNAVAILABLE', 'ارتباط با پایگاه داده برقرار نشد.');
      }
    }

    return failure(404, 'NOT_FOUND', 'مسیر پیدا نشد.');
  }
};
