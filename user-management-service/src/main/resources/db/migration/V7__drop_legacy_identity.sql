-- Remove legacy public identity tables (superseded by consumer.* and staff.*).

DROP TABLE IF EXISTS public.password_reset_tokens;
DROP TABLE IF EXISTS public.refresh_tokens;
DROP TABLE IF EXISTS public.auth_methods;
DROP TABLE IF EXISTS public.scoped_memberships;
DROP TABLE IF EXISTS public.user_profiles;
DROP TABLE IF EXISTS public.user_roles;
DROP TABLE IF EXISTS public.users;
