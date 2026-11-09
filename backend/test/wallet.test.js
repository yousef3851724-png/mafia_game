'use strict';

const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const { test } = require('node:test');
const { INITIAL_PLAYER_WALLET } = require('../src/wallet');

test('ordinary player starting wallet is 500 coins and 10 diamonds', () => {
  assert.deepEqual(INITIAL_PLAYER_WALLET, { coins: 500, diamonds: 10 });
});

test('wallet migration changes defaults without rewriting existing balances', () => {
  const migration = fs.readFileSync(path.join(__dirname, '../migrations/20261109_registration_wallet_defaults.sql'), 'utf8');
  assert.match(migration, /ALTER TABLE players ALTER COLUMN coins SET DEFAULT 500/i);
  assert.match(migration, /ALTER TABLE players ALTER COLUMN diamonds SET DEFAULT 10/i);
  assert.doesNotMatch(migration, /\bUPDATE\s+players\b/i);
});
