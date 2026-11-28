# Cloudflare Worker migration (staged)

## Current scope

This branch adds a Cloudflare Worker entrypoint that can proxy HTTP API and
WebSocket requests to the existing Node.js backend after an HTTPS origin is
configured as the Worker variable `API_ORIGIN`.

The Worker currently exposes `GET /health`. It reports whether an origin is
configured; it does not claim that the backend or database is healthy.

## Important safety boundaries

- This scaffold does not connect to PostgreSQL, D1, or Hyperdrive.
- It does not run migrations or write to any database.
- It does not replace the existing Node.js backend.
- Do not point `API_ORIGIN` at a production service until its health endpoint
  and WebSocket endpoint have been verified.
- Do not deploy this branch until the origin is confirmed and deployment is
  explicitly approved.

## Next steps

1. Identify a reachable HTTPS Node.js backend origin.
2. Verify `GET /health` and the `/lobby` WebSocket handshake against it.
3. Set Worker variable `API_ORIGIN` in the Cloudflare dashboard.
4. Deploy only this branch to a test Worker and verify API and WebSocket
   forwarding.
5. Separately design and test a PostgreSQL migration/connection strategy
   (including Hyperdrive if appropriate). Database changes require explicit
   approval and a verified backup.
