-- Store purchase ledger for Cafe Bazaar and Myket.
-- Provider receipt verification must complete before granting inventory.
CREATE TABLE IF NOT EXISTS store_products (
  id TEXT PRIMARY KEY,
  item_type TEXT NOT NULL CHECK (item_type IN ('coins','diamonds','avatar','frame','sticker','tombstone')),
  item_ref TEXT,
  quantity INTEGER NOT NULL CHECK (quantity > 0),
  price_irr BIGINT,
  price_usd_cents INTEGER,
  is_active BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CHECK (price_irr IS NULL OR price_irr > 0),
  CHECK (price_usd_cents IS NULL OR price_usd_cents > 0)
);

CREATE TABLE IF NOT EXISTS store_purchases (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  player_id TEXT NOT NULL REFERENCES players(id) ON DELETE RESTRICT,
  provider TEXT NOT NULL CHECK (provider IN ('cafebazaar','myket')),
  product_id TEXT NOT NULL REFERENCES store_products(id) ON DELETE RESTRICT,
  provider_order_id TEXT,
  purchase_token TEXT NOT NULL,
  provider_payload JSONB NOT NULL DEFAULT '{}'::jsonb,
  status TEXT NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending','verified','rejected','refunded')),
  verified_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (provider, purchase_token)
);

CREATE INDEX IF NOT EXISTS store_purchases_player_created_idx
  ON store_purchases(player_id, created_at DESC);

CREATE TABLE IF NOT EXISTS inventory_ledger (
  id BIGSERIAL PRIMARY KEY,
  player_id TEXT NOT NULL REFERENCES players(id) ON DELETE RESTRICT,
  purchase_id UUID REFERENCES store_purchases(id) ON DELETE RESTRICT,
  item_type TEXT NOT NULL CHECK (item_type IN ('coins','diamonds','avatar','frame','sticker','tombstone')),
  item_ref TEXT,
  quantity INTEGER NOT NULL CHECK (quantity > 0),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (purchase_id)
);

-- USD pricing is catalog metadata only in this release.
-- Bazaar and Myket checkout prices remain controlled by each Iranian store.
