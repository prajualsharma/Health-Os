-- Split identity into consumer (NutriKit) and staff (Kitchen + Gym) pools.

CREATE SCHEMA IF NOT EXISTS consumer;
CREATE SCHEMA IF NOT EXISTS staff;

-- ---------------------------------------------------------------- consumer
CREATE TABLE IF NOT EXISTS consumer.consumer_accounts (
  id uuid PRIMARY KEY,
  first_name varchar(80) NOT NULL,
  last_name varchar(80),
  email varchar(255),
  phone varchar(32),
  password_hash varchar(255),
  status varchar(32) NOT NULL,
  created_at timestamptz NOT NULL,
  updated_at timestamptz NOT NULL
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_consumer_accounts_email
  ON consumer.consumer_accounts(email) WHERE email IS NOT NULL;
CREATE UNIQUE INDEX IF NOT EXISTS ux_consumer_accounts_phone
  ON consumer.consumer_accounts(phone) WHERE phone IS NOT NULL;

CREATE TABLE IF NOT EXISTS consumer.user_profiles (
  account_id uuid PRIMARY KEY REFERENCES consumer.consumer_accounts(id) ON DELETE CASCADE,
  height_cm int,
  weight_kg int,
  gender varchar(16),
  date_of_birth date,
  goal varchar(128),
  target_weight_kg int,
  activity_level varchar(32),
  diet_type varchar(32),
  allergies text,
  calorie_target int,
  protein_target_g int,
  carb_target_g int,
  fat_target_g int,
  goals text,
  medical_conditions text,
  city varchar(128),
  goal_pace varchar(32),
  preferred_height_unit varchar(8) DEFAULT 'cm',
  preferred_weight_unit varchar(8) DEFAULT 'kg',
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS consumer.auth_methods (
  id uuid PRIMARY KEY,
  account_id uuid NOT NULL REFERENCES consumer.consumer_accounts(id) ON DELETE CASCADE,
  method varchar(16) NOT NULL,
  identifier varchar(255) NOT NULL,
  verified boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (method, identifier)
);
CREATE INDEX IF NOT EXISTS idx_consumer_auth_methods_account ON consumer.auth_methods(account_id);

CREATE TABLE IF NOT EXISTS consumer.refresh_tokens (
  id uuid PRIMARY KEY,
  account_id uuid NOT NULL REFERENCES consumer.consumer_accounts(id) ON DELETE CASCADE,
  token_hash varchar(128) NOT NULL UNIQUE,
  expires_at timestamptz NOT NULL,
  revoked_at timestamptz,
  created_at timestamptz NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_consumer_refresh_account ON consumer.refresh_tokens(account_id);

CREATE TABLE IF NOT EXISTS consumer.password_reset_tokens (
  id uuid PRIMARY KEY,
  account_id uuid NOT NULL REFERENCES consumer.consumer_accounts(id) ON DELETE CASCADE,
  token_hash varchar(128) NOT NULL UNIQUE,
  expires_at timestamptz NOT NULL,
  used_at timestamptz,
  created_at timestamptz NOT NULL
);

-- ---------------------------------------------------------------- staff
CREATE TABLE IF NOT EXISTS staff.staff_accounts (
  id uuid PRIMARY KEY,
  first_name varchar(80) NOT NULL,
  last_name varchar(80),
  email varchar(255),
  phone varchar(32),
  password_hash varchar(255),
  status varchar(32) NOT NULL,
  created_at timestamptz NOT NULL,
  updated_at timestamptz NOT NULL
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_staff_accounts_email
  ON staff.staff_accounts(email) WHERE email IS NOT NULL;
CREATE UNIQUE INDEX IF NOT EXISTS ux_staff_accounts_phone
  ON staff.staff_accounts(phone) WHERE phone IS NOT NULL;

CREATE TABLE IF NOT EXISTS staff.staff_roles (
  account_id uuid NOT NULL REFERENCES staff.staff_accounts(id) ON DELETE CASCADE,
  role_id uuid NOT NULL REFERENCES roles(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (account_id, role_id)
);

CREATE TABLE IF NOT EXISTS staff.scoped_memberships (
  id uuid PRIMARY KEY,
  account_id uuid NOT NULL REFERENCES staff.staff_accounts(id) ON DELETE CASCADE,
  portal_type varchar(32) NOT NULL,
  scope_type varchar(32) NOT NULL,
  scope_id uuid NOT NULL,
  role_name varchar(64) NOT NULL,
  status varchar(32) NOT NULL DEFAULT 'ACTIVE',
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT uq_staff_scoped_membership UNIQUE (account_id, portal_type, scope_type, scope_id, role_name)
);

CREATE INDEX IF NOT EXISTS idx_staff_scoped_memberships_account ON staff.scoped_memberships(account_id);
CREATE INDEX IF NOT EXISTS idx_staff_scoped_memberships_scope ON staff.scoped_memberships(scope_type, scope_id);

CREATE TABLE IF NOT EXISTS staff.auth_methods (
  id uuid PRIMARY KEY,
  account_id uuid NOT NULL REFERENCES staff.staff_accounts(id) ON DELETE CASCADE,
  method varchar(16) NOT NULL,
  identifier varchar(255) NOT NULL,
  verified boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (method, identifier)
);
CREATE INDEX IF NOT EXISTS idx_staff_auth_methods_account ON staff.auth_methods(account_id);

CREATE TABLE IF NOT EXISTS staff.refresh_tokens (
  id uuid PRIMARY KEY,
  account_id uuid NOT NULL REFERENCES staff.staff_accounts(id) ON DELETE CASCADE,
  token_hash varchar(128) NOT NULL UNIQUE,
  expires_at timestamptz NOT NULL,
  revoked_at timestamptz,
  created_at timestamptz NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_staff_refresh_account ON staff.refresh_tokens(account_id);

CREATE TABLE IF NOT EXISTS consumer.identity_links (
  id uuid PRIMARY KEY,
  consumer_id uuid NOT NULL REFERENCES consumer.consumer_accounts(id) ON DELETE CASCADE,
  staff_id uuid NOT NULL REFERENCES staff.staff_accounts(id) ON DELETE CASCADE,
  phone varchar(32) NOT NULL,
  linked_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (consumer_id, staff_id)
);

-- ---------------------------------------------------------------- migrate consumer pool
INSERT INTO consumer.consumer_accounts (id, first_name, last_name, email, phone, password_hash, status, created_at, updated_at)
SELECT u.id, u.first_name, u.last_name, u.email, u.phone, u.password_hash, u.status, u.created_at, u.updated_at
FROM users u
WHERE EXISTS (SELECT 1 FROM user_profiles p WHERE p.user_id = u.id)
  AND NOT EXISTS (SELECT 1 FROM scoped_memberships sm WHERE sm.user_id = u.id)
ON CONFLICT (id) DO NOTHING;

INSERT INTO consumer.user_profiles (
  account_id, height_cm, weight_kg, gender, date_of_birth, goal, target_weight_kg,
  activity_level, diet_type, allergies, calorie_target, protein_target_g, carb_target_g, fat_target_g,
  goals, medical_conditions, city, goal_pace, preferred_height_unit, preferred_weight_unit, updated_at
)
SELECT
  p.user_id, p.height_cm, p.weight_kg, p.gender, p.date_of_birth, p.goal, p.target_weight_kg,
  p.activity_level, p.diet_type, p.allergies, p.calorie_target, p.protein_target_g, p.carb_target_g, p.fat_target_g,
  p.goals, p.medical_conditions, p.city, p.goal_pace, p.preferred_height_unit, p.preferred_weight_unit, p.updated_at
FROM user_profiles p
WHERE EXISTS (SELECT 1 FROM consumer.consumer_accounts c WHERE c.id = p.user_id)
ON CONFLICT (account_id) DO NOTHING;

INSERT INTO consumer.auth_methods (id, account_id, method, identifier, verified, created_at)
SELECT am.id, am.user_id, am.method, am.identifier, am.verified, am.created_at
FROM auth_methods am
WHERE EXISTS (SELECT 1 FROM consumer.consumer_accounts c WHERE c.id = am.user_id)
ON CONFLICT (method, identifier) DO NOTHING;

INSERT INTO consumer.refresh_tokens (id, account_id, token_hash, expires_at, revoked_at, created_at)
SELECT rt.id, rt.user_id, rt.token_hash, rt.expires_at, rt.revoked_at, rt.created_at
FROM refresh_tokens rt
WHERE EXISTS (SELECT 1 FROM consumer.consumer_accounts c WHERE c.id = rt.user_id)
ON CONFLICT (token_hash) DO NOTHING;

-- ---------------------------------------------------------------- migrate staff pool
INSERT INTO staff.staff_accounts (id, first_name, last_name, email, phone, password_hash, status, created_at, updated_at)
SELECT u.id, u.first_name, u.last_name, u.email, u.phone, u.password_hash, u.status, u.created_at, u.updated_at
FROM users u
WHERE EXISTS (SELECT 1 FROM scoped_memberships sm WHERE sm.user_id = u.id)
   OR EXISTS (
     SELECT 1 FROM user_roles ur
     JOIN roles r ON r.id = ur.role_id
     WHERE ur.user_id = u.id AND r.name NOT IN ('MEMBER')
   )
ON CONFLICT (id) DO NOTHING;

INSERT INTO staff.scoped_memberships (id, account_id, portal_type, scope_type, scope_id, role_name, status, created_at)
SELECT sm.id, sm.user_id, sm.portal_type, sm.scope_type, sm.scope_id, sm.role_name, sm.status, sm.created_at
FROM scoped_memberships sm
WHERE EXISTS (SELECT 1 FROM staff.staff_accounts sa WHERE sa.id = sm.user_id)
ON CONFLICT (id) DO NOTHING;

INSERT INTO staff.staff_roles (account_id, role_id, created_at)
SELECT ur.user_id, ur.role_id, ur.created_at
FROM user_roles ur
WHERE EXISTS (SELECT 1 FROM staff.staff_accounts sa WHERE sa.id = ur.user_id)
  AND EXISTS (SELECT 1 FROM roles r WHERE r.id = ur.role_id AND r.name NOT IN ('MEMBER'))
ON CONFLICT DO NOTHING;

INSERT INTO staff.auth_methods (id, account_id, method, identifier, verified, created_at)
SELECT am.id, am.user_id, am.method, am.identifier, am.verified, am.created_at
FROM auth_methods am
WHERE EXISTS (SELECT 1 FROM staff.staff_accounts sa WHERE sa.id = am.user_id)
  AND NOT EXISTS (SELECT 1 FROM consumer.auth_methods cam WHERE cam.method = am.method AND cam.identifier = am.identifier)
ON CONFLICT (method, identifier) DO NOTHING;

INSERT INTO staff.refresh_tokens (id, account_id, token_hash, expires_at, revoked_at, created_at)
SELECT rt.id, rt.user_id, rt.token_hash, rt.expires_at, rt.revoked_at, rt.created_at
FROM refresh_tokens rt
WHERE EXISTS (SELECT 1 FROM staff.staff_accounts sa WHERE sa.id = rt.user_id)
  AND NOT EXISTS (SELECT 1 FROM consumer.refresh_tokens crt WHERE crt.token_hash = rt.token_hash)
ON CONFLICT (token_hash) DO NOTHING;

INSERT INTO consumer.identity_links (id, consumer_id, staff_id, phone)
SELECT gen_random_uuid(), c.id, s.id, COALESCE(c.phone, s.phone)
FROM consumer.consumer_accounts c
JOIN staff.staff_accounts s ON c.phone IS NOT NULL AND c.phone = s.phone
ON CONFLICT (consumer_id, staff_id) DO NOTHING;
