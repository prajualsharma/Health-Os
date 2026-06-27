-- Scoped RBAC: portal-agnostic memberships (gym, clinic, etc.)

create table if not exists scoped_memberships (
  id uuid primary key,
  user_id uuid not null references users(id) on delete cascade,
  portal_type varchar(32) not null,
  scope_type varchar(32) not null,
  scope_id uuid not null,
  role_name varchar(64) not null,
  status varchar(32) not null default 'ACTIVE',
  created_at timestamptz not null default now(),
  constraint uq_scoped_membership unique (user_id, portal_type, scope_type, scope_id, role_name)
);

create index if not exists idx_scoped_memberships_user on scoped_memberships(user_id);
create index if not exists idx_scoped_memberships_scope on scoped_memberships(scope_type, scope_id);
create index if not exists idx_scoped_memberships_portal_scope_role
  on scoped_memberships(portal_type, scope_id, role_name);

-- Additional seeded roles
insert into roles (id, name, description)
values
  ('00000000-0000-0000-0000-000000000006', 'GYM_MANAGER', 'Gym manager (scoped to a location)'),
  ('00000000-0000-0000-0000-000000000007', 'STAFF', 'Gym staff (scoped to a location)')
on conflict (name) do nothing;

-- Seed permissions
insert into permissions (id, name, description)
values
  ('00000000-0000-0000-0000-000000000101', 'gym:org:manage', 'Manage organization settings'),
  ('00000000-0000-0000-0000-000000000102', 'gym:location:manage', 'Create and manage gym locations'),
  ('00000000-0000-0000-0000-000000000103', 'gym:staff:invite', 'Invite staff to a gym location'),
  ('00000000-0000-0000-0000-000000000104', 'gym:member:read', 'Read gym members'),
  ('00000000-0000-0000-0000-000000000105', 'gym:member:write', 'Manage gym members')
on conflict (name) do nothing;

-- Map permissions to global roles (used for authorization checks)
insert into role_permissions (role_id, permission_id)
values
  ('00000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000101'),
  ('00000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000102'),
  ('00000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000103'),
  ('00000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000104'),
  ('00000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000105'),
  ('00000000-0000-0000-0000-000000000006', '00000000-0000-0000-0000-000000000103'),
  ('00000000-0000-0000-0000-000000000006', '00000000-0000-0000-0000-000000000104'),
  ('00000000-0000-0000-0000-000000000006', '00000000-0000-0000-0000-000000000105'),
  ('00000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000104'),
  ('00000000-0000-0000-0000-000000000007', '00000000-0000-0000-0000-000000000104')
on conflict do nothing;
