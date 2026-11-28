-- Mafia Radical moderation, consent, audit, and recording metadata foundation.
-- Audio bytes belong in private object storage, never in PostgreSQL rows.
-- Access must be enforced by authenticated backend handlers, not client UI alone.

CREATE TABLE IF NOT EXISTS moderation_role_assignments (
  id BIGSERIAL PRIMARY KEY,
  player_id UUID NOT NULL REFERENCES players(id) ON DELETE RESTRICT,
  role VARCHAR(16) NOT NULL CHECK (role IN ('creator', 'admin', 'supervisor')),
  granted_by UUID REFERENCES players(id) ON DELETE RESTRICT,
  permissions JSONB NOT NULL DEFAULT '[]'::jsonb,
  granted_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  expires_at TIMESTAMPTZ,
  revoked_at TIMESTAMPTZ,
  revoked_by UUID REFERENCES players(id) ON DELETE RESTRICT,
  revoke_reason TEXT,
  CHECK (expires_at IS NULL OR expires_at > granted_at)
);
CREATE INDEX IF NOT EXISTS idx_moderation_roles_player_active
  ON moderation_role_assignments(player_id, role) WHERE revoked_at IS NULL;

CREATE TABLE IF NOT EXISTS moderation_actions (
  id UUID PRIMARY KEY,
  room_id UUID REFERENCES game_rooms(id) ON DELETE SET NULL,
  target_player_id UUID REFERENCES players(id) ON DELETE SET NULL,
  actor_player_id UUID REFERENCES players(id) ON DELETE SET NULL,
  actor_role VARCHAR(16) NOT NULL CHECK (actor_role IN ('creator', 'admin', 'supervisor', 'system')),
  action_type VARCHAR(32) NOT NULL CHECK (action_type IN (
    'ban', 'unban', 'ip_ban', 'ip_unban', 'role_grant', 'role_revoke',
    'role_suspend', 'role_restore', 'warning', 'recording_access'
  )),
  reason TEXT NOT NULL CHECK (length(trim(reason)) BETWEEN 3 AND 2000),
  starts_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  ends_at TIMESTAMPTZ,
  metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CHECK (ends_at IS NULL OR ends_at > starts_at)
);
CREATE INDEX IF NOT EXISTS idx_moderation_actions_target_time
  ON moderation_actions(target_player_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_moderation_actions_room_time
  ON moderation_actions(room_id, created_at DESC);

CREATE TABLE IF NOT EXISTS moderation_audit_log (
  id BIGSERIAL PRIMARY KEY,
  actor_player_id UUID REFERENCES players(id) ON DELETE SET NULL,
  actor_role VARCHAR(16) NOT NULL CHECK (actor_role IN ('creator', 'admin', 'supervisor', 'system')),
  event_type VARCHAR(64) NOT NULL,
  target_player_id UUID REFERENCES players(id) ON DELETE SET NULL,
  room_id UUID REFERENCES game_rooms(id) ON DELETE SET NULL,
  reason TEXT,
  evidence JSONB NOT NULL DEFAULT '{}'::jsonb,
  request_id UUID,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_moderation_audit_time ON moderation_audit_log(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_moderation_audit_actor_time ON moderation_audit_log(actor_player_id, created_at DESC);

-- Prevent routine application credentials from editing/deleting audit history.
CREATE OR REPLACE FUNCTION reject_moderation_audit_mutation()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  RAISE EXCEPTION 'moderation audit log is append-only';
END;
$$;
DROP TRIGGER IF EXISTS moderation_audit_no_update ON moderation_audit_log;
CREATE TRIGGER moderation_audit_no_update
  BEFORE UPDATE OR DELETE ON moderation_audit_log
  FOR EACH ROW EXECUTE FUNCTION reject_moderation_audit_mutation();

CREATE TABLE IF NOT EXISTS lobby_recording_consents (
  room_id UUID NOT NULL REFERENCES game_rooms(id) ON DELETE CASCADE,
  player_id UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
  policy_version VARCHAR(32) NOT NULL,
  consented_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  withdrawn_at TIMESTAMPTZ,
  PRIMARY KEY (room_id, player_id, policy_version)
);

CREATE TABLE IF NOT EXISTS lobby_recordings (
  id UUID PRIMARY KEY,
  room_id UUID NOT NULL REFERENCES game_rooms(id) ON DELETE RESTRICT,
  recording_kind VARCHAR(16) NOT NULL CHECK (recording_kind IN ('audio', 'event_timeline')),
  storage_provider VARCHAR(32) NOT NULL,
  storage_key TEXT NOT NULL UNIQUE,
  started_at TIMESTAMPTZ NOT NULL,
  ended_at TIMESTAMPTZ,
  duration_seconds INTEGER CHECK (duration_seconds IS NULL OR duration_seconds >= 0),
  bytes BIGINT CHECK (bytes IS NULL OR bytes >= 0),
  sha256_hex CHAR(64),
  consent_policy_version VARCHAR(32) NOT NULL,
  retention_until TIMESTAMPTZ NOT NULL,
  status VARCHAR(16) NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending', 'ready', 'quarantined', 'deleted', 'failed')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CHECK (ended_at IS NULL OR ended_at >= started_at)
);
CREATE INDEX IF NOT EXISTS idx_lobby_recordings_room_time
  ON lobby_recordings(room_id, started_at DESC);
CREATE INDEX IF NOT EXISTS idx_lobby_recordings_retention
  ON lobby_recordings(retention_until) WHERE status IN ('ready', 'quarantined');

CREATE TABLE IF NOT EXISTS moderation_ai_alerts (
  id UUID PRIMARY KEY,
  room_id UUID REFERENCES game_rooms(id) ON DELETE SET NULL,
  recording_id UUID REFERENCES lobby_recordings(id) ON DELETE SET NULL,
  subject_player_id UUID REFERENCES players(id) ON DELETE SET NULL,
  alert_type VARCHAR(40) NOT NULL,
  confidence NUMERIC(5,4) CHECK (confidence IS NULL OR confidence BETWEEN 0 AND 1),
  occurred_at TIMESTAMPTZ NOT NULL,
  evidence JSONB NOT NULL DEFAULT '{}'::jsonb,
  status VARCHAR(16) NOT NULL DEFAULT 'open'
    CHECK (status IN ('open', 'reviewing', 'confirmed', 'dismissed', 'resolved')),
  reviewed_by UUID REFERENCES players(id) ON DELETE SET NULL,
  reviewed_at TIMESTAMPTZ,
  review_note TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_ai_alerts_open_time
  ON moderation_ai_alerts(status, created_at DESC);

CREATE TABLE IF NOT EXISTS recording_access_log (
  id BIGSERIAL PRIMARY KEY,
  recording_id UUID NOT NULL REFERENCES lobby_recordings(id) ON DELETE RESTRICT,
  viewer_player_id UUID REFERENCES players(id) ON DELETE SET NULL,
  viewer_role VARCHAR(16) NOT NULL CHECK (viewer_role IN ('creator', 'admin', 'supervisor', 'system')),
  access_reason TEXT NOT NULL CHECK (length(trim(access_reason)) BETWEEN 3 AND 1000),
  accessed_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_recording_access_recording_time
  ON recording_access_log(recording_id, accessed_at DESC);
