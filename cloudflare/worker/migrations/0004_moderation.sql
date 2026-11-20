CREATE TABLE IF NOT EXISTS moderation_events (
  id TEXT PRIMARY KEY,
  room_id TEXT NOT NULL,
  player_id TEXT NOT NULL,
  username TEXT NOT NULL,
  category TEXT NOT NULL,
  severity TEXT NOT NULL,
  message_excerpt TEXT NOT NULL,
  model TEXT NOT NULL,
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_moderation_events_room_created
  ON moderation_events(room_id, created_at);
CREATE INDEX IF NOT EXISTS idx_moderation_events_player_created
  ON moderation_events(player_id, created_at);
