# Mafia Radical backend

This service is intended to be the persistent online backend for the Flutter game. It uses PostgreSQL for player accounts, rooms, membership, and event history. It does not use mock players or an in-memory database.

## Requirements

- Node.js 22 or newer
- PostgreSQL 15 or newer
- A private, persistent PostgreSQL database in the deployment environment

## Local setup

1. Copy `.env.example` to `.env` and set `DATABASE_URL` and a randomly generated `JWT_SECRET` of at least 32 characters.
2. Create the PostgreSQL database and database user with least-privilege permissions.
3. Install dependencies with `npm ci` after committing the generated lockfile from the supported deployment environment, or run `npm install` to generate it.
4. Apply migrations using `npm run migrate`.
5. Start the service using `npm start`.

Never commit `.env`, database credentials, production JWT secrets, signing keys, or user data.

## API currently implemented

- `GET /health` — process/database health
- `POST /api/v1/auth/register` — creates a persistent account with an initial wallet (1000 coins, 10 diamonds)
- `POST /api/v1/auth/login` — password verification and signed access token
- `GET /api/v1/me` — authenticated player profile
- `GET /api/v1/rooms` — list waiting rooms
- `POST /api/v1/rooms` — create room
- `POST /api/v1/rooms/join` — join by room code
- `POST /api/v1/rooms/:code/ready` — set ready state
- `POST /api/v1/rooms/:code/start` — owner starts a game after readiness checks
- `GET /api/v1/rooms/:code/state` — private role and public game state for a room member
- WebSocket `/lobby?roomCode=XXXXXX&token=...` — authenticated room membership, player snapshots, ready updates, and persistent room chat

## Important integration status

The existing Flutter lobby/game socket clients use a placeholder URL and mock mode. They must be updated in a separate, reviewed Flutter change to use the deployed HTTPS/WSS origin and the token-based protocol. Do not point a release build at a local phone-only address.

This is a backend foundation, not a claim that all online Mafia gameplay is finished. Server-authoritative voting, night-action validation/resolution, phase timers, elimination, reconnection recovery, economy transactions, moderation, and end-to-end client integration still need to be completed before calling the online game production-ready. The game role-count policy also needs confirmation against the current in-app role distribution before release.

## Moderation and locked-lobby recording status

See [`docs/MODERATION_AND_LOCKED_LOBBY_RECORDING.md`](../docs/MODERATION_AND_LOCKED_LOBBY_RECORDING.md) for the role/permission policy, locked-lobby monitoring requirements, continuous audio recording and consent policy, AI alert workflow, privacy/retention requirements, and acceptance criteria. Migration `002_moderation_recording.sql` adds the database foundation for role assignments, moderation/audit records, consent, recording metadata, AI alerts, and recording access logs.

**Important:** these are schema and specification changes, not a deployed recording system. The current backend does not yet implement the moderation APIs, creator web panel, media/SFU pipeline, audio storage/upload, speech recognition, beep filtering, retention worker, or AI alert delivery. Do not advertise locked-lobby audio recording as active until those components are implemented and end-to-end tested. Audio recording must be gated by clear notice/consent and use private storage with a defined retention period.

## Tests

Run `npm test` for the pure game-rule tests and `npm run check` for a syntax check. Database integration tests require a disposable PostgreSQL test database and should be run before deployment.
