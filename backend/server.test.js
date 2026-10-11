'use strict';
const { test } = require('node:test');
const assert = require('node:assert/strict');
const { spawn } = require('node:child_process');
const net = require('node:net');

async function freePort() {
  const s = net.createServer();
  await new Promise((resolve, reject) => s.listen(0, '127.0.0.1', resolve).once('error', reject));
  const port = s.address().port;
  await new Promise(resolve => s.close(resolve));
  return port;
}

test('backend starts and serves a healthy HTTP response', async () => {
  const port = await freePort();
  const child = spawn(process.execPath, ['backend/server.js'], {
    env: { ...process.env, PORT: String(port) },
    stdio: ['ignore', 'pipe', 'pipe'],
  });
  let output = '';
  child.stdout.on('data', d => { output += d.toString(); });
  child.stderr.on('data', d => { output += d.toString(); });
  try {
    let response;
    const deadline = Date.now() + 5000;
    while (Date.now() < deadline) {
      if (child.exitCode !== null) throw new Error(`Backend exited early: ${output}`);
      try {
        response = await fetch(`http://127.0.0.1:${port}/health`);
        break;
      } catch {
        await new Promise(resolve => setTimeout(resolve, 100));
      }
    }
    assert.ok(response, `Health endpoint did not respond. Output: ${output}`);
    assert.equal(response.status, 200);
    const body = await response.json();
    assert.equal(body.status, 'ok');
    assert.equal(body.websocket, 'available');
    assert.equal(typeof body.rooms, 'number');
  } finally {
    child.kill('SIGTERM');
    await new Promise(resolve => {
      if (child.exitCode !== null) return resolve();
      child.once('exit', resolve);
      setTimeout(() => { child.kill('SIGKILL'); resolve(); }, 1500).unref();
    });
  }
});
