CREATE TABLE IF NOT EXISTS zp_rooms (
  id TEXT PRIMARY KEY,
  code TEXT NOT NULL UNIQUE,
  owner_id TEXT NOT NULL,
  max_players INTEGER NOT NULL DEFAULT 20,
  status TEXT NOT NULL DEFAULT 'waiting',
  game_state TEXT,
  version INTEGER NOT NULL DEFAULT 0,
  created_at INTEGER DEFAULT (strftime('%s','now'))
);
CREATE TABLE IF NOT EXISTS zp_room_players (
  room_id TEXT NOT NULL,
  player_id TEXT NOT NULL,
  seat INTEGER NOT NULL,
  is_ready INTEGER NOT NULL DEFAULT 0,
  PRIMARY KEY (room_id, player_id),
  UNIQUE (room_id, seat)
);
