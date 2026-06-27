# HealthOS Flutter App

Modern SaaS gym management UI prototype (Android + iOS + Web) built with Flutter. Runs entirely on realistic dummy data — backend wiring comes later.

## Dev login

- Mobile: `9534015459` → OTP: `1234` (any mobile + OTP `1234` also works in dev)
- Any email + any password works
- "Continue with Google" is a stub (logs in as Owner)
- Role chips on the login screen let you preview Owner / Manager / Trainer / Receptionist views

## Run

```bash
flutter pub get

# Web (desktop layout with sidebar)
flutter run -d chrome

# Android (bottom-nav layout, OTP SMS autofill)
flutter run -d android

# Build installable APK (release)
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk

# iOS
flutter run -d ios
```

## Deploy demo (Vercel)

Static web build — no backend required.

```bash
chmod +x deploy.sh

# One-time: log in to Vercel (opens browser)
npx vercel login

# Build + deploy
./deploy.sh
```

Production URL is printed at the end (e.g. `https://healthos-flutter.vercel.app`).

**Without CLI:** after `./deploy.sh` fails at auth, the folder `build/web` is still ready — drag it onto [Netlify Drop](https://app.netlify.com/drop) for an instant public demo.

**CI / token:** set `VERCEL_TOKEN` from [vercel.com/account/tokens](https://vercel.com/account/tokens) then run `./deploy.sh`.

## Structure

```
lib/
├── app/        # theme, router, responsive shell, shared widgets
├── core/       # mock session (roles), dark-mode preference
├── data/       # models + dummy data (3 gyms, 54 members, 10 staff)
└── features/   # auth, dashboard, gyms, staff, members,
                # memberships, attendance, payments, reports, settings
```

## Design

- Primary `#2563EB`, secondary `#10B981`, Inter font, Material 3
- ≥1024px: left sidebar + top header (web portal)
- <1024px: bottom navigation (mobile app)
- Light/dark mode toggle (persisted)

## Role access (mock)

| Role | Access |
|------|--------|
| Gym Owner | All gyms + all modules + org settings |
| Gym Manager | Assigned gym only |
| Trainer | Members + attendance |
| Receptionist | Check-in/out, payments, member lookup |
