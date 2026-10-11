-- Operational moderation tables. IP bans are deliberately not exposed until request-time enforcement is wired in.
CREATE TABLE IF NOT EXISTS moderation_role_suspensions (
  id BIGSERIAL PRIMARY KEY,
  assignment_id BIGINT NOT NULL REFERENCES moderation_role_assignments(id) ON DELETE RESTRICT,
  suspended_by UUID NOT NULL REFERENCES players(id) ON DELETE RESTRICT,
  reason TEXT NOT NULL CHECK (length(trim(reason)) BETWEEN 3 AND 2000),
  starts_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  ends_at TIMESTAMPTZ NOT NULL,
  restored_at TIMESTAMPTZ,
  restored_by UUID REFERENCES players(id) ON DELETE RESTRICT,
  CHECK (ends_at > starts_at)
);
CREATE INDEX IF NOT EXISTS idx_role_suspensions_active
  ON moderation_role_suspensions(assignment_id, ends_at DESC)
  WHERE restored_at IS NULL;

CREATE TABLE IF NOT EXISTS player_bans (
  id UUID PRIMARY KEY,
  player_id UUID NOT NULL REFERENCES players(id) ON DELETE RESTRICT,
  issued_by UUID NOT NULL REFERENCES players(id) ON DELETE RESTRICT,
  reason TEXT NOT NULL CHECK (length(trim(reason)) BETWEEN 3 AND 2000),
  starts_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  ends_at TIMESTAMPTZ NOT NULL,
  revoked_at TIMESTAMPTZ,
  revoked_by UUID REFERENCES players(id) ON DELETE RESTRICT,
  revoke_reason TEXT,
  CHECK (ends_at > starts_at)
);
CREATE INDEX IF NOT EXISTS idx_player_bans_active
  ON player_bans(player_id, ends_at DESC) WHERE revoked_at IS NULL;
