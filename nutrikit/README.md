# NutriKit

A cross-platform (iOS, Android, Web) nutrition + meal-delivery app built from a single Flutter codebase. AI-style onboarding builds a daily macro target, a kitchen cooks portioned meals to those targets, and the app handles ordering, tracking, progress and profile.

> Data layer is UI-first: every screen renders from in-app mock data (`lib/data/services/mock_data.dart`) so the app runs standalone on all platforms. A fully typed Dio `ApiService` (`lib/data/services/api_service.dart`) is wired and ready to point at a real backend — flip `USE_MOCK` off to use it (see below).

## Tech stack

- **Flutter** (single codebase: iOS / Android / Web)
- **go_router** — routing incl. `StatefulShellRoute` bottom-nav + adaptive web rail
- **provider** — `AuthProvider`, `ProfileProvider`
- **dio** — HTTP client with auth interceptor, typed errors, retry-once
- **flutter_secure_storage** / **shared_preferences** — token + cache
- **fl_chart** — weight bar chart
- **google_fonts** (DM Sans) — typography
- **shimmer** — loading skeletons

## Project structure

```
lib/
├── main.dart                 # entry; MultiProvider + platform setup
├── app.dart                  # MaterialApp.router
├── core/
│   ├── theme/                # app_colors, app_typography, app_theme
│   ├── constants/            # app_constants (API URL, USE_MOCK flag)
│   ├── router/               # app_router (go_router)
│   └── utils/                # validators
├── data/
│   ├── models/               # typed models w/ fromJson
│   └── services/             # api_service (Dio) + mock_data
├── presentation/
│   ├── widgets/common/       # AppButton, AppCard, CalorieRing, ...
│   ├── screens/              # onboarding / auth / main
│   └── providers/            # auth, profile, cart, onboarding stores
└── platform/                 # web/ + mobile/ conditional entry helpers
```

## Run

```bash
# Web (Chrome)
flutter run -d chrome

# iOS simulator
flutter run -d ios

# Android emulator
flutter run -d android
```

## Build

```bash
# Web for production (inject the backend URL at build time)
flutter build web --release --dart-define=API_URL=https://your-api.com/api

# iOS for the App Store
flutter build ios --release

# Android APK
flutter build apk --release

# Android App Bundle (Play Store)
flutter build appbundle --release
```

### Mock vs live backend

The app ships with `USE_MOCK=true` so it works with no server. To hit a real backend:

```bash
flutter run -d chrome \
  --dart-define=USE_MOCK=false \
  --dart-define=API_URL=http://localhost:8080/api
```

`API_URL` is read in `lib/core/constants/app_constants.dart` via
`String.fromEnvironment('API_URL', defaultValue: 'http://localhost:8080/api')`.

## Firebase Hosting (Web)

One-time setup (already scaffolded in `firebase.json` + `.firebaserc` — update the
project id in `.firebaserc`):

```bash
firebase login
firebase init hosting        # public dir: build/web, single-page app: Yes
```

Deploy:

```bash
flutter build web --release --dart-define=API_URL=https://your-api.com/api
firebase deploy --only hosting
```

`firebase.json` sets `public: build/web` and rewrites all routes to
`/index.html` (required for clean go_router URLs via `usePathUrlStrategy`).

## Connecting to the Spring Boot backend

`ApiService` targets REST paths under `/v1/*` (e.g. `/v1/dashboard`,
`/v1/orders`, `/v1/profile/me`) and adds `Authorization: Bearer <token>` from
secure storage on every request. On `401` it clears storage and routes back to
onboarding. Network timeouts are retried once automatically.

### Fixing Flutter Web CORS

When the web build calls the Spring Boot API from a different origin (e.g.
`localhost:port` in dev or the Firebase Hosting domain in prod), the browser
enforces CORS. Allow the Flutter origin server-side. A global bean is the most
robust option:

```java
@Configuration
public class CorsConfig {
  @Bean
  public CorsConfigurationSource corsConfigurationSource() {
    CorsConfiguration config = new CorsConfiguration();
    config.setAllowedOrigins(List.of(
        "http://localhost:5000",                 // local flutter web
        "https://nutrikit-app.web.app",          // firebase hosting
        "https://nutrikit-app.firebaseapp.com"
    ));
    config.setAllowedMethods(List.of("GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"));
    config.setAllowedHeaders(List.of("Authorization", "Content-Type"));
    config.setAllowCredentials(true);
    UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
    source.registerCorsConfiguration("/**", config);
    return source;
  }
}
```

Or, per-controller: annotate with
`@CrossOrigin(origins = {"http://localhost:5000", "https://nutrikit-app.web.app"})`.
If Spring Security is enabled, also call `http.cors(Customizer.withDefaults())`
in the security filter chain so the config is applied.

During local development you can avoid CORS entirely by serving the web app on a
fixed port (`flutter run -d chrome --web-port=5000`) and whitelisting that port.
