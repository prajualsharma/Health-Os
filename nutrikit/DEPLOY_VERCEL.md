# Deploy NutriKit (Flutter web) to Vercel + wire it to the backend

This deploys the NutriKit web app to Vercel and connects its **phone auth +
registration** to the HealthOS backend, so a new signup is **persisted in
Postgres** (`users` + `user_profiles`).

## What's live vs. mock

| Flow | Endpoint | Backend? | Build flag |
|---|---|---|---|
| Phone OTP + registration | `/auth/phone/initiate`, `/auth/phone/verify`, `/auth/register-phone` | **Yes — saves user to Postgres** | `MOCK_AUTH=false` |
| Dashboard / meal plan / kitchen / orders / progress / profile | `/v1/*` | Not implemented yet | `USE_MOCK=true` |

So the recommended production build is **`MOCK_AUTH=false` + `USE_MOCK=true`**:
real account creation, mock content screens.

---

## Prerequisite: the backend must be reachable over HTTPS

NutriKit on Vercel is served over **https**. Browsers block a secure page from
calling an insecure (`http://`) API (mixed content), so the api-gateway must be
exposed over **https**. Pick one (all have a free path):

- **Cloudflare Tunnel (recommended, free, no domain/cert needed).** On the VM
  running the compose stack from the repo root:
  ```bash
  # install cloudflared, then:
  cloudflared tunnel --url http://localhost:80
  ```
  It prints a public `https://<random>.trycloudflare.com` URL that proxies to
  your stack. Use that as `API_URL`. For a stable hostname, create a named
  tunnel bound to a Cloudflare-managed domain.
- **Domain + TLS:** point a domain at the VM and terminate TLS with Caddy or
  certbot/nginx, then use `https://api.yourdomain.com`.

> The api-gateway already sends permissive CORS (`CORS_ALLOWED_ORIGINS=*`,
> credentials + all headers), so the Vercel origin is allowed out of the box.
> Tighten it to your Vercel domain for production.

---

## Deploy on Vercel

### Option A — Vercel dashboard (easiest)
1. **New Project → Import** your Git repo.
2. **Root Directory:** set to `nutrikit`.
3. Framework Preset: **Other** (the included `vercel.json` already sets the
   build command, output dir, and SPA rewrites).
4. **Settings → Environment Variables** (Production + Preview):
   | Name | Value |
   |---|---|
   | `API_URL` | `https://<your-backend-host>` (no trailing slash, no `/api`) |
   | `MOCK_AUTH` | `false` |
   | `USE_MOCK` | `true` |
5. **Deploy.** First build is slow (it downloads the Flutter SDK); later builds reuse it.

### Option B — Vercel CLI
```bash
cd nutrikit
npm i -g vercel
vercel link
vercel env add API_URL production       # https://<your-backend-host>
vercel env add MOCK_AUTH production      # false
vercel env add USE_MOCK production       # true
vercel --prod
```

`vercel.json` runs `vercel-build.sh`, which installs Flutter and runs
`flutter build web --release` with the env vars injected as `--dart-define`s,
outputting to `build/web`.

---

## Verify a user is saved in the DB

1. Open the Vercel URL → enter a 10-digit phone → continue.
2. OTP screen: in dev the code is **`123456`** (`DEV_OTP_CODE`, `OTP_DEV_BYPASS=true`).
3. Complete onboarding (name, goal, body, etc.) → this calls `register-phone`.
4. On the VM, check Postgres:
   ```bash
   docker compose exec postgres psql -U healthos -d healthos \
     -c "select id, first_name, last_name, phone, email, created_at from users order by created_at desc limit 5;"

   docker compose exec postgres psql -U healthos -d healthos \
     -c "select user_id, gender, height_cm, weight_kg, goal, calorie_target, protein_target_g from user_profiles order by updated_at desc limit 5;"
   ```
   You should see the new row with the name/goal/macros captured during onboarding.

---

## Troubleshooting

- **OTP send fails / "Cannot reach the server":** `API_URL` wrong, backend not
  on https, or stack not running. Open `https://<API_URL>/actuator/health` in a
  browser — it should return `{"status":"UP"}`.
- **CORS error in the browser console:** confirm `CORS_ALLOWED_ORIGINS` includes
  your Vercel domain (the default `*` already does).
- **Mixed content blocked:** the API is `http://`. Put it behind https (see above).
- **`Phone must be E.164`:** the app sends `+91` + 10 digits automatically; make
  sure you typed a full 10-digit Indian number.
- **Build fails on Vercel with empty API_URL:** set `API_URL`, or set
  `MOCK_AUTH=true` for a pure-demo build with no backend.
