# HealthOS API proxy on Vercel

Spring Boot + Postgres cannot run on Vercel. This project is a **HTTPS reverse
proxy** so NutriKit (and other clients) can call a stable `*.vercel.app` URL
while the real stack runs on Docker (local VM, Oracle Cloud, etc.).

## Env vars (Vercel project settings)

| Name | Example |
|---|---|
| `BACKEND_URL` | `https://your-tunnel-or-vm-host` (no trailing slash) |

## Deploy

```bash
cd deploy/vercel-api
npx vercel link
npx vercel env add BACKEND_URL production
npx vercel --prod
```

Then set NutriKit `API_URL` to the proxy's production URL and `MOCK_AUTH=false`.
