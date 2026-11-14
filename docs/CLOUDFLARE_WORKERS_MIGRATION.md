# Cloudflare Workers migration plan

## Status

This is a staged migration plan only. It does not replace or deploy the existing Node.js backend. The current backend remains the reference implementation until the Worker passes compatibility, security, database, and client contract tests.

## Target architecture

- Cloudflare Worker: HTTP API entry point using the Fetch API and explicit route handlers (do not try to run the current Express application unchanged).
- Hyperdrive: connection from the Worker to the existing PostgreSQL database. Keep the existing database and schema; do not create a replacement database or run destructive migrations during the first phase.
- Durable Objects: authoritative room/lobby coordination and WebSocket session state. Persist durable game/account data in PostgreSQL; do not treat Durable Object memory as the account database.
- Cloudflare Secrets: JWT signing secret and any payment/OpenAI credentials. Never put secrets in Wrangler configuration, source control, build logs, or client builds.
- R2 only if/when private recording or media storage is implemented with consent, access control, and retention policy.

## Compatibility requirements before implementation

1. Preserve the current API contract and response shapes for registration, login, profile, rooms, groups, moderation, payments, and health.
2. Preserve existing PostgreSQL tables, player IDs, wallet balances, moderation records, and payment history. No database reset, drop, truncate, or replacement.
3. Password compatibility is a release blocker: current accounts use Argon2 hashes. Prove the Worker can verify existing hashes before routing login traffic to it. Never reset passwords or silently change hashes. If compatible Argon2 verification is unavailable, retain a temporary secure legacy-auth path until a verified migration strategy exists.
4. JWT compatibility is a release blocker: preserve issuer, audience, subject, expiry behavior, and signing key so existing sessions remain valid during cutover.
5. Reproduce transaction boundaries and row-locking semantics for payments, wallet changes, room membership, and moderation.
6. WebSocket authentication and room authorization must be enforced server-side. Durable Objects must validate every message and reconnect, not merely broadcast client data.
7. Keep the Flutter API and WSS URLs unchanged until the new Worker passes end-to-end tests.

## Phases and acceptance criteria

### Phase 0 — inventory (no production changes)
- Record every route, middleware, SQL table, migration, WebSocket event, secret, and client call site.
- Confirm which PostgreSQL database contains the current production accounts and verify that a restorable backup exists.
- Run existing unit tests and backend syntax checks.

### Phase 1 — isolated Worker skeleton
- Create a separate Worker entry point and Wrangler configuration on the migration branch.
- Add only a non-sensitive /health endpoint initially.
- Configure Hyperdrive and Durable Object bindings as environment bindings, without placing credentials in source.
- Deploy only to a preview Worker URL, never the production domain.

### Phase 2 — read-only database compatibility
- Connect through Hyperdrive and run read-only checks (SELECT 1, schema version, expected table presence).
- Compare returned account/profile data against the existing backend.
- Do not run migrations automatically from Worker startup.

### Phase 3 — authentication compatibility
- Implement registration/login only after Argon2 hash verification and JWT compatibility tests pass.
- Use test accounts and a disposable database first.
- Verify rate limits, input validation, account lock/ban checks, and error handling.

### Phase 4 — API and realtime parity
- Port groups, rooms, moderation, payments, and AI routes one module at a time.
- Move room coordination and WebSocket lifecycle to Durable Objects.
- Test concurrent joins, disconnect/reconnect, duplicate payment callbacks, room ownership, and authorization.

### Phase 5 — controlled cutover
- Run production read-only shadow comparisons first.
- Back up the database and record the current deployment configuration.
- Switch traffic only after acceptance tests pass and rollback is documented.
- Keep the previous Node.js deployment and database available until the rollback window closes.

## Explicitly out of scope until separately approved

- Deleting or replacing the existing database.
- Changing player balances, owner identity, roles, or password hashes.
- Running schema migrations against production.
- Changing Flutter production API/WSS URLs.
- Enabling paid Cloudflare products or creating billable resources.
- Advertising online gameplay features as production-ready before full server-authoritative gameplay tests pass.

## Known current-backend facts

- The current service is CommonJS Node.js with Express 5, ws, pg, argon2, and JWT.
- PostgreSQL is required by current configuration.
- Existing password verification uses Argon2.
- The current JWT issuer is mafia-radical-api and audience is mafia-radical-app.
- Current standard account wallet constant is 500 coins and 10 diamonds.
- Current room WebSocket endpoint is /lobby?roomCode=...&token=....
- Existing README documents that server-authoritative voting, night-action resolution, phase timers, reconnection recovery, economy transactions, and full end-to-end client integration are not yet complete.

## Audit findings — 2026-11-14

The current Worker implementation is not approved for production cutover. The following compatibility blockers were found by comparing it with `backend/src`:

- **Password hashes are incompatible:** PostgreSQL accounts use Argon2id, while the preview Worker currently hashes/verifies PBKDF2. Existing users cannot safely sign in through that Worker. Do not reset or rewrite password hashes as a workaround.
- **Account schema is not migrated:** the preview Worker creates a separate `users` table, while the current service uses `players` and related tables. The three D1 SQL files create empty tables; they do not copy any existing users, balances, room history, payment records, or moderation data.
- **Wallet defaults are inconsistent:** the preview D1 schema defaults to 100 coins / 0 diamonds; the current backend's standard new-player wallet is 500 coins / 10 diamonds. The preview registration response also hardcodes the old 100 / 0 values. Do not enable registration against this schema.
- **JWT compatibility is incomplete:** the current backend signs JWTs with issuer `mafia-radical-api` and audience `mafia-radical-app`; the preview Worker currently omits those claims and does not validate them.
- **API coverage is incomplete:** the Worker currently has only a subset of the production API. Moderation, groups, full game-state transitions, game history, and the current AI endpoint are not at parity.
- **Realtime coverage is incomplete:** the Durable Object currently handles basic ready/chat messages; the current client/game protocol needs full authorization, gameplay actions, disconnect/reconnect behavior, and parity tests before cutover.
- **Payments need reconciliation:** package prices and idempotent payment settlement must match the current backend and the approved 500-coin package price of 25,000 toman before any live payment route is enabled.

### Deployment guard

The automatic push-triggered Cloudflare deployment and automatic remote D1 migration were disabled on this branch. Preview deployment is now manual-only. Do not run D1 migrations against a live account database and do not change Flutter API/WSS URLs until the blockers above are closed and a restorable backup plus end-to-end compatibility tests are verified.
