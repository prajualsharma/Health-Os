-- V3: Phone-first authentication
-- Adds a flexible auth_methods table, relaxes users for phone-first signup,
-- and extends user_profiles with NutriKit onboarding data.

-- Phone becomes a first-class identity; email/password are now optional.
alter table users alter column email drop not null;
alter table users alter column password_hash drop not null;

-- Phone must be unique when present (multiple NULLs allowed).
create unique index if not exists ux_users_phone on users(phone) where phone is not null;

-- Flexible login identifiers: one row per (method, identifier).
create table if not exists auth_methods (
  id uuid primary key,
  user_id uuid not null references users(id) on delete cascade,
  method varchar(16) not null,        -- PHONE | GOOGLE | APPLE
  identifier varchar(255) not null,   -- E.164 phone / oauth subject
  verified boolean not null default false,
  created_at timestamptz not null default now(),
  unique (method, identifier)
);
create index if not exists idx_auth_methods_user on auth_methods(user_id);

-- Extend profile with NutriKit onboarding fields (nutrition specifics live
-- here until a dedicated nutrikit-service exists).
alter table user_profiles add column if not exists target_weight_kg int;
alter table user_profiles add column if not exists activity_level varchar(32);
alter table user_profiles add column if not exists diet_type varchar(32);
alter table user_profiles add column if not exists allergies text;
alter table user_profiles add column if not exists calorie_target int;
alter table user_profiles add column if not exists protein_target_g int;
alter table user_profiles add column if not exists carb_target_g int;
alter table user_profiles add column if not exists fat_target_g int;
