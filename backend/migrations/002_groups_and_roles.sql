CREATE TABLE IF NOT EXISTS player_global_roles (
  player_id UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
  role VARCHAR(24) NOT NULL CHECK (role IN ('moderator', 'admin', 'platform_creator')),
  granted_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  granted_by UUID REFERENCES players(id) ON DELETE SET NULL,
  PRIMARY KEY (player_id, role)
);

CREATE TABLE IF NOT EXISTS player_groups (
  id UUID PRIMARY KEY,
  name VARCHAR(64) NOT NULL,
  acronym VARCHAR(8) NOT NULL,
  description VARCHAR(280) NOT NULL DEFAULT '',
  visibility VARCHAR(16) NOT NULL DEFAULT 'public'
    CHECK (visibility IN ('public', 'private', 'approval')),
  creator_id UUID NOT NULL REFERENCES players(id),
  leader_id UUID REFERENCES players(id) ON DELETE SET NULL,
  official_verified BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CHECK (acronym ~ '^[A-Z0-9]{2,8}$')
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_player_groups_acronym_ci ON player_groups (UPPER(acronym));
CREATE INDEX IF NOT EXISTS idx_player_groups_visibility_created ON player_groups(visibility, created_at DESC);

CREATE TABLE IF NOT EXISTS player_group_members (
  group_id UUID NOT NULL REFERENCES player_groups(id) ON DELETE CASCADE,
  player_id UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
  role VARCHAR(16) NOT NULL DEFAULT 'member'
    CHECK (role IN ('member', 'manager', 'leader')),
  membership_status VARCHAR(16) NOT NULL DEFAULT 'active'
    CHECK (membership_status IN ('pending', 'active')),
  joined_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (group_id, player_id)
);

CREATE INDEX IF NOT EXISTS idx_player_group_members_player ON player_group_members(player_id, membership_status);
CREATE INDEX IF NOT EXISTS idx_player_group_members_group_role ON player_group_members(group_id, role);

CREATE TABLE IF NOT EXISTS player_group_audit (
  id BIGSERIAL PRIMARY KEY,
  group_id UUID REFERENCES player_groups(id) ON DELETE SET NULL,
  actor_id UUID REFERENCES players(id) ON DELETE SET NULL,
  target_id UUID REFERENCES players(id) ON DELETE SET NULL,
  action VARCHAR(40) NOT NULL,
  details JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_player_group_audit_group_created ON player_group_audit(group_id, created_at DESC);
