# HealthOS Enterprise Starter

Production-ready starter for a HealthOS platform.

## Included services
- **`api-gateway/`**: Spring Cloud Gateway (JWT validation, routing, rate limiting, Swagger aggregation, Google login orchestration)
- **`user-management-service/`**: Spring Boot service for Users/Roles/Permissions/Auth (JWT + refresh token, Flyway, Redis-ready)
- **`notification-service/`**: Event-driven notifications (Kafka, MongoDB, Redis, Handlebars templates, multi-channel factory/strategy, JWT RBAC)
- **`mobile-app/`**: React Native CLI (TypeScript) app with navigation + Redux Toolkit + React Query + Axios token refresh
- **`infra/`**: Docker Compose for Postgres + Redis + services

## Local setup (backend)

### Prerequisites
- Java 21
- Maven 3.8+
- Docker + Docker Compose (for `infra/`)

### Run using Docker Compose

```bash
cp infra/.env.example infra/.env
docker compose -f infra/docker-compose.yml up -d --build
```

If Docker isn’t available in your environment, run services locally:

```bash
mvn -f user-management-service/pom.xml spring-boot:run
mvn -f api-gateway/pom.xml spring-boot:run
```

### URLs
- **Gateway**: `http://localhost:8080`
- **User service swagger (via gateway aggregation)**: `http://localhost:8080/swagger-ui.html`
- **User service swagger (direct)**: `http://localhost:8081/swagger-ui.html`
- **Notification service**: `http://localhost:8082` (see `notification-service/README.md` for its own Docker Compose stack)

## Auth flows

### Email login
- Mobile calls `POST /auth/login` (via gateway) → gets **access JWT** + **refresh token**
- Mobile stores both, sends access JWT as `Authorization: Bearer <token>`
- On 401, mobile calls `POST /auth/refresh` and retries the original request

### OTP login (dev)
- Mobile calls `POST /auth/otp/request` then `POST /auth/otp/verify`
- **Dev OTP** default is `123456` (set `DEV_OTP_CODE` to change)

### Google login (gateway)
- Mobile obtains a Google **ID token** (native setup required)
- Mobile calls `POST /auth/google` on gateway with `{ "idToken": "..." }`
- Gateway validates token with Google, upserts user in user-service, issues platform access+refresh

## RBAC
Seeded roles in Flyway migration:
- `SUPER_ADMIN`, `ADMIN`, `GYM_OWNER`, `TRAINER`, `MEMBER`

Admin endpoints (require `SUPER_ADMIN` or `ADMIN`):
- `/admin/users/**`, `/admin/roles/**`, `/admin/permissions/**`

## Frontend handoff

See [docs/frontend-handoff.md](docs/frontend-handoff.md) for Next.js web + React Native screen inventory, API contracts, and sprint plan.

## Mobile app

### Run

```bash
cd mobile-app
npm install
npm run android
```

### API base URL
Configured in `mobile-app/src/api/client/baseUrl.ts`:
- Android emulator uses `http://10.0.2.2:8080`
- iOS simulator uses `http://localhost:8080`

