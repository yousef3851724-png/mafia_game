# Mafia Radical Node.js backend starter

This directory is a **starter implementation**, not a production-ready game backend.

## Included
- HTTP health endpoint at `/health`
- WebSocket connection on the same server
- In-memory lobby membership, ready state, seat changes, chat, host kick, and start-request validation
- Configurable port and room size

## Run locally
Requires Node.js 20 or newer.

```sh
npm install
npm run check
npm start
```

Open `http://localhost:8080/health` to verify the process.

## Liara
Deploy the **backend directory** as a Node.js app and configure the platform to route to the port provided by `PORT` (the default is 8080). After deployment, test the health endpoint before changing the Flutter app's endpoint constants.

## Important limitations before public launch
- Rooms and players are stored in memory and disappear when the process restarts.
- There is no authentication or token verification yet. The client-supplied player ID is not a secure identity.
- No database, persistent wallet, purchases, inventory, ranking, or moderation is implemented.
- The start event is only a request; the authoritative Mafia game engine, secret role assignment, night actions, voting, timers, reconnect recovery, rate limiting, and abuse protection must be implemented and tested before real users play.
- Do not use this starter to handle real money, paid diamonds, or valuable account state.
- The Flutter app currently uses placeholder WebSocket URLs and mock mode in its lobby provider. Switch it only after the deployed backend is tested and the message protocol is aligned.
