-- New ordinary accounts must receive the standard starting wallet.
-- Existing player balances are intentionally not modified.
ALTER TABLE players ALTER COLUMN coins SET DEFAULT 500;
ALTER TABLE players ALTER COLUMN diamonds SET DEFAULT 10;
