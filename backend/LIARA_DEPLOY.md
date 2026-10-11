# Deploy Mafia Radical backend to Liara

This repository contains a Flutter app and a separate starter Node.js backend in `backend/`.
The root `package.json` is the Node.js deployment entry point for platforms that build from the repository root.

## Liara settings
- App type: Node.js
- Branch: `deploy/liara-node-backend`
- Node.js: 20 or newer
- Start command: `npm start` (if the panel asks for a start command)
- Health check path: `/health` (if configurable)
- Port: use the platform-provided `PORT`; the server reads `process.env.PORT`.

After deployment, open `https://YOUR-APP-DOMAIN/health`. A successful response should be JSON with `"status":"ok"`.
The WebSocket endpoint uses the same host with `wss://YOUR-APP-DOMAIN` on HTTPS deployments.

## Important limitations
This is a starter backend, not a production-ready online Mafia game. Lobby state is kept in memory and disappears when the process restarts. Authentication, persistent database storage, wallet/purchase integrity, authoritative game phases/roles/voting, rate limiting, and production integration tests are not implemented. Do not use it to store real user balances or launch public competitive matches yet.

The Flutter app has separate lobby/game socket clients and must be explicitly configured and tested against the deployed URL before the app is connected. The current starter server does not implement the full game protocol; game actions return an error rather than running an actual match.
