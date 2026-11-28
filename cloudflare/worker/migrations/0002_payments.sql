CREATE TABLE IF NOT EXISTS zp_payments (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id TEXT NOT NULL,
  package_id TEXT NOT NULL,
  amount_toman INTEGER NOT NULL,
  coins INTEGER NOT NULL DEFAULT 0,
  diamonds INTEGER NOT NULL DEFAULT 0,
  authority TEXT NOT NULL UNIQUE,
  status TEXT NOT NULL DEFAULT 'pending',
  ref_id TEXT,
  created_at INTEGER DEFAULT (strftime('%s','now')),
  paid_at INTEGER
);
