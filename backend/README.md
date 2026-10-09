# Mafia Radical Node.js backend

This is a **playable in-memory backend MVP**, not production-ready infrastructure.

## Included
- HTTP health endpoint: `/health`
- WebSocket lobby: join/reconnect by player ID, ready state, seat changes, chat, host kick
- Server-side start validation and randomized roles (mafia, citizen, doctor, detective)
- Timed night/day/voting/result phases, night actions, doctor protection, detective result, voting, elimination, and win checks
- Payload size limit and a basic per-connection message rate limit
- Basic automated HTTP health smoke test

## Run locally
Requires Node.js 20 or newer.

```sh
npm install
npm run check
npm test
npm start
```

Health endpoint: `http://localhost:8080/health`. The server listens on `PORT` supplied by the hosting platform.

## Flutter protocol
The server accepts the existing `join` and `game_join` messages and emits `players`, `game_state`, `phase_changed`, `eliminated`-compatible state updates, `chat`, `error`, and `investigation_result` events. The Flutter endpoint constants and mock-mode configuration still need to be deliberately switched after deployment and end-to-end testing.

## AI foundation (phase 1)

The `backend/ai/` folder contains an initial, deterministic foundation now connected to the Node.js WebSocket server:
- `strategy.js`: role-aware night target and vote selection helpers with easy/normal/hard difficulty inputs; host can request bots with a WebSocket `add_ai` message while in the lobby, and bots act during night/voting phases
- `moderation.js`: a small Persian chat filter baseline
- `assistant.js`: fixed FAQ answers for rules, roles, wallet safety, and reporting, requested with an `assistant` message carrying `question`
- `ai.test.js`: unit tests for these helpers

**Important:** this is an early integration, not a connected generative AI model. Bot behavior is simple and can be predictable; the moderation patterns are only a basic baseline. The current Flutter UI does not yet expose add-bot or assistant controls, and no AI provider API key is required. The AI player protocol and exact game rules still need end-to-end validation.

## Required before public launch
- **Authentication is not implemented.** Client-supplied player IDs are not secure identities; do not treat this service as protected against impersonation or cheating.
- Rooms, sessions, and game state exist only in memory and are lost on restart. Multiple app instances will not share state.
- No database, account system, durable coins/diamonds, purchases, inventory, rankings, or moderation is implemented.
- Role counts and phase timing are MVP defaults and must be verified against Mafia Radical's intended rules before launch.
- Reconnect recovery is limited; this is not a substitute for durable sessions or secure authentication.
- The included automated test is a smoke test, not comprehensive game, security, or load testing.
- Do not use this MVP for real-money purchases, paid diamonds, or valuable account state.

Deploy to a staging app first, run the health and WebSocket tests, then verify the complete Flutter flow with multiple real devices before any public release.
