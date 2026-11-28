const encoder = new TextEncoder();
const decoder = new TextDecoder();

function decodeBase64Url(value) {
  const normalized = value.replace(/-/g, '+').replace(/_/g, '/');
  const padded = normalized + '='.repeat((4 - normalized.length % 4) % 4);
  const binary = atob(padded);
  return Uint8Array.from(binary, (char) => char.charCodeAt(0));
}

/**
 * Verifies the exact JWT contract used by backend/src/security.js:
 * HS256, issuer mafia-radical-api, audience mafia-radical-app.
 */
export async function verifyBackendAccessToken(token, secret, nowSeconds = Math.floor(Date.now() / 1000)) {
  if (typeof token !== 'string' || typeof secret !== 'string' || secret.length < 32) return null;

  try {
    const parts = token.split('.');
    if (parts.length !== 3) return null;
    const [encodedHeader, encodedPayload, encodedSignature] = parts;
    const header = JSON.parse(decoder.decode(decodeBase64Url(encodedHeader)));
    if (header.alg !== 'HS256' || header.typ !== 'JWT') return null;

    const key = await crypto.subtle.importKey(
      'raw',
      encoder.encode(secret),
      { name: 'HMAC', hash: 'SHA-256' },
      false,
      ['verify']
    );
    const valid = await crypto.subtle.verify(
      'HMAC',
      key,
      decodeBase64Url(encodedSignature),
      encoder.encode(`${encodedHeader}.${encodedPayload}`)
    );
    if (!valid) return null;

    const payload = JSON.parse(decoder.decode(decodeBase64Url(encodedPayload)));
    const audienceValid = payload.aud === 'mafia-radical-app' ||
      (Array.isArray(payload.aud) && payload.aud.includes('mafia-radical-app'));

    if (
      payload.iss !== 'mafia-radical-api' ||
      !audienceValid ||
      typeof payload.sub !== 'string' ||
      !payload.sub ||
      typeof payload.exp !== 'number' ||
      payload.exp <= nowSeconds
    ) return null;

    return payload;
  } catch {
    return null;
  }
}

export function bearerToken(request) {
  const value = request.headers.get('authorization') || '';
  const match = /^Bearer\s+(.+)$/i.exec(value);
  return match?.[1] || null;
}
