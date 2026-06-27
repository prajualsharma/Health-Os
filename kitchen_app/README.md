# HealthOS Cloud Kitchen

Flutter app (iOS / Android / Web) for cloud-kitchen operations on the HealthOS
platform. Two roles share one phone-OTP login:

- **Corporate** — add and manage cloud kitchens across the organization.
- **Kitchen** — a Swiggy/Zomato-style kitchen display: a live order board with
  Accept / Preparing / Ready / Picked-up transitions, plus a menu manager
  grouped by meal category.

## Stack

- `go_router`, `provider`, `dio`, `flutter_secure_storage`, `shared_preferences`
- Typed `ApiService` for `/auth/**` and `/kitchen/**`, **mock-first** so the app
  runs with no backend.

## Run

```bash
flutter pub get

# Pure demo (dummy data, OTP 123456):
flutter run -d chrome \
  --dart-define=USE_MOCK=true \
  --dart-define=MOCK_AUTH=true

# Live backend (kitchen-service via api-gateway):
flutter run -d chrome \
  --dart-define=API_URL=https://your-gateway \
  --dart-define=USE_MOCK=false \
  --dart-define=MOCK_AUTH=false
```

## Dart-defines

| define      | default | meaning                                              |
|-------------|---------|------------------------------------------------------|
| `API_URL`   | `http://localhost:8080` | api-gateway base URL                 |
| `USE_MOCK`  | `true`  | serve kitchens/menu/orders from in-app mock data     |
| `MOCK_AUTH` | `USE_MOCK` | demo phone auth (OTP `123456`, no backend)        |

## Deploy (Vercel, deferred)

`vercel-build.sh` fetches Flutter and builds `build/web`. Configure `API_URL`,
`USE_MOCK`, `MOCK_AUTH` as Vercel env vars. See `vercel.json`.
