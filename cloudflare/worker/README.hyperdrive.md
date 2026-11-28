# Mafia Radical — PostgreSQL / Hyperdrive Worker (staged)

This is an isolated, non-deployed Worker entrypoint for evaluating the existing
PostgreSQL backend through Cloudflare Hyperdrive. It deliberately does not use
D1 and does not contain or execute database migrations.

## Safety boundary

- The production database remains the existing PostgreSQL database.
- No schema or data changes are performed by this Worker.
- The staged Wrangler config uses a separate Worker name:
  `mafia-radical-hyperdrive-test`.
- The Hyperdrive ID is a placeholder. Do not replace it with a production ID
  or deploy until connection and compatibility tests are approved.
- The existing `wrangler.jsonc`, D1 migrations, and deployment workflow are
  intentionally left unchanged in this first implementation step.

## Current scope

Implemented as a read-only compatibility slice:

- `GET /health`: opens a short-lived `pg.Client` through the Hyperdrive binding
  and runs `SELECT 1`.
- `GET /api/v1/me`: verifies the existing backend JWT contract
  (HS256, issuer `mafia-radical-api`, audience `mafia-radical-app`) and reads
  the existing `players` row without changing it.

The Worker does **not** yet handle registration/login, Argon2id password
verification, rooms, lobby WebSockets, moderation, wallet changes, or payments.
Those paths must not be routed to this staged entrypoint yet. In particular,
the current D1 Worker uses a separate `users` schema and PBKDF2 password hashes;
it is not compatible with the production PostgreSQL `players` table and
Argon2id hashes.

## Why a request-scoped Client

Cloudflare Hyperdrive owns the upstream connection pool. The Worker creates
one `pg.Client` per request and closes the client after the operation rather
than creating a process-global `pg.Pool`.

## Local checks

From `cloudflare/worker`:

```sh
npm install
npm test
npm run check
```

For local Wrangler development, first set a real Hyperdrive binding ID in
`wrangler.hyperdrive.jsonc` and provide a local test secret through Wrangler
secrets/vars. Do not use production credentials for local tests.

There is intentionally no deployment or migration command in this workflow.
