import { withPostgres } from './postgres-db.js';
import { bearerToken, verifyBackendAccessToken } from './postgres-auth.js';

const json = (data, status = 200) => Response.json(data, {
  status,
  headers: { 'cache-control': 'no-store' }
});
const failure = (status, code, message, extra = {}) =>
  json({ error: { code, message, ...extra } }, status);

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
        const result = await withPostgres(env, async (client) => {
          const ban = await client.query(
            `SELECT ends_at FROM player_bans
             WHERE player_id = $1 AND revoked_at IS NULL
               AND starts_at <= NOW() AND ends_at > NOW()
             ORDER BY ends_at DESC LIMIT 1`,
            [identity.sub]
          );
          if (ban.rowCount) return { bannedUntil: ban.rows[0].ends_at };

          const player = await client.query(
            `SELECT id, username, referral_code, level, xp, coins, diamonds,
                    games_played, games_won, avatar_id, frame_id
             FROM players WHERE id = $1`,
            [identity.sub]
          );
          return { row: player.rows[0] || null };
        });

        if (result.bannedUntil) {
          return failure(403, 'ACCOUNT_BANNED', 'حساب کاربری به‌طور موقت مسدود است.', {
            until: result.bannedUntil
          });
        }
        const row = result.row;
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
