'use strict';

const { Pool } = require('pg');

function createDatabase(config) {
  const pool = new Pool({
    connectionString: config.DATABASE_URL,
    ssl: config.DATABASE_SSL ? { rejectUnauthorized: true } : false,
    max: 15,
    idleTimeoutMillis: 30000,
    connectionTimeoutMillis: 5000,
    application_name: 'mafia-radical-backend'
  });
  pool.on('error', error => {
    // Keep credentials out of logs.
    console.error('Unexpected idle PostgreSQL client error:', error.message);
  });
  return pool;
}

async function withTransaction(pool, callback) {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const result = await callback(client);
    await client.query('COMMIT');
    return result;
  } catch (error) {
    try { await client.query('ROLLBACK'); } catch (_) {}
    throw error;
  } finally {
    client.release();
  }
}

module.exports = { createDatabase, withTransaction };
