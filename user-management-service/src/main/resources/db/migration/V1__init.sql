-- HealthOS User Management schema (PostgreSQL)

create table if not exists roles (
  id uuid primary key,
  name varchar(64) not null unique,
  description varchar(255),
  created_at timestamptz not null default now()
);

create table if not exists permissions (
  id uuid primary key,
  name varchar(128) not null unique,
  description varchar(255),
  created_at timestamptz not null default now()
);

create table if not exists role_permissions (
  role_id uuid not null references roles(id) on delete cascade,
  permission_id uuid not null references permissions(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (role_id, permission_id)
);

create table if not exists users (
  id uuid primary key,
  first_name varchar(80) not null,
  last_name varchar(80),
  email varchar(255) not null unique,
  phone varchar(32),
  password_hash varchar(255) not null,
  status varchar(32) not null,
  created_at timestamptz not null,
  updated_at timestamptz not null
);
create index if not exists idx_users_email on users(email);
create index if not exists idx_users_phone on users(phone);

create table if not exists user_roles (
  user_id uuid not null references users(id) on delete cascade,
  role_id uuid not null references roles(id) on delete restrict,
  created_at timestamptz not null default now(),
  primary key (user_id, role_id)
);

create table if not exists user_profiles (
  user_id uuid primary key references users(id) on delete cascade,
  height_cm int,
  weight_kg int,
  gender varchar(16),
  date_of_birth date,
  goal varchar(128),
  updated_at timestamptz not null default now()
);

create table if not exists refresh_tokens (
  id uuid primary key,
  user_id uuid not null references users(id) on delete cascade,
  token_hash varchar(128) not null unique,
  expires_at timestamptz not null,
  revoked_at timestamptz,
  created_at timestamptz not null
);
create index if not exists idx_refresh_tokens_user on refresh_tokens(user_id);
create index if not exists idx_refresh_tokens_expires on refresh_tokens(expires_at);

create table if not exists password_reset_tokens (
  id uuid primary key,
  user_id uuid not null references users(id) on delete cascade,
  token_hash varchar(128) not null unique,
  expires_at timestamptz not null,
  used_at timestamptz,
  created_at timestamptz not null
);
create index if not exists idx_pwd_reset_user on password_reset_tokens(user_id);

-- Seed roles (id is deterministic for easy references)
insert into roles (id, name, description)
values
  ('00000000-0000-0000-0000-000000000001', 'SUPER_ADMIN', 'Platform super administrator'),
  ('00000000-0000-0000-0000-000000000002', 'ADMIN', 'Platform administrator'),
  ('00000000-0000-0000-0000-000000000003', 'GYM_OWNER', 'Gym owner'),
  ('00000000-0000-0000-0000-000000000004', 'TRAINER', 'Trainer'),
  ('00000000-0000-0000-0000-000000000005', 'MEMBER', 'Member')
on conflict (name) do nothing;

