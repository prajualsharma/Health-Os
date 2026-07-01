# user-management-service

Identity service for HealthOS — consumer (NutriKit) and staff (Kitchen + Gym) pools.

## API surface

**NutriKit (consumer)**

- `POST /auth/nutrikit/phone/initiate`
- `POST /auth/nutrikit/phone/verify`
- `POST /auth/nutrikit/register-phone`
- `POST /auth/nutrikit/refresh`
- `GET /me/nutrikit/profile`
- `PUT /me/nutrikit/profile`

**Staff (Kitchen + Gym)**

- `POST /auth/staff/phone/initiate`
- `POST /auth/staff/phone/verify`
- `POST /auth/staff/register-phone`
- `POST /auth/staff/refresh`
- `GET /me/staff/memberships`
- `POST /me/staff/active-scope`
- `GET /scoped-memberships` (manage memberships in a scope)
- `POST /scoped-memberships`
- `DELETE /scoped-memberships/{id}`

**Internal (service-to-service)**

- `POST /internal/auth/oauth/resolve`
- `POST /internal/tokens/refresh`
- `POST /internal/staff/scoped-memberships`

**Admin (RBAC protected)**

- `/admin/users/**`
- `/admin/roles/**`
- `/admin/permissions/**`

## Run

```bash
mvn spring-boot:run
```

## Database

Flyway migrations in `src/main/resources/db/migration/`:

- `consumer` schema — NutriKit accounts and profiles
- `staff` schema — Kitchen/Gym staff accounts and scoped memberships
- `public` schema — shared RBAC (`roles`, `permissions`) and kitchen tables
