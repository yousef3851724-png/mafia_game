'use strict';

require('dotenv').config();
const fs = require('node:fs');
const path = require('node:path');
const { loadConfig } = require('./config');
const { createDatabase, withTransaction } = require('./db');

async function main() {
  const config = loadConfig();
  const pool = createDatabase(config);
  try {
    await pool.query(`CREATE TABLE IF NOT EXISTS schema_migrations (
      name TEXT PRIMARY KEY,
      applied_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
    )`);
    const dir = path.join(__dirname, '..', 'migrations');
    const files = fs.readdirSync(dir).filter(name => /^\d+_.*\.sql$/.test(name)).sort();
    for (const name of files) {
      const exists = await pool.query('SELECT 1 FROM schema_migrations WHERE name = $1', [name]);
      if (exists.rowCount) continue;
      const sql = fs.readFileSync(path.join(dir, name), 'utf8');
      await withTransaction(pool, async client => {
        // Migration files are trusted repository code, never user input.
        await client.query(sql);
        await client.query('INSERT INTO schema_migrations(name) VALUES ($1)', [name]);
      });
      console.log(`Applied migration: ${name}`);
    }
  } finally {
    await pool.end();
  }
}

main().catch(error => {
  console.error('Database migration failed:', error.message);
  process.exitCode = 1;
});
