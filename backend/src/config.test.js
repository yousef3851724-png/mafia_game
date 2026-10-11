'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');
const { loadConfig } = require('./config');

test('configuration rejects missing database and short JWT secret', () => {
  assert.throws(() => loadConfig({}), /Invalid backend configuration/);
  assert.throws(() => loadConfig({ DATABASE_URL: 'postgres://example', JWT_SECRET: 'short' }), /Invalid backend configuration/);
});

test('configuration parses a valid minimum environment and CORS list', () => {
  const config = loadConfig({
    DATABASE_URL: 'postgres://example',
    JWT_SECRET: 'x'.repeat(40),
    CORS_ORIGINS: 'https://admin.example.com, https://game.example.com',
    PORT: '3001'
  });
  assert.equal(config.PORT, 3001);
  assert.deepEqual(config.CORS_ORIGINS, ['https://admin.example.com', 'https://game.example.com']);
  assert.equal(config.DATABASE_SSL, false);
});
