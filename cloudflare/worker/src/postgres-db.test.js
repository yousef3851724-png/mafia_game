import test from 'node:test';
import assert from 'node:assert/strict';
import { withPostgres } from './postgres-db.js';

test('uses Hyperdrive connection string and closes the request client', async () => {
  const calls = [];
  class FakeClient {
    constructor(config) { calls.push(['constructor', config]); }
    async connect() { calls.push(['connect']); }
    async query(sql) { calls.push(['query', sql]); return { rows: [{ ok: 1 }] }; }
    async end() { calls.push(['end']); }
  }

  const result = await withPostgres(
    { HYPERDRIVE: { connectionString: 'postgres://test.invalid/db' } },
    (client) => client.query('SELECT 1'),
    FakeClient
  );

  assert.deepEqual(result.rows, [{ ok: 1 }]);
  assert.deepEqual(calls.map((call) => call[0]), ['constructor', 'connect', 'query', 'end']);
  assert.equal(calls[0][1].connectionString, 'postgres://test.invalid/db');
});

test('does not attempt a connection without the Hyperdrive binding', async () => {
  await assert.rejects(
    () => withPostgres({}, async () => {}),
    (error) => error.code === 'HYPERDRIVE_NOT_CONFIGURED'
  );
});

test('closes a connected client when the request callback fails', async () => {
  let ended = false;
  class FakeClient {
    async connect() {}
    async end() { ended = true; }
  }
  await assert.rejects(
    () => withPostgres({ HYPERDRIVE: { connectionString: 'postgres://test.invalid/db' } },
      async () => { throw new Error('expected test failure'); }, FakeClient),
    /expected test failure/
  );
  assert.equal(ended, true);
});
