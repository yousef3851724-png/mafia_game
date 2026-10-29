CREATE TABLE IF NOT EXISTS payments (
  id BIGSERIAL PRIMARY KEY,
  player_id TEXT NOT NULL,
  package_id TEXT NOT NULL,
  amount_toman INTEGER NOT NULL,
  coins INTEGER NOT NULL,
  authority TEXT UNIQUE,
  status TEXT NOT NULL DEFAULT 'pending',
  ref_id TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  paid_at TIMESTAMPTZ
);
