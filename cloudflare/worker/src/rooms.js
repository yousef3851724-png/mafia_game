const json = (d, s = 200) =>
  Response.json(d, { status: s, headers: { 'cache-control': 'no-store' } });
const fail = (s, code, message) => json({ error: { code, message } }, s);
const CODE_RE = /^[A-Z0-9]{4,8}$/;
const normCode = (c) => String(c || '').trim().toUpperCase();
const ALPHABET = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

function newCode() {
  const b = crypto.getRandomValues(new Uint8Array(6));
  return Array.from(b, (x) => ALPHABET[x % ALPHABET.length]).join('');
}

async function readBody(request) {
  try { return await request.json(); } catch { return {}; }
}

const getRoom = (env, code) =>
  env.DB.prepare('SELECT * FROM zp_rooms WHERE code = ?').bind(code).first();

const isMember = (env, roomId, userId) =>
  env.DB.prepare('SELECT 1 AS x FROM zp_room_players WHERE room_id = ? AND player_id = ?')
    .bind(roomId, userId).first();

// PLACEHOLDER: replace with assignRoles from backend/src/game-rules.js
function assignRoles(ids) {
  const a = [...ids];
  for (let i = a.length - 1; i > 0; i--) {
    const j = crypto.getRandomValues(new Uint32Array(1))[0] % (i + 1);
    [a[i], a[j]] = [a[j], a[i]];
  }
  const mafia = Math.max(1, Math.floor(a.length / 4));
  return a.map((playerId, i) => ({
    playerId,
    role: i < mafia ? 'mafia' : i === mafia ? 'doctor' : i === mafia + 1 ? 'detective' : 'citizen'
  }));
}

async function route(request, env, pathname, userId) {
  const m = request.method;
  const sub = pathname.split('/').filter(Boolean).slice(2);

  if (sub.length === 0 && m === 'GET') {
    const { results } = await env.DB.prepare(
      `SELECT r.id, r.code, r.status, r.max_players, r.created_at, u.username AS owner_name,
         (SELECT COUNT(*) FROM zp_room_players rp WHERE rp.room_id = r.id) AS player_count
       FROM zp_rooms r JOIN users u ON u.id = r.owner_id
       WHERE r.status = 'waiting' ORDER BY r.created_at DESC LIMIT 50`
    ).all();
    return json({ rooms: results.map((r) => ({
      id: r.id, code: r.code, status: r.status, maxPlayers: r.max_players,
      playerCount: r.player_count, ownerName: r.owner_name, createdAt: r.created_at
    })) });
  }

  if (sub.length === 0 && m === 'POST') {
    const b = await readBody(request);
    const max = b.maxPlayers === undefined ? 20 : b.maxPlayers;
    if (!Number.isInteger(max) || max < 4 || max > 20)
      return fail(400, 'VALIDATION_ERROR', 'تعداد بازیکنان باید بین ۴ تا ۲۰ باشد.');
    const id = crypto.randomUUID();
    const code = newCode();
    await env.DB.batch([
      env.DB.prepare('INSERT INTO zp_rooms (id, code, owner_id, max_players) VALUES (?,?,?,?)')
        .bind(id, code, userId, max),
      env.DB.prepare('INSERT INTO zp_room_players (room_id, player_id, seat) VALUES (?,?,1)')
        .bind(id, userId)
    ]);
    return json({ room: { id, code, status: 'waiting', maxPlayers: max } }, 201);
  }

  if (sub.length === 1 && sub[0] === 'join' && m === 'POST') {
    const code = normCode((await readBody(request)).code);
    if (!CODE_RE.test(code)) return fail(400, 'VALIDATION_ERROR', 'کد اتاق معتبر نیست.');
    const room = await getRoom(env, code);
    if (!room || room.status !== 'waiting')
      return fail(404, 'ROOM_UNAVAILABLE', 'اتاق پیدا نشد یا دیگر پذیرای بازیکن نیست.');
    if (await isMember(env, room.id, userId)) return json({ room: { roomId: room.id, code: room.code } });
    const { results } = await env.DB.prepare('SELECT seat FROM zp_room_players WHERE room_id = ?')
      .bind(room.id).all();
    const used = new Set(results.map((r) => r.seat));
    let seat = 1;
    while (used.has(seat)) seat++;
    const ins = await env.DB.prepare(
      'INSERT INTO zp_room_players (room_id, player_id, seat) SELECT ?1, ?2, ?3 WHERE (SELECT COUNT(*) FROM zp_room_players WHERE room_id = ?1) < ?4'
    ).bind(room.id, userId, seat, room.max_players).run();
    if (ins.meta.changes !== 1) return fail(409, 'ROOM_FULL', 'ظرفیت اتاق تکمیل است.');
    return json({ room: { roomId: room.id, code: room.code } });
  }

  if (sub.length === 2) {
    const code = normCode(decodeURIComponent(sub[0]));
    if (!CODE_RE.test(code)) return fail(400, 'VALIDATION_ERROR', 'کد اتاق معتبر نیست.');
    const room = await getRoom(env, code);

    if (sub[1] === 'ready' && m === 'POST') {
      const b = await readBody(request);
      if (typeof b.ready !== 'boolean') return fail(400, 'VALIDATION_ERROR', 'درخواست آماده‌بودن معتبر نیست.');
      if (!room || room.status !== 'waiting') return fail(404, 'ROOM_UNAVAILABLE', 'اتاق در دسترس نیست.');
      const up = await env.DB.prepare(
        'UPDATE zp_room_players SET is_ready = ? WHERE room_id = ? AND player_id = ?'
      ).bind(b.ready ? 1 : 0, room.id, userId).run();
      if (up.meta.changes !== 1) return fail(403, 'NOT_IN_ROOM', 'عضو این اتاق نیستید.');
      return json({ roomId: room.id, ready: b.ready });
    }

    if (sub[1] === 'start' && m === 'POST') {
      if (!room || room.status !== 'waiting') return fail(404, 'ROOM_UNAVAILABLE', 'اتاق در دسترس نیست.');
      if (room.owner_id !== userId) return fail(403, 'OWNER_ONLY', 'فقط سازنده اتاق می‌تواند بازی را آغاز کند.');
      const { results } = await env.DB.prepare(
        'SELECT player_id, is_ready FROM zp_room_players WHERE room_id = ? ORDER BY seat'
      ).bind(room.id).all();
      if (results.length < 4) return fail(409, 'NOT_ENOUGH_PLAYERS', 'برای شروع حداقل ۴ بازیکن لازم است.');
      if (results.some((r) => !r.is_ready && r.player_id !== userId))
        return fail(409, 'PLAYERS_NOT_READY', 'همه بازیکنان باید آماده باشند.');
      const ids = results.map((r) => r.player_id);
      const state = { phase: 'night', round: 1, alivePlayerIds: ids, roles: assignRoles(ids), votes: {}, nightActions: {} };
      const up = await env.DB.prepare(
        "UPDATE zp_rooms SET status='in_game', game_state=?, version=version+1 WHERE id=? AND status='waiting'"
      ).bind(JSON.stringify(state), room.id).run();
      if (up.meta.changes !== 1) return fail(404, 'ROOM_UNAVAILABLE', 'اتاق در دسترس نیست.');
      return json({ room: { id: room.id, code: room.code, status: 'in_game' }, message: 'بازی آغاز شد.' });
    }

    if (sub[1] === 'state' && m === 'GET') {
      if (!room) return fail(404, 'ROOM_NOT_FOUND', 'اتاق پیدا نشد.');
      if (!(await isMember(env, room.id, userId))) return fail(403, 'NOT_IN_ROOM', 'عضو این اتاق نیستید.');
      const state = room.game_state ? JSON.parse(room.game_state) : {};
      const own = Array.isArray(state.roles) ? state.roles.find((i) => i.playerId === userId) : null;
      const live = room.status === 'in_game' || room.status === 'finished';
      return json({
        room: { code, status: room.status, version: room.version },
        game: live ? {
          phase: state.phase, round: state.round, alivePlayerIds: state.alivePlayerIds,
          ownRole: own ? own.role : null, winner: state.winner || null
        } : null
      });
    }
  }

  return fail(404, 'NOT_FOUND', 'route not found');
}

export async function handleRooms(request, env, pathname, userId) {
  try {
    return await route(request, env, pathname, userId);
  } catch (e) {
    return fail(500, 'SERVER_ERROR', 'خطای سرور');
  }
}
