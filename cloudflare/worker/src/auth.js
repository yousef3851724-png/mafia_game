const enc = new TextEncoder();
const ISSUER = 'mafia-radical-api';
const AUDIENCE = 'mafia-radical-app';
const DEFAULT_TTL_SEC = 60 * 60 * 24 * 7;

const b64u = (buf) => btoa(String.fromCharCode(...new Uint8Array(buf))).replace(/\\+/g, '-').replace(/\\//g, '_').replace(/=+$/, '');
const unb64u = (s) => Uint8Array.from(atob(s.replace(/-/g, '+').replace(/_/g, '/')), (c) => c.charCodeAt(0));

export async function hashPassword(password, saltB64) {
  const salt = saltB64 ? unb64u(saltB64) : crypto.getRandomValues(new Uint8Array(16));
  const key = await crypto.subtle.importKey('raw', enc.encode(password), 'PBKDF2', false, ['deriveBits']);
  const bits = await crypto.subtle.deriveBits({ name: 'PBKDF2', hash: 'SHA-256', salt, iterations: 100000 }, key, 256);
  return { hash: b64u(bits), salt: b64u(salt) };
}

export function safeEqual(a, b) {
  if (typeof a !== 'string' || typeof b !== 'string' || a.length !== b.length) return false;
  let r = 0;
  for (let i = 0; i < a.length; i++) r |= a.charCodeAt(i) ^ b.charCodeAt(i);
  return r === 0;
}

const hmacKey = (secret, usage) =>
  crypto.subtle.importKey('raw', enc.encode(secret), { name: 'HMAC', hash: 'SHA-256' }, false, usage);

export async function signJwt(payload, secret, ttlSec = DEFAULT_TTL_SEC) {
  const now = Math.floor(Date.now() / 1000);
  const head = b64u(enc.encode(JSON.stringify({ alg: 'HS256', typ: 'JWT' })));
  const claims = {
    ...payload,
    iss: ISSUER,
    aud: AUDIENCE,
    iat: now,
    exp: now + ttlSec
  };
  const body = b64u(enc.encode(JSON.stringify(claims)));
  const sig = await crypto.subtle.sign('HMAC', await hmacKey(secret, ['sign']), enc.encode(`${head}.${body}`));
  return `${head}.${body}.${b64u(sig)}`;
}

export async function verifyJwt(token, secret) {
  try {
    if (typeof token !== 'string') return null;
    const parts = token.split('.');
    if (parts.length !== 3) return null;
    const [h, b, s] = parts;
    const header = JSON.parse(new TextDecoder().decode(unb64u(h)));
    if (header.alg !== 'HS256' || header.typ !== 'JWT') return null;
    const ok = await crypto.subtle.verify('HMAC', await hmacKey(secret, ['verify']), unb64u(s), enc.encode(`${h}.${b}`));
    if (!ok) return null;
    const payload = JSON.parse(new TextDecoder().decode(unb64u(b)));
    const now = Math.floor(Date.now() / 1000);
    if (
      typeof payload.sub !== 'string' ||
      payload.iss !== ISSUER ||
      payload.aud !== AUDIENCE ||
      !Number.isFinite(payload.exp) ||
      payload.exp <= now ||
      (payload.nbf !== undefined && (!Number.isFinite(payload.nbf) || payload.nbf > now))
    ) return null;
    return payload;
  } catch {
    return null;
  }
}
