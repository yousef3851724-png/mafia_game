'use strict';

const http = require('node:http');
const { randomUUID } = require('node:crypto');
const { WebSocketServer, WebSocket } = require('ws');

const PORT = Number(process.env.PORT || 8080);
const MAX_PLAYERS_PER_ROOM = Number(process.env.MAX_PLAYERS_PER_ROOM || 20);
const rooms = new Map();
const clients = new Map();

const server = http.createServer((req, res) => {
  if (req.url === '/health' || req.url === '/') {
    res.writeHead(200, { 'content-type': 'application/json; charset=utf-8' });
    res.end(JSON.stringify({
      service: 'mafia-radical-backend',
      status: 'ok',
      websocket: 'available',
      rooms: rooms.size
    }));
    return;
  }
  res.writeHead(404, { 'content-type': 'application/json; charset=utf-8' });
  res.end(JSON.stringify({ error: 'not_found' }));
});

const wss = new WebSocketServer({ server, maxPayload: 16 * 1024 });

function send(ws, payload) {
  if (ws.readyState === WebSocket.OPEN) ws.send(JSON.stringify(payload));
}

function roomFor(roomId) {
  if (!rooms.has(roomId)) rooms.set(roomId, new Map());
  return rooms.get(roomId);
}

function publicPlayers(room) {
  return [...room.values()].map(p => ({
    id: p.id,
    name: p.name,
    isHost: p.isHost,
    ready: p.ready,
    seat: p.seat
  }));
}

function broadcast(roomId, payload) {
  const room = rooms.get(roomId);
  if (!room) return;
  for (const player of room.values()) send(player.ws, payload);
}

function broadcastPlayers(roomId) {
  const room = rooms.get(roomId);
  if (room) broadcast(roomId, { type: 'players', players: publicPlayers(room) });
}

function sendError(ws, message) {
  send(ws, { type: 'error', message });
}

function removeClient(ws) {
  const client = clients.get(ws);
  if (!client) return;
  clients.delete(ws);
  const room = rooms.get(client.roomId);
  if (!room) return;
  room.delete(client.playerId);
  if (room.size === 0) {
    rooms.delete(client.roomId);
    return;
  }
  const remaining = [...room.values()];
  if (!remaining.some(p => p.isHost)) remaining[0].isHost = true;
  broadcastPlayers(client.roomId);
}

function joinRoom(ws, data) {
  const roomId = String(data.roomId || '').trim().slice(0, 80);
  const playerId = String(data.playerId || '').trim().slice(0, 80);
  if (!roomId || !playerId) {
    sendError(ws, 'roomId و playerId الزامی هستند.');
    return;
  }

  const room = roomFor(roomId);
  const existing = room.get(playerId);
  if (!existing && room.size >= MAX_PLAYERS_PER_ROOM) {
    sendError(ws, 'ظرفیت این اتاق تکمیل است.');
    return;
  }

  const isFirst = room.size === 0;
  const player = existing || {
    id: playerId,
    name: String(data.name || 'بازیکن').slice(0, 40),
    isHost: isFirst,
    ready: false,
    seat: room.size,
    ws
  };
  player.ws = ws;
  if (data.name) player.name = String(data.name).slice(0, 40);
  room.set(playerId, player);
  clients.set(ws, { roomId, playerId });
  send(ws, { type: 'joined', roomId, playerId, isHost: player.isHost });
  broadcastPlayers(roomId);
}

function handleMessage(ws, raw) {
  let data;
  try {
    data = JSON.parse(raw.toString());
  } catch {
    sendError(ws, 'فرمت پیام معتبر نیست.');
    return;
  }
  if (!data || typeof data.type !== 'string') {
    sendError(ws, 'نوع پیام مشخص نشده است.');
    return;
  }

  const client = clients.get(ws);
  if (data.type === 'join' || data.type === 'game_join') {
    joinRoom(ws, data);
    return;
  }
  if (!client) {
    sendError(ws, 'ابتدا باید وارد اتاق شوید.');
    return;
  }

  const room = rooms.get(client.roomId);
  const player = room && room.get(client.playerId);
  if (!room || !player) {
    sendError(ws, 'اتاق یا بازیکن پیدا نشد.');
    return;
  }

  switch (data.type) {
    case 'ready':
      player.ready = Boolean(data.value);
      broadcastPlayers(client.roomId);
      break;
    case 'seat': {
      const seat = Number(data.seat);
      if (!Number.isInteger(seat) || seat < 0 || seat >= MAX_PLAYERS_PER_ROOM) {
        sendError(ws, 'شماره صندلی معتبر نیست.');
        break;
      }
      const occupant = [...room.values()].find(p => p.seat === seat && p.id !== player.id);
      if (occupant) {
        const previousSeat = player.seat;
        occupant.seat = previousSeat;
      }
      player.seat = seat;
      broadcastPlayers(client.roomId);
      break;
    }
    case 'chat': {
      const text = String(data.text || '').trim().slice(0, 500);
      if (!text) break;
      broadcast(client.roomId, {
        type: 'chat',
        playerId: player.id,
        name: player.name,
        text,
        sentAt: new Date().toISOString()
      });
      break;
    }
    case 'kick':
      if (!player.isHost) {
        sendError(ws, 'فقط میزبان می‌تواند بازیکن را اخراج کند.');
        break;
      }
      if (String(data.playerId) === player.id) {
        sendError(ws, 'میزبان نمی‌تواند خودش را اخراج کند.');
        break;
      }
      {
        const target = room.get(String(data.playerId));
        if (target) {
          send(target.ws, { type: 'error', message: 'از اتاق اخراج شدید.' });
          target.ws.close(1000, 'kicked');
          removeClient(target.ws);
        }
      }
      break;
    case 'start':
      if (!player.isHost) {
        sendError(ws, 'فقط میزبان می‌تواند بازی را شروع کند.');
        break;
      }
      if (room.size < 3) {
        sendError(ws, 'برای شروع آزمایشی حداقل ۳ بازیکن لازم است.');
        break;
      }
      if ([...room.values()].some(p => !p.ready && p.id !== player.id)) {
        sendError(ws, 'همه بازیکنان باید آماده باشند.');
        break;
      }
      broadcast(client.roomId, {
        type: 'start_requested',
        message: 'درخواست شروع دریافت شد؛ موتور امن و کامل بازی هنوز باید پیاده‌سازی شود.'
      });
      break;
    case 'vote':
    case 'night_action':
    case 'skip':
      sendError(ws, 'اکشن‌های واقعی بازی تا پیاده‌سازی موتور سرور فعال نیستند.');
      break;
    default:
      sendError(ws, 'نوع پیام پشتیبانی نمی‌شود.');
  }
}

wss.on('connection', ws => {
  ws.on('message', raw => handleMessage(ws, raw));
  ws.on('close', () => removeClient(ws));
  ws.on('error', () => removeClient(ws));
});

server.listen(PORT, '0.0.0.0', () => {
  console.log(`Mafia Radical backend listening on 0.0.0.0:${PORT}`);
});

function shutdown() {
  for (const ws of wss.clients) ws.close(1001, 'server_shutdown');
  server.close(() => process.exit(0));
  setTimeout(() => process.exit(1), 5000).unref();
}
process.on('SIGTERM', shutdown);
process.on('SIGINT', shutdown);
