import test from 'node:test';
import assert from 'node:assert/strict';
import { bearerToken, verifyBackendAccessToken } from './postgres-auth.js';

const enc = (value) => Buffer.from(value).toString('base64url');
async function sign(payload, secret, header = { alg: 'HS256', typ: 'JWT' }) {
  const h = enc(JSON.stringify(header));
  const p = enc(JSON.stringify(payload));
  const key = await crypto.subtle.importKey(
    'raw', new TextEncoder().encode(secret),
    { name: 'HMAC', hash: 'SHA-256' }, false, ['sign']
  );
  const sig = await crypto.subtle.sign('HMAC', key, new TextEncoder().encode(`${h}.${p}`));
  return `${h}.${p}.${Buffer.from(sig).toString('base64url')}`;
}

test('accepts the backend issuer/audience HS256 token contract', async () => {
  const secret = 'a-secure-test-secret-with-more-than-32-characters';
  const token = await sign({
    sub: 'bfa3c74a-13c7-4f7b-88c8-2ed5f8a9d0a1',
    username: 'tester',
    iss: 'mafia-radical-api',
    aud: 'mafia-radical-app',
    exp: 2000000000
  }, secret);
  const result = await verifyBackendAccessToken(token, secret, 1900000000);
  assert.equal(result.username, 'tester');
});

test('rejects wrong issuer, audience, expiry, and malformed tokens', async () => {
  const secret = 'a-secure-test-secret-with-more-than-32-characters';
  for (const payload of [
    { sub: 'x', iss: 'wrong', aud: 'mafia-radical-app', exp: 2000000000 },
    { sub: 'x', iss: 'mafia-radical-api', aud: 'wrong', exp: 2000000000 },
    { sub: 'x', iss: 'mafia-radical-api', aud: 'mafia-radical-app', exp: 100 }
  ]) {
    const token = await sign(payload, secret);
    assert.equal(await verifyBackendAccessToken(token, secret, 1000), null);
  }
  assert.equal(await verifyBackendAccessToken('not-a-jwt', secret), null);
});

test('extracts bearer tokens case-insensitively', () => {
  assert.equal(bearerToken(new Request('https://example.test', {
    headers: { authorization: 'bEaReR abc.def.ghi' }
  })), 'abc.def.ghi');
  assert.equal(bearerToken(new Request('https://example.test')), null);
});
