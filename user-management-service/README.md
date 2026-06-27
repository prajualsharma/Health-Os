# user-management-service

Identity + RBAC service for HealthOS.

## Features
- Flyway migrations (Postgres)
- Users, Roles, Permissions, User Profiles
- Scoped RBAC (portal-agnostic memberships for gym/clinic/nutrition)
- Auth endpoints:
  - `POST /auth/register`
  - `POST /auth/login`
  - `POST /auth/refresh`
  - `POST /auth/logout`
  - `POST /auth/otp/request` (dev)
  - `POST /auth/otp/verify` (dev)
  - `POST /auth/forgot-password` (dev returns token)
  - `POST /auth/reset-password`
- Me endpoints:
  - `GET /me/profile`
  - `PUT /me/profile`
  - `GET /me/memberships`
  - `POST /me/active-scope`
- Scoped membership endpoints:
  - `GET /scoped-memberships`
  - `POST /scoped-memberships`
  - `DELETE /scoped-memberships/{id}`
  - `POST /internal/scoped-memberships` (service-to-service)
- Admin endpoints (RBAC protected):
  - `/admin/users/**`
  - `/admin/roles/**`
  - `/admin/permissions/**`

## Run

```bash
mvn -f pom.xml spring-boot:run
```

## Database
- Migration: `src/main/resources/db/migration/V1__init.sql`
- Migrations: `V1__init.sql`, `V2__scoped_rbac.sql`
- Seed roles: `SUPER_ADMIN`, `ADMIN`, `GYM_OWNER`, `GYM_MANAGER`, `TRAINER`, `STAFF`, `MEMBER`
- Seed permissions: `gym:org:manage`, `gym:location:manage`, `gym:staff:invite`, `gym:member:read`, `gym:member:write`

