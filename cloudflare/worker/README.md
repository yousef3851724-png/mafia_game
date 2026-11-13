# Mafia Radical — Cloudflare Worker adapter

This directory is an isolated migration target. It does not replace the existing
Node.js backend, the root Wrangler static-site configuration, or the production
database.

## Phase 1 implemented

- Dedicated Worker entrypoint.
- `GET /health` checks PostgreSQL through the Cloudflare Hyperdrive binding.
- Unmigrated routes explicitly return HTTP 501; they are not silently mocked.

## Required before local testing/deployment

1. Create a Hyperdrive configuration in the Cloudflare dashboard pointing to the
   existing PostgreSQL database. Do not use D1 and do not run migrations.
2. Replace `REPLACE_WITH_HYPERDRIVE_ID` in `wrangler.jsonc` with that Hyperdrive ID.
3. Confirm the database host is reachable from Hyperdrive and TLS settings are correct.
4. Run `npm install`, `npm run check`, then `npm run dev`.

## Migration constraints discovered in the existing backend

- PostgreSQL access uses `pg`; Cloudflare Hyperdrive supports node-postgres
  `pg@8.16.3` with Node.js compatibility.
- Authentication uses native `argon2`; its native addon must be replaced with a
  Workers-compatible password hashing implementation before auth routes can move.
- Existing Express middleware/router modules depend on Express and request/response
  semantics; routes must be adapted and tested, not copied wholesale.
- Existing WebSocket lobby uses Node's HTTP upgrade and `ws` server. Reliable
  room coordination on Workers should be implemented with Durable Objects.
- Payment verification, moderation, wallet updates, game state and audit writes
  must preserve their existing PostgreSQL transaction boundaries.

## Safety

No schema migration is run by this Worker. No user rows, balances, payment records,
room history, or moderation records are modified by the health endpoint.
Do not deploy this scaffold as the live game API: application routes are not migrated yet.
