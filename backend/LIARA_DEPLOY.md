# Deploy Mafia Radical backend to Liara

The repository contains the Flutter app and a separate Node.js WebSocket backend in `backend/`. The root `package.json` starts `backend/server.js`.

## Liara settings
- App type: Node.js
- Branch: `feat/mafia-backend-completion` after the pull request is reviewed and merged
- Node.js: 20 or newer
- Build/install: `npm install`
- Start command: `npm start`
- Validation before deployment: `npm run check` and `npm test`
- Health check path: `/health`
- Port: use the platform-provided `PORT`; the server reads `process.env.PORT`

After deploying to a **staging app**, open the assigned domain with `/health`. A successful response should be JSON containing `"status":"ok"`. On an HTTPS deployment, WebSocket clients must use `wss://` on the same host.

## Before connecting Flutter
The backend now supports a playable, in-memory MVP protocol, but Flutter's endpoint constants and mock-mode settings have intentionally not been changed. First test lobby join, readiness, chat, start, private role assignment, night actions, voting, and win conditions with several clients. Then configure the Flutter URLs in a separate reviewed change.

## Important production gaps
This is not production-ready for public launch. Player IDs are client-supplied and there is no authentication, persistent database, multi-instance state sharing, account security, durable wallet/purchases, inventory, ranking, or moderation. Room/game state disappears on restart. Role counts and phase durations are MVP defaults and must be checked against the intended Mafia Radical rules. The included test is only an HTTP health smoke test, not a full integration, security, or load test. Do not use this version for real-money purchases or paid diamonds.
