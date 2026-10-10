'use strict';

require('dotenv').config();
const crypto = require('node:crypto');
const http = require('node:http');
const express = require('express');
const helmet = require('helmet');
const cors = require('cors');
const rateLimit = require('express-rate-limit');
const argon2 = require('argon2');
const { z } = require('zod');
const { WebSocketServer, WebSocket } = require('ws');
const { loadConfig } = require('./config');
const { createDatabase, withTransaction } = require('./db');
const { signAccessToken, verifyAccessToken, requireAuth } = require('./security');
const { assignRoles, getWinner } = require('./game-rules');
const { createModerationRouter } = require('./moderation');

const config = loadConfig();
const pool = createDatabase(config);
const app = express();
app.disable('x-powered-by');
if (config.TRUST_PROXY > 0) app.set('trust proxy', config.TRUST_PROXY);
app.use(helmet());
app.use(cors({
  origin(origin, callback) {
    if (!origin || config.CORS_ORIGINS.length === 0 || config.CORS_ORIGINS.includes(origin)) return callback(null, true);
    return callback(new Error('Origin not allowed'));
  }
}));
app.use(express.json({ limit: '32kb', strict: true }));
app.use(rateLimit({ windowMs: 60_000, limit: 120, standardHeaders: 'draft-8', legacyHeaders: false }));

const authLimiter = rateLimit({ windowMs: 15 * 60_000, limit: 10, standardHeaders: 'draft-8', legacyHeaders: false });
const auth = requireAuth(config);
app.use('/api/v1/moderation', createModerationRouter({ pool, auth }));
const usernameSchema = z.string().trim().min(3).max(24).regex(/^[\p{L}\p{N}_-]+$/u);
const passwordSchema = z.string().min(10).max(128);
const roomCodeSchema = z.string().trim().toUpperCase().regex(/^[A-Z2-9]{6}$/);

function fail(res, status, code, message) {
  return res.status(status).json({ error: { code, message } });
}
function publicPlayer(row) {
  return {
    id: row.id, username: row.username, referralCode: row.referral_code,
    level: row.level, xp: row.xp, coins: row.coins, diamonds: row.diamonds,
    gamesPlayed: row.games_played, gamesWon: row.games_won,
    avatarId: row.avatar_id, frameId: row.frame_id
  };
}
async function getPlayer(playerId) {
  const result = await pool.query(
    'SELECT id, username, referral_code, level, xp, coins, diamonds, games_played, games_won, avatar_id, frame_id FROM players WHERE id = $1',
    [playerId]
  );
  return result.rows[0] || null;
}
async function appendEvent(client, roomId, actorId, eventType, payload = {}) {
  await client.query(
    'INSERT INTO game_events(room_id, actor_id, event_type, payload) VALUES ($1, $2, $3, $4::jsonb)',
    [roomId, actorId || null, eventType, JSON.stringify(payload)]
  );
}

app.get('/health', async (_req, res) => {
  try {
    await pool.query('SELECT 1');
    res.json({ service: 'Mafia Radical API', status: 'ok', database: 'ok', websocket: '/lobby' });
  } catch (_) {
    res.status(503).json({ service: 'Mafia Radical API', status: 'degraded', database: 'unavailable' });
  }
});

app.post('/api/v1/auth/register', authLimiter, async (req, res, next) => {
  try {
    const input = z.object({
      username: usernameSchema,
      password: passwordSchema,
      referralCode: z.string().trim().max(12).optional()
    }).safeParse(req.body);
    if (!input.success) return fail(res, 400, 'VALIDATION_ERROR', 'نام کاربری یا گذرواژه معتبر نیست.');
    const username = input.data.username;
    const referral = input.data.referralCode ? await pool.query(
      'SELECT id FROM players WHERE referral_code = $1', [input.data.referralCode.toUpperCase()]
    ) : null;
    if (input.data.referralCode && !referral.rows[0]) return fail(res, 400, 'INVALID_REFERRAL', 'کد دعوت معتبر نیست.');
    const id = crypto.randomUUID();
    const referralCode = 'MR-' + crypto.randomBytes(4).toString('hex').toUpperCase();
    const passwordHash = await argon2.hash(input.data.password, { type: argon2.argon2id });
    let inserted;
    try {
      inserted = await pool.query(
        `INSERT INTO players(id, username, username_normalized, password_hash, referral_code, referred_by)
         VALUES ($1, $2, $3, $4, $5, $6)
         RETURNING id, username, referral_code, level, xp, coins, diamonds, games_played, games_won, avatar_id, frame_id`,
        [id, username, username.toLocaleLowerCase(), passwordHash, referralCode, referral?.rows[0]?.id || null]
      );
    } catch (error) {
      if (error.code === '23505') return fail(res, 409, 'USERNAME_TAKEN', 'این نام کاربری قبلاً ثبت شده است.');
      throw error;
    }
    const player = inserted.rows[0];
    return res.status(201).json({ token: signAccessToken(player, config), player: publicPlayer(player) });
  } catch (error) { next(error); }
});

app.post('/api/v1/auth/login', authLimiter, async (req, res, next) => {
  try {
    const input = z.object({ username: usernameSchema, password: passwordSchema }).safeParse(req.body);
    if (!input.success) return fail(res, 400, 'VALIDATION_ERROR', 'نام کاربری یا گذرواژه معتبر نیست.');
    const result = await pool.query(
      'SELECT id, username, password_hash FROM players WHERE username_normalized = $1',
      [input.data.username.toLocaleLowerCase()]
    );
    const row = result.rows[0];
    if (!row || !(await argon2.verify(row.password_hash, input.data.password))) {
      return fail(res, 401, 'INVALID_CREDENTIALS', 'نام کاربری یا گذرواژه اشتباه است.');
    }
    const player = await getPlayer(row.id);
    return res.json({ token: signAccessToken(player, config), player: publicPlayer(player) });
  } catch (error) { next(error); }
});

app.get('/api/v1/me', auth, async (req, res, next) => {
  try {
    const player = await getPlayer(req.auth.sub);
    if (!player) return fail(res, 401, 'ACCOUNT_NOT_FOUND', 'حساب کاربری پیدا نشد.');
    return res.json({ player: publicPlayer(player) });
  } catch (error) { next(error); }
});

app.get('/api/v1/rooms', auth, async (_req, res, next) => {
  try {
    const result = await pool.query(
      `SELECT r.id, r.code, r.status, r.max_players, r.created_at,
              p.username AS owner_name, COUNT(rp.player_id)::int AS player_count
       FROM game_rooms r JOIN players p ON p.id = r.owner_id
       LEFT JOIN room_players rp ON rp.room_id = r.id
       WHERE r.status = 'waiting'
       GROUP BY r.id, p.username ORDER BY r.created_at DESC LIMIT 50`
    );
    res.json({ rooms: result.rows.map(row => ({
      id: row.id, code: row.code, status: row.status, maxPlayers: row.max_players,
      playerCount: row.player_count, ownerName: row.owner_name, createdAt: row.created_at
    })) });
  } catch (error) { next(error); }
});

app.post('/api/v1/rooms', auth, async (req, res, next) => {
  try {
    const input = z.object({ maxPlayers: z.number().int().min(4).max(20).default(20) }).safeParse(req.body || {});
    if (!input.success) return fail(res, 400, 'VALIDATION_ERROR', 'تعداد بازیکنان باید بین ۴ تا ۲۰ باشد.');
    const roomId = crypto.randomUUID();
    const code = crypto.randomBytes(4).toString('hex').toUpperCase().replace(/[01IO]/g, '2').slice(0, 6);
    const result = await withTransaction(pool, async client => {
      const room = await client.query(
        `INSERT INTO game_rooms(id, code, owner_id, max_players)
         VALUES ($1, $2, $3, $4) RETURNING id, code, status, max_players`,
        [roomId, code, req.auth.sub, input.data.maxPlayers]
      );
      await client.query('INSERT INTO room_players(room_id, player_id, seat) VALUES ($1, $2, 1)', [roomId, req.auth.sub]);
      await appendEvent(client, roomId, req.auth.sub, 'room_created', { maxPlayers: input.data.maxPlayers });
      return room.rows[0];
    });
    res.status(201).json({ room: { id: result.id, code: result.code, status: result.status, maxPlayers: result.max_players } });
  } catch (error) { next(error); }
});

app.post('/api/v1/rooms/join', auth, async (req, res, next) => {
  try {
    const input = z.object({ code: roomCodeSchema }).safeParse(req.body);
    if (!input.success) return fail(res, 400, 'VALIDATION_ERROR', 'کد اتاق معتبر نیست.');
    const result = await withTransaction(pool, async client => {
      const found = await client.query('SELECT * FROM game_rooms WHERE code = $1 FOR UPDATE', [input.data.code]);
      const room = found.rows[0];
      if (!room || room.status !== 'waiting') return { error: 'ROOM_UNAVAILABLE' };
      const existing = await client.query('SELECT 1 FROM room_players WHERE room_id = $1 AND player_id = $2', [room.id, req.auth.sub]);
      if (existing.rowCount) return { roomId: room.id, code: room.code };
      const count = await client.query('SELECT COUNT(*)::int AS count FROM room_players WHERE room_id = $1', [room.id]);
      if (count.rows[0].count >= room.max_players) return { error: 'ROOM_FULL' };
      const seats = await client.query('SELECT seat FROM room_players WHERE room_id = $1 AND seat IS NOT NULL', [room.id]);
      const occupied = new Set(seats.rows.map(row => row.seat));
      let seat = 1;
      while (occupied.has(seat)) seat++;
      await client.query('INSERT INTO room_players(room_id, player_id, seat) VALUES ($1, $2, $3)', [room.id, req.auth.sub, seat]);
      await appendEvent(client, room.id, req.auth.sub, 'player_joined', {});
      return { roomId: room.id, code: room.code };
    });
    if (result.error === 'ROOM_UNAVAILABLE') return fail(res, 404, result.error, 'اتاق پیدا نشد یا دیگر پذیرای بازیکن نیست.');
    if (result.error === 'ROOM_FULL') return fail(res, 409, result.error, 'ظرفیت اتاق تکمیل است.');
    return res.json({ room: result });
  } catch (error) { next(error); }
});

app.post('/api/v1/rooms/:code/ready', auth, async (req, res, next) => {
  try {
    const code = roomCodeSchema.safeParse(req.params.code);
    const ready = z.boolean().safeParse(req.body?.ready);
    if (!code.success || !ready.success) return fail(res, 400, 'VALIDATION_ERROR', 'درخواست آماده‌بودن معتبر نیست.');
    const result = await withTransaction(pool, async client => {
      const roomResult = await client.query('SELECT id, status FROM game_rooms WHERE code = $1 FOR UPDATE', [code.data]);
      const room = roomResult.rows[0];
      if (!room || room.status !== 'waiting') return { error: 'ROOM_UNAVAILABLE' };
      const update = await client.query(
        'UPDATE room_players SET is_ready = $3 WHERE room_id = $1 AND player_id = $2',
        [room.id, req.auth.sub, ready.data]
      );
      if (!update.rowCount) return { error: 'NOT_IN_ROOM' };
      await appendEvent(client, room.id, req.auth.sub, 'player_ready', { ready: ready.data });
      return { roomId: room.id, ready: ready.data };
    });
    if (result.error === 'ROOM_UNAVAILABLE') return fail(res, 404, result.error, 'اتاق در دسترس نیست.');
    if (result.error === 'NOT_IN_ROOM') return fail(res, 403, result.error, 'عضو این اتاق نیستید.');
    res.json(result);
  } catch (error) { next(error); }
});

app.post('/api/v1/rooms/:code/start', auth, async (req, res, next) => {
  try {
    const code = roomCodeSchema.safeParse(req.params.code);
    if (!code.success) return fail(res, 400, 'VALIDATION_ERROR', 'کد اتاق معتبر نیست.');
    const result = await withTransaction(pool, async client => {
      const roomResult = await client.query('SELECT * FROM game_rooms WHERE code = $1 FOR UPDATE', [code.data]);
      const room = roomResult.rows[0];
      if (!room || room.status !== 'waiting') return { error: 'ROOM_UNAVAILABLE' };
      if (room.owner_id !== req.auth.sub) return { error: 'OWNER_ONLY' };
      const members = await client.query(
        'SELECT rp.player_id, rp.is_ready FROM room_players rp WHERE rp.room_id = $1 ORDER BY rp.seat',
        [room.id]
      );
      if (members.rowCount < 4) return { error: 'NOT_ENOUGH_PLAYERS' };
      if (members.rows.some(member => !member.is_ready && member.player_id !== req.auth.sub)) return { error: 'PLAYERS_NOT_READY' };
      const roleMap = assignRoles(members.rows.map(row => row.player_id), max => crypto.randomInt(0, max));
      const state = { phase: 'night', round: 1, alivePlayerIds: members.rows.map(row => row.player_id), roles: roleMap, votes: {}, nightActions: {} };
      await client.query(
        "UPDATE game_rooms SET status = 'in_game', game_state = $2::jsonb, version = version + 1, updated_at = NOW() WHERE id = $1",
        [room.id, JSON.stringify(state)]
      );
      await appendEvent(client, room.id, req.auth.sub, 'game_started', { playerCount: members.rowCount, round: 1 });
      return { roomId: room.id, code: room.code, state };
    });
    if (result.error === 'ROOM_UNAVAILABLE') return fail(res, 404, result.error, 'اتاق در دسترس نیست.');
    if (result.error === 'OWNER_ONLY') return fail(res, 403, result.error, 'فقط سازنده اتاق می‌تواند بازی را آغاز کند.');
    if (result.error === 'NOT_ENOUGH_PLAYERS') return fail(res, 409, result.error, 'برای شروع حداقل ۴ بازیکن لازم است.');
    if (result.error === 'PLAYERS_NOT_READY') return fail(res, 409, result.error, 'همه بازیکنان باید آماده باشند.');
    // Role assignments are never returned in this response; players receive their own role via authenticated game-state retrieval.
    res.json({ room: { id: result.roomId, code: result.code, status: 'in_game' }, message: 'بازی آغاز شد.' });
  } catch (error) { next(error); }
});

app.get('/api/v1/rooms/:code/state', auth, async (req, res, next) => {
  try {
    const code = roomCodeSchema.safeParse(req.params.code);
    if (!code.success) return fail(res, 400, 'VALIDATION_ERROR', 'کد اتاق معتبر نیست.');
    const roomResult = await pool.query('SELECT id, status, game_state, version FROM game_rooms WHERE code = $1', [code.data]);
    const room = roomResult.rows[0];
    if (!room) return fail(res, 404, 'ROOM_NOT_FOUND', 'اتاق پیدا نشد.');
    const member = await pool.query('SELECT 1 FROM room_players WHERE room_id = $1 AND player_id = $2', [room.id, req.auth.sub]);
    if (!member.rowCount) return fail(res, 403, 'NOT_IN_ROOM', 'عضو این اتاق نیستید.');
    const state = room.game_state || {};
    const ownRole = Array.isArray(state.roles) ? state.roles.find(item => item.playerId === req.auth.sub)?.role : null;
    res.json({
      room: { code: code.data, status: room.status, version: room.version },
      game: room.status === 'in_game' || room.status === 'finished' ? {
        phase: state.phase, round: state.round, alivePlayerIds: state.alivePlayerIds,
        ownRole, winner: state.winner || null
      } : null
    });
  } catch (error) { next(error); }
});

const server = http.createServer(app);
const wss = new WebSocketServer({ noServer: true, maxPayload: 16 * 1024 });
const socketsByRoom = new Map();

function send(ws, data) {
  if (ws.readyState === WebSocket.OPEN) ws.send(JSON.stringify(data));
}
function broadcast(roomId, data) {
  const sockets = socketsByRoom.get(roomId);
  if (!sockets) return;
  for (const ws of sockets) send(ws, data);
}
async function lobbySnapshot(roomId) {
  const result = await pool.query(
    `SELECT p.id, p.username, rp.seat, rp.is_ready
     FROM room_players rp JOIN players p ON p.id = rp.player_id
     WHERE rp.room_id = $1 ORDER BY rp.seat`,
    [roomId]
  );
  return result.rows.map(row => ({ id: row.id, username: row.username, seat: row.seat, ready: row.is_ready }));
}

server.on('upgrade', async (request, socket, head) => {
  try {
    const url = new URL(request.url, 'http://localhost');
    if (url.pathname !== '/lobby') return socket.destroy();
    const token = url.searchParams.get('token');
    if (!token) return socket.destroy();
    const identity = verifyAccessToken(token, config);
    const roomCode = roomCodeSchema.safeParse(url.searchParams.get('roomCode'));
    if (!roomCode.success) return socket.destroy();
    const roomResult = await pool.query('SELECT id, code, status FROM game_rooms WHERE code = $1', [roomCode.data]);
    const room = roomResult.rows[0];
    if (!room || room.status === 'closed') return socket.destroy();
    const member = await pool.query('SELECT 1 FROM room_players WHERE room_id = $1 AND player_id = $2', [room.id, identity.sub]);
    if (!member.rowCount) return socket.destroy();
    wss.handleUpgrade(request, socket, head, ws => {
      ws.playerId = identity.sub;
      ws.roomId = room.id;
      ws.roomCode = room.code;
      wss.emit('connection', ws);
    });
  } catch (_) { socket.destroy(); }
});

wss.on('connection', async ws => {
  if (!socketsByRoom.has(ws.roomId)) socketsByRoom.set(ws.roomId, new Set());
  socketsByRoom.get(ws.roomId).add(ws);
  try { send(ws, { type: 'players', players: await lobbySnapshot(ws.roomId) }); }
  catch (_) { send(ws, { type: 'error', code: 'SERVER_ERROR' }); }
  ws.on('message', async raw => {
    let message;
    try { message = JSON.parse(raw.toString()); }
    catch (_) { return send(ws, { type: 'error', code: 'INVALID_JSON' }); }
    if (!message || typeof message.type !== 'string') return send(ws, { type: 'error', code: 'INVALID_MESSAGE' });
    try {
      if (message.type === 'ready') {
        if (typeof message.ready !== 'boolean') return send(ws, { type: 'error', code: 'VALIDATION_ERROR' });
        const result = await pool.query(
          "UPDATE room_players rp SET is_ready = $3 FROM game_rooms r WHERE rp.room_id = r.id AND r.id = $1 AND rp.player_id = $2 AND r.status = 'waiting'",
          [ws.roomId, ws.playerId, message.ready]
        );
        if (!result.rowCount) return send(ws, { type: 'error', code: 'ROOM_NOT_WAITING' });
        await pool.query('INSERT INTO game_events(room_id, actor_id, event_type, payload) VALUES ($1,$2,$3,$4::jsonb)',
          [ws.roomId, ws.playerId, 'player_ready', JSON.stringify({ ready: message.ready })]);
        broadcast(ws.roomId, { type: 'players', players: await lobbySnapshot(ws.roomId) });
      } else if (message.type === 'chat') {
        const text = typeof message.text === 'string' ? message.text.trim() : '';
        if (!text || text.length > 300) return send(ws, { type: 'error', code: 'INVALID_CHAT' });
        const player = await getPlayer(ws.playerId);
        const payload = { playerId: ws.playerId, username: player.username, text, sentAt: new Date().toISOString() };
        await pool.query('INSERT INTO game_events(room_id, actor_id, event_type, payload) VALUES ($1,$2,$3,$4::jsonb)',
          [ws.roomId, ws.playerId, 'chat', JSON.stringify(payload)]);
        broadcast(ws.roomId, { type: 'chat', ...payload });
      } else {
        send(ws, { type: 'error', code: 'UNSUPPORTED_OPERATION', message: 'این عملیات هنوز در پروتکل آنلاین پیاده‌سازی نشده است.' });
      }
    } catch (error) {
      console.error('WebSocket message failed:', error.message);
      send(ws, { type: 'error', code: 'SERVER_ERROR' });
    }
  });
  ws.on('close', () => {
    const roomSockets = socketsByRoom.get(ws.roomId);
    if (roomSockets) {
      roomSockets.delete(ws);
      if (!roomSockets.size) socketsByRoom.delete(ws.roomId);
    }
  });
});

app.use((error, _req, res, _next) => {
  console.error('Request failed:', error.message);
  if (res.headersSent) return;
  res.status(500).json({ error: { code: 'INTERNAL_ERROR', message: 'خطای داخلی سرور.' } });
});

async function shutdown(signal) {
  console.log(`Received ${signal}; shutting down gracefully.`);
  server.close();
  wss.clients.forEach(ws => ws.close(1001, 'server shutdown'));
  try { await pool.end(); } finally { process.exit(0); }
}
process.once('SIGTERM', () => shutdown('SIGTERM'));
process.once('SIGINT', () => shutdown('SIGINT'));

server.listen(config.PORT, config.HOST, () => {
  console.log(`Mafia Radical API listening on ${config.HOST}:${config.PORT}`);
});

module.exports = { app, server, pool };
