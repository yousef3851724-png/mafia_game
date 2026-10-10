# Mafia Radical — UI integration requirements and implementation status

This document consolidates the previously requested screens and the moderation/locked-lobby work into the existing Flutter + Node/PostgreSQL project. It is a delivery checklist, not a claim that every item is complete.

## Authentication — implemented on this branch, not yet validated
- Persian RTL login and registration screen using the existing RadicalTheme and logo.
- Calls the existing backend endpoints `POST /api/v1/auth/login` and `POST /api/v1/auth/register`.
- Stores the returned access token and player ID in SharedPreferences.
- Does not silently simulate a successful login. The app must be built with `--dart-define=API_BASE_URL=https://YOUR_API_HOST`.
- First launch proceeds through onboarding, then authentication. Returning players with a locally stored token currently proceed to Home; server-side token/session revalidation and logout/session expiry handling remain required before production.

## Existing game UI must be preserved
- Do not replace the current app, lobby, scenarios, game flow, shop, avatars, frames, wallet, or assets with placeholders.
- Keep the existing RadicalTheme and logo consistent across splash, onboarding, authentication, Home, lobby, avatar selection, frame shop, and management pages.
- Avoid a gold-heavy visual treatment; use noir/charcoal surfaces, restrained metallic accents, and the existing theme tokens.
- Keep the avatar/profile area near the top-right of the lobby experience, and retain a dedicated live-stream area where the game design calls for it.
- Complete and connect the actual lobby list, create/join flows, lobby room, settings, player readiness, and game transition. A page that only looks clickable but does not call working functionality is not complete.
- Preserve coin/diamond pricing rules: ordinary items use coins, Legendary items use diamonds, and displayed prices, balance checks, and server-side deductions must agree.

## Creator/admin/supervisor management
- Creator-only web management panel: search for an existing verified account, assign/revoke admin or supervisor roles, and configure explicit permissions. Typing an email alone must never grant a role.
- Admin actions must be constrained by server-checked permissions. Admins can issue bans for 1–30 days where authorized, and suspend/revoke supervisor access only with the specific permission.
- Supervisors can issue only 1-, 3-, or 7-day bans with a recorded violation reason. Supervisors cannot grant roles or IP-ban users.
- Only the creator may IP-ban/unban. Warn about shared IPs and avoid treating IP alone as reliable identity.
- All sensitive actions must produce append-only audit events, including actor, target, time, action, reason, result, and relevant evidence references.
- Never expose private roles, secret game roles, or unrelated locked-lobby details to clients without authorization. Enforce this in backend responses, not just hidden UI controls.

## Locked-lobby monitoring, recordings, and AI review
- Creator-authorized view of locked-lobby state: members, phase, timestamps, and event timeline.
- Full-duration in-lobby audio recording is a separate media feature and is not active merely because database tables exist. It requires clear notice and required consent, media transport/SFU, private encrypted object storage, short-lived access links, access logs, retention/deletion jobs, and a creator review interface.
- No hidden microphone capture outside the lobby. Admins/supervisors do not receive recording access by default.
- AI can flag suspected abuse and send the creator evidence-based alerts; it must not permanently revoke privileges on its own. Human review is required because false positives are possible.
- Real-time audio censoring requires a delayed media buffer and moderation pipeline; it cannot be promised by a basic WebSocket game server alone.

## Release gate
Do not merge this work into `main` or describe the full feature set as complete until:
1. Flutter format/analyze/tests and Android build pass.
2. Backend syntax/tests and authorization tests pass.
3. PostgreSQL migrations run successfully against a test database.
4. Login/register are tested against a configured server; expired/invalid sessions are rejected.
5. Role escalation, ban limits, audit immutability, and unauthorized recording access have negative tests.
6. Lobby and game flows are tested with multiple real Android devices.
7. Recording consent, private storage, retention, and review access are implemented and tested before enabling audio capture.
