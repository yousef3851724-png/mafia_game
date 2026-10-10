CREATE TABLE IF NOT EXISTS players (
  id UUID PRIMARY KEY,
  username VARCHAR(24) NOT NULL,
  username_normalized VARCHAR(24) NOT NULL UNIQUE,
  password_hash TEXT NOT NULL,
  referral_code VARCHAR(12) NOT NULL UNIQUE,
  referred_by UUID REFERENCES players(id) ON DELETE SET NULL,
  level INTEGER NOT NULL DEFAULT 1 CHECK (level >= 1),
  xp BIGINT NOT NULL DEFAULT 0 CHECK (xp >= 0),
  coins BIGINT NOT NULL DEFAULT 1000 CHECK (coins >= 0),
  diamonds BIGINT NOT NULL DEFAULT 10 CHECK (diamonds >= 0),
  games_played BIGINT NOT NULL DEFAULT 0 CHECK (games_played >= 0),
  games_won BIGINT NOT NULL DEFAULT 0 CHECK (games_won >= 0),
  avatar_id VARCHAR(80),
  frame_id VARCHAR(80),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CHECK (games_won <= games_played)
);

CREATE TABLE IF NOT EXISTS game_rooms (
  id UUID PRIMARY KEY,
  code VARCHAR(8) NOT NULL UNIQUE,
  owner_id UUID NOT NULL REFERENCES players(id),
  status VARCHAR(16) NOT NULL DEFAULT 'waiting'
    CHECK (status IN ('waiting', 'in_game', 'finished', 'closed')),
  max_players SMALLINT NOT NULL DEFAULT 20 CHECK (max_players BETWEEN 4 AND 20),
  settings JSONB NOT NULL DEFAULT '{}'::jsonb,
  game_state JSONB NOT NULL DEFAULT '{}'::jsonb,
  version BIGINT NOT NULL DEFAULT 1,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS room_players (
  room_id UUID NOT NULL REFERENCES game_rooms(id) ON DELETE CASCADE,
  player_id UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
  seat SMALLINT,
  is_ready BOOLEAN NOT NULL DEFAULT FALSE,
  joined_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (room_id, player_id),
  UNIQUE (room_id, seat)
);

CREATE TABLE IF NOT EXISTS game_events (
  id BIGSERIAL PRIMARY KEY,
  room_id UUID NOT NULL REFERENCES game_rooms(id) ON DELETE CASCADE,
  actor_id UUID REFERENCES players(id) ON DELETE SET NULL,
  event_type VARCHAR(48) NOT NULL,
  payload JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_game_events_room_id_id ON game_events(room_id, id);
CREATE INDEX IF NOT EXISTS idx_rooms_status_updated ON game_rooms(status, updated_at);
CREATE INDEX IF NOT EXISTS idx_room_players_player ON room_players(player_id);
