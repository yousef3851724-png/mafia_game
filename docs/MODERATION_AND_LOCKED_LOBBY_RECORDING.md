# Mafia Radical — Moderation, Locked-Lobby Monitoring, and Audio Records

**Status: design + database foundation only. This document does not claim that recording, speech recognition, AI moderation, or the admin website is already running.**

## Product requirements

### 1. Roles and server-side permissions

All authorization must be checked by the backend for every HTTP request, WebSocket event, recording read, and moderation action. Hiding a button in Flutter is not a security boundary. A role assignment must refer to an authenticated account; typing an email address alone never grants a role. The account/email must be verified, and the creator must confirm the assignment from the creator control panel.

- **Creator (owner):** can grant/revoke roles, set explicit permissions, review moderation and AI alerts, view locked-lobby state/event timelines, access recordings for a documented moderation purpose, and manage IP bans. The creator account must be provisioned securely; it must never be selected by a public registration field.
- **Admin:** can issue user bans up to 30 days; may suspend a supervisor role and may revoke it only when the explicit `supervisor.role.revoke` permission is granted. Admins cannot grant themselves permissions or manage creator accounts. All such actions require a reason and immutable audit entry.
- **Supervisor:** may issue only 1-day, 3-day, or 7-day user bans for a documented violation. A supervisor has no IP-ban permission and cannot grant/revoke/suspend admin or supervisor roles. Access to recordings and live audio is not implied by being a supervisor.
- **IP bans/unbans:** creator-only, with a reason, expiry/review, and audit entry. IPs can be shared by households, mobile networks, schools, VPNs, and workplaces; the UI must warn of collateral impact and the system should prefer account-level enforcement when sufficient.
- **Least privilege:** permissions are explicit and revocable, expire when configured, and are checked server-side. A suspended/revoked assignment must take effect on the next request and on existing WebSocket sessions.

Suggested permission identifiers include `roles.assign`, `roles.revoke`, `supervisor.role.suspend`, `supervisor.role.revoke`, `moderation.ban.1d`, `moderation.ban.3d`, `moderation.ban.7d`, `moderation.ban.30d`, `moderation.ip_ban`, `lobby.state.view_locked`, `recording.review`, and `recording.audio.review`. The database JSON field stores grants; the backend must implement a central policy check and must not trust permission values supplied by a client.

### 2. Locked-lobby visibility and recording

- The creator's control panel can inspect locked-lobby game state, participant list, phase, and event timeline. In this game, “visual view” means game/lobby state unless a separate real-time video feature is explicitly built.
- Record the **entire voice session** for locked lobbies, from start to end, only after every participant has received a clear notice and the required consent has been recorded for the active policy version. Do not record device microphone audio outside the lobby session.
- Show a persistent recording indicator and explain who can access recordings, the purpose, retention duration, and how to report misuse. If consent is absent or withdrawn, do not start/continue audio recording; provide a clear lobby policy for whether the session must end or switch to a non-recorded mode.
- Store audio objects in private object storage, not as database blobs or public URLs. Keep only storage key, duration, checksum, timestamps, status, and retention metadata in PostgreSQL. Use encryption in transit and at rest, short-lived signed access, strict creator permissions, and access logs. Never place audio bytes or secrets in application logs.
- Define a retention period before enabling recording. The database schema requires `retention_until`; a scheduled, tested deletion worker must delete the object and then mark metadata appropriately. Legal holds for a specific reported incident need a reason, authorized reviewer, and expiry/review date. Do not keep every recording forever by default.
- Creator can review the recording when a moderation concern is raised or for an explicitly authorized review. Every access must be logged with the viewer, role, timestamp, recording, and reason. No hidden/secret listening and no microphone access outside a lobby.

### 3. AI monitoring and escalation

AI may analyze consented lobby audio and server-side event history for possible insults, threats, role-information leakage, suspicious moderation patterns, and abuse of authority. Each alert must contain timestamp, room, type, confidence when available, and limited evidence references.

- AI alerts the creator promptly; it must not permanently revoke an admin/supervisor or decide guilt by itself.
- Examples to flag: repeated supervisor bans without meaningful reasons; an admin suspending a supervisor without a recorded reason; repeated access to recordings unrelated to an incident; attempts to access another lobby category; and a possible disclosure of hidden roles.
- Creator reviews the evidence and records a decision. Dismissed alerts remain auditable. The subject of a report must not be able to delete or alter the relevant audit trail.
- AI classification can be wrong. Provide a review/appeal path, avoid exposing unnecessary private speech in alert previews, and never treat model confidence as proof by itself.

### 4. Preventing secret-role leaks

Role secrecy must be enforced by the authoritative game server before data is sent to clients. Send each player only the information their role is allowed to see. Do not broadcast hidden roles, night actions, private messages, or moderator-only state to all clients and hope that AI will catch it afterward. AI is a secondary detector, not the primary access-control mechanism.

Access to a lobby category must be checked server-side for every state request, event subscription, and recording. A supervisor assigned to a points lobby must not automatically gain access to friendly lobbies, night audio, or moderator-only channels.

### 5. Voice profanity filtering

A real-time beep/mute filter needs a speech-to-text or audio-classification pipeline and a short rolling audio buffer so that the offending segment can be detected before it reaches listeners. It needs measured latency, language coverage, false-positive handling, and a clear way to report mistakes. If the media server cannot guarantee the filter timing, do not promise that every insult will be muted before playback. Filtering and recording are separate policies: any recording must still follow the consent and retention rules above.

### 6. Audit and abuse prevention

The migration creates append-only audit rows for moderation history, plus role assignments, recording consent, recording metadata, AI alerts, and recording access logs. The application must use a least-privilege database account and must not expose update/delete operations for audit history. The trigger is defense-in-depth, not protection against a database owner or privileged operator changing the schema; ship audit exports/alerts to a separately controlled destination before claiming tamper-proof logging.

All moderation endpoints must validate action duration, target, room membership, role, permission, and reason on the server inside a transaction where applicable. Rate-limit sensitive operations and prevent the same actor from approving their own role escalation or silently erasing evidence.

## Database migration

`002_moderation_recording.sql` adds:
- role assignment records with explicit permissions and revocation/suspension metadata;
- moderation actions and append-only audit events;
- per-player/per-room recording consent;
- private audio/event recording metadata and retention deadlines;
- AI moderation alerts and review outcomes;
- recording access audit entries.

It does **not** yet implement the HTTP/WebSocket endpoints, role policy middleware, creator web panel, media server, audio upload/storage, speech recognition, beep filter, scheduled retention deletion, alert delivery, or Flutter integration. Those require code, deployment configuration, private storage, and integration tests.

## Required implementation sequence

1. Add centralized backend authorization and tests for every role/permission boundary.
2. Add verified account/email support and a creator-only bootstrap procedure; never hard-code a creator identity into a public API.
3. Add moderation APIs, transactions, immutable audit writes, expiry handling, and abuse tests.
4. Deploy an authenticated WebRTC media/SFU service and private object storage; implement consent gating, continuous recording, encryption, access logging, and retention deletion.
5. Build the creator web panel for role grants, locked-lobby state/event timeline, alert review, and justified recording access.
6. Add AI transcription/classification and alert delivery with human review; evaluate Persian speech accuracy and false positives.
7. Integrate Flutter lobby authentication/protocol, show recording notice/indicator, and run end-to-end tests on multiple Android devices.
8. Do not call this production-ready until migration, API authorization, consent, recording, retention, privacy, and end-to-end tests all pass.

## Acceptance criteria

- A supervisor cannot issue a ban longer than 7 days or access a locked-lobby recording by default.
- An admin cannot IP-ban, self-escalate, or revoke a supervisor without the explicit permission.
- Only the creator can issue/revoke IP bans.
- Every moderation action and recording access creates an auditable event.
- No locked-lobby audio is recorded before the notice/consent gate succeeds.
- No player receives another player's hidden role through state snapshots or WebSocket broadcasts.
- Recording objects are private, encrypted, expire according to retention policy, and are not publicly linkable.
- AI alerts lead to human review, not automatic permanent punishment.


## Implemented moderation API foundation (branch only)

The backend now mounts authenticated endpoints under `/api/v1/moderation`:
- `GET /roles` — requires `roles.read`.
- `POST /roles` — creator-only role grants; accepts only `admin` or `supervisor`, explicit permission list, expiry, and reason.
- `POST /roles/:assignmentId/revoke` — creator-only revocation; creator assignments cannot be revoked through this route.
- `POST /roles/:assignmentId/suspend` — creator/admin suspension of a supervisor assignment, up to 30 days.
- `POST /bans` — enforces supervisor durations of 1/3/7 days and admin/creator durations of 1–30 days, subject to explicit `moderation.ban` permission for non-creators.
- `GET /audit` — requires `audit.read`.

Role grants require an existing player UUID; an email or client-provided role alone never grants authority. Creator status must be established out-of-band by a trusted database operator after verifying the account. Example template (replace the UUID only after independently verifying it; never expose this as a public API):

```sql
INSERT INTO moderation_role_assignments (player_id, role, permissions)
SELECT id, 'creator', '[]'::jsonb
FROM players
WHERE id = 'REPLACE-WITH-VERIFIED-PLAYER-UUID'
  AND NOT EXISTS (
    SELECT 1 FROM moderation_role_assignments
    WHERE role = 'creator' AND revoked_at IS NULL
  );
```

This SQL is an operator procedure, not an automatic seed; it does not identify the account by email and does not run on application startup. Review and execute it manually only after confirming the correct player UUID.

The moderation routes and schema are not yet production-verified: PostgreSQL migrations and integration tests have not been run in a connected test environment. Ban records are currently persisted, but login/session enforcement and IP-ban enforcement still need to be wired into authentication/request handling. Audio capture, consent UI, private object storage, retention jobs, creator web panel, AI alert pipeline, and Flutter integration remain unimplemented. Do not treat this branch as a production release.
