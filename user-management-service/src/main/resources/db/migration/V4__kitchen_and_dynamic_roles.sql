-- Kitchen portal roles + portal-agnostic (dynamic) authorization permissions.
--
-- Authorization is permission-driven: ScopeAuthorizationService grants assign/manage authority to
-- any scoped role carrying `scope:membership:manage`. Seeding these onto the gym roles keeps gym
-- behavior intact while letting new portals (kitchen) and dynamically created roles work without
-- code changes. More roles can be created at runtime via POST /admin/roles.

-- Kitchen roles
insert into roles (id, name, description)
values
  ('00000000-0000-0000-0000-000000000008', 'CORPORATE', 'Cloud-kitchen corporate owner (organization scope)'),
  ('00000000-0000-0000-0000-000000000009', 'KITCHEN_STAFF', 'Cloud-kitchen staff (location scope)')
on conflict (name) do nothing;

-- Portal-agnostic authorization permissions
insert into permissions (id, name, description)
values
  ('00000000-0000-0000-0000-000000000110', 'scope:membership:manage', 'Assign and revoke memberships within an applicable scope'),
  ('00000000-0000-0000-0000-000000000111', 'scope:org:manage', 'Manage an organization scope')
on conflict (name) do nothing;

-- Kitchen domain permissions
insert into permissions (id, name, description)
values
  ('00000000-0000-0000-0000-000000000120', 'kitchen:manage', 'Create and manage cloud kitchens'),
  ('00000000-0000-0000-0000-000000000121', 'kitchen:menu:write', 'Add and edit kitchen menu items'),
  ('00000000-0000-0000-0000-000000000122', 'kitchen:order:read', 'Read kitchen orders'),
  ('00000000-0000-0000-0000-000000000123', 'kitchen:order:write', 'Update kitchen order status')
on conflict (name) do nothing;

-- Map generic management permissions onto existing gym roles (keeps gym authorization working
-- through the new permission-driven checks).
insert into role_permissions (role_id, permission_id)
values
  -- GYM_OWNER -> manage memberships + org
  ('00000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000110'),
  ('00000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000111'),
  -- GYM_MANAGER -> manage memberships
  ('00000000-0000-0000-0000-000000000006', '00000000-0000-0000-0000-000000000110')
on conflict do nothing;

-- CORPORATE -> full kitchen authority + membership/org management
insert into role_permissions (role_id, permission_id)
values
  ('00000000-0000-0000-0000-000000000008', '00000000-0000-0000-0000-000000000110'),
  ('00000000-0000-0000-0000-000000000008', '00000000-0000-0000-0000-000000000111'),
  ('00000000-0000-0000-0000-000000000008', '00000000-0000-0000-0000-000000000120'),
  ('00000000-0000-0000-0000-000000000008', '00000000-0000-0000-0000-000000000121'),
  ('00000000-0000-0000-0000-000000000008', '00000000-0000-0000-0000-000000000122'),
  ('00000000-0000-0000-0000-000000000008', '00000000-0000-0000-0000-000000000123')
on conflict do nothing;

-- KITCHEN_STAFF -> menu + order operations at their location
insert into role_permissions (role_id, permission_id)
values
  ('00000000-0000-0000-0000-000000000009', '00000000-0000-0000-0000-000000000121'),
  ('00000000-0000-0000-0000-000000000009', '00000000-0000-0000-0000-000000000122'),
  ('00000000-0000-0000-0000-000000000009', '00000000-0000-0000-0000-000000000123')
on conflict do nothing;
