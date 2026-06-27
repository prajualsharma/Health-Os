# api-gateway

Spring Cloud Gateway edge service for HealthOS.

## Features
- Routing to downstream services (currently `user-management-service`)
- JWT validation for protected routes (adds `X-User-*`, `X-User-Memberships`, `X-Portal-Type`, `X-Scope-Type`, `X-Scope-Id` headers downstream)
- Rate limiting (Redis-backed)
- CORS
- Request logging
- Swagger aggregation (proxies downstream OpenAPI docs)
- Google login orchestration: `POST /auth/google`

## Run

```bash
mvn -f pom.xml spring-boot:run
```

## Configuration
See `src/main/resources/application.yml`.

