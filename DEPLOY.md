# HealthOS — Deploy the whole stack

One `docker-compose.yml` at the repo root brings up **everything**:

| Component | Container | Port | Notes |
|---|---|---|---|
| Flutter web frontend | `healthos-web` (nginx) | `80` | Serves the app **and** reverse-proxies the API |
| API gateway | `healthos-api-gateway` | 8080 (internal) | Spring Cloud Gateway |
| User management | `healthos-user-management-service` | 8081 (internal) | Postgres + Redis |
| Notification | `healthos-notification-service` | 8082 (internal) | Mongo + Kafka + Redis |
| Postgres | `healthos-postgres` | (internal) | SQL store |
| MongoDB | `healthos-mongo` | (internal) | Notification store |
| Redis | `healthos-redis` | (internal) | Cache / rate limiting |
| Kafka | `healthos-kafka` | (internal) | Event bus |

> The backend ports are **not** published to the host. The browser only ever
> talks to nginx on port 80, which proxies `/auth`, `/me`, `/admin`, `/swagger-ui`,
> etc. to the gateway. That's how the **frontend is bound to the backend APIs**
> with no CORS pain and no hardcoded IP.

Everything builds **from source inside Docker**, so a target machine only needs
Docker installed — no Java, Maven, or Flutter SDK required.

---

## Run locally

```bash
cp .env.example .env
# edit JWT_SECRET (or: sed -i "s|^JWT_SECRET=.*|JWT_SECRET=$(openssl rand -base64 48)|" .env)

docker compose up -d --build
```

Open:
- App: <http://localhost/>  (set `WEB_PORT=8088` in `.env` if port 80 is taken → <http://localhost:8088/>)
- Swagger: <http://localhost/swagger-ui.html>

Useful:
```bash
docker compose logs -f            # tail everything
docker compose ps                 # status
docker compose down               # stop
docker compose down -v            # stop + wipe data volumes
```

---

## Deploy free on Oracle Cloud (Always Free) — recommended

Oracle **Always Free** includes an Ampere **A1.Flex** VM (up to 4 OCPU / 24 GB RAM).
Use **Ubuntu 22.04** — not Oracle Linux `opc` — so [`deploy/oracle-setup.sh`](deploy/oracle-setup.sh)
matches. The AMD `E2.1.Micro` (1 GB RAM) is too small for Docker builds.

### 1. Create the VM

1. Oracle Cloud Console → **Compute → Instances → Create instance**.
2. Image: **Ubuntu 22.04**. Shape: **VM.Standard.A1.Flex**, **2 OCPU / 12 GB** (or 4 / 24 GB).
3. Assign a **public IPv4**, upload your SSH public key, create.

### 2. Open ports in the VCN

Security List or NSG → ingress from `0.0.0.0/0`:

| Port | Purpose |
|------|---------|
| **22** | SSH |
| **8080** | API gateway (NutriKit + Vercel proxy) |
| **80** | Optional — full stack with nginx frontend |

### 3. Deploy backend from your laptop

```bash
cp deploy/oracle-host.env.example deploy/oracle-host.env
# edit ORACLE_HOST=ubuntu@<public-ip>

export SSH_KEY=/home/pras/Downloads/ssh-key-2026-06-30.key
export ORACLE_HOST=ubuntu@<public-ip>
export ORACLE_STACK=dev   # default: backend + kitchen + datastores, OTP 123456

bash deploy/oracle-deploy.sh
```

**Dev stack** (recommended — frontends stay on Vercel, Oracle is API-only):

| On Oracle | Not on Oracle |
|-----------|---------------|
| api-gateway, user-management-service, kitchen-service (Go) | notification-service |
| postgres, redis, mongo, kafka | web / NutriKit / kitchen_app builds |

```bash
docker compose -f docker-compose.yml \
  -f deploy/docker-compose.backend.yml \
  -f deploy/docker-compose.dev-stack.yml \
  -f deploy/docker-compose.oracle-6gb.yml \
  up -d --build \
  postgres redis mongo kafka user-management-service kitchen-service api-gateway
```

Dev OTP is always **123456** (`OTP_DEV_BYPASS=true`, no notification-service).

**Minimal stack** (auth only, no kitchen/mongo/kafka): `ORACLE_STACK=minimal bash deploy/oracle-deploy.sh`

Legacy minimal compose:

```bash
docker compose -f docker-compose.yml \
  -f deploy/docker-compose.backend.yml \
  -f deploy/docker-compose.ec2-email.yml \
  -f deploy/docker-compose.ec2-minimal.yml \
  up -d --build
```

### 4. Wire NutriKit (Vercel)

NutriKit uses `API_URL=https://healthos-api.vercel.app`. Point the proxy at Oracle:

```bash
bash deploy/wire-oracle.sh <public-ip>
# or manually set BACKEND_URL=http://<public-ip>:8080 on the healthos-api Vercel project
```

### 5. Test

```bash
curl -s http://<public-ip>:8080/actuator/health
```

Dev OTP is **123456** when `OTP_DEV_BYPASS=true` (default for `ORACLE_STACK=dev`).

### Dev API endpoints

| Purpose | URL |
|---------|-----|
| Vercel proxy (NutriKit / kitchen_app) | `https://healthos-api.vercel.app` |
| Direct Oracle gateway | `http://<public-ip>:8080` |
| Health | `GET /actuator/health` |
| Auth OTP | `POST /auth/phone/initiate` then `POST /auth/phone/verify` with `"otp":"123456"` |
| Kitchen APIs | `GET /kitchen/kitchens`, `/kitchen/kitchens/{id}/menu`, etc. |

Datastore ports (dev-stack publishes to host): Postgres **5432**, Mongo **27017**, Kafka **9092**, Redis **6379** — open in VCN if needed from your laptop.

Set `SMTP_PASSWORD` in `~/healthos/.env` on the VM for real email OTP (not used when `ORACLE_STACK=dev`).

### Full stack (optional)

For nginx frontend on port 80, use `docker compose up -d --build` without the EC2 overlays.

---

## Deploy on AWS EC2 (legacy — disk/RAM too small on t2.micro)

Backend-only deploy: **api-gateway**, **user-management-service**, **notification-service**
plus Postgres, Redis, Mongo, and Kafka. Tuned for small instances (`t2.micro`) with swap
and memory limits.

### 1. Security group

Allow inbound **TCP 22** (SSH) and **TCP 8080** (API gateway).

### 2. From your laptop (with `prajwalkey.pem`)

```bash
export SSH_KEY=~/path/to/prajwalkey.pem
export EC2_HOST=ec2-user@65.0.109.103
bash deploy/ec2-deploy.sh
```

Or manually on the instance:

```bash
ssh -i prajwalkey.pem ec2-user@65.0.109.103
git clone https://github.com/prajualsharma/Health-Os.git healthos && cd healthos
bash deploy/aws-setup.sh
```

### 3. Backend compose command

On **t2.micro**, Kafka often OOMs. Use the minimal overlay (auth only, OTP logged in
user-management console; no SMS):

```bash
docker compose -f docker-compose.yml \
  -f deploy/docker-compose.backend.yml \
  -f deploy/docker-compose.ec2-minimal.yml up -d --no-build
```

If the 8 GB root disk is full, build images on your laptop and load on EC2:

```bash
docker compose -f docker-compose.yml -f deploy/docker-compose.backend.yml build \
  user-management-service notification-service api-gateway
docker save healthos-user-management-service healthos-notification-service healthos-api-gateway \
  | gzip | ssh -i ~/Downloads/prajual-key.pem ec2-user@65.0.109.103 'gunzip | sudo docker load'
```

Full stack (needs more RAM, e.g. `t3.small`):

```bash
docker compose -f docker-compose.yml -f deploy/docker-compose.backend.yml up -d --build
```

### 4. HTTPS for NutriKit (Vercel)

On EC2, run a Cloudflare quick tunnel:

```bash
curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o cloudflared
chmod +x cloudflared && ./cloudflared tunnel --url http://localhost:8080
```

Set `BACKEND_URL` on the [deploy/vercel-api](deploy/vercel-api) Vercel project to the
`https://….trycloudflare.com` URL, then `npx vercel --prod`.

### 5. Test login

```bash
curl -s http://<ec2-ip>:8080/actuator/health
curl -s -X POST http://<ec2-ip>:8080/auth/phone/initiate \
  -H 'Content-Type: application/json' -d '{"phone":"+919534015459"}'
curl -s -X POST http://<ec2-ip>:8080/auth/phone/verify \
  -H 'Content-Type: application/json' -d '{"phone":"+919534015459","otp":"123456"}'
```

Dev OTP is **123456** when `OTP_DEV_BYPASS=true`.

---

## CI/CD (GitHub Actions)

Workflows live in [`.github/workflows/`](.github/workflows/):

| Workflow | Trigger | What it does |
|---|---|---|
| **CI** | Push / PR to `main` | Maven tests (4 Java services) + `flutter analyze` for NutriKit |
| **Deploy** | Push to `main` or manual | rsync to VM → `docker compose up --build` on host (works on ARM Oracle) |

Runs: [github.com/prajualsharma/Health-Os/actions](https://github.com/prajualsharma/Health-Os/actions)

### Required GitHub repository secrets

Settings → Secrets and variables → Actions:

| Secret | Example |
|---|---|
| `EC2_HOST` | Oracle or EC2 public IP (e.g. `129.x.x.x`) |
| `EC2_USER` | `ubuntu` (Oracle Ubuntu) or `ec2-user` (AWS) |
| `EC2_SSH_KEY` | Full contents of your deploy private key |
| `JWT_SECRET` | 32+ char random string (same as EC2 `.env`) |
| `SMTP_PASSWORD` | Gmail App Password (16 chars, no spaces) |

Optional:

| Secret / Variable | Purpose |
|---|---|
| `OTP_EMAIL_TO` | OTP inbox (default `prajual.sharma.1559@gmail.com`) |
| `VERCEL_TOKEN` | Vercel deploy token |
| Repository variable `DEPLOY_VERCEL` | Set to `true` to deploy NutriKit + API proxy on each push |

### Manual deploy

Actions → **Deploy HealthOS to VM** → **Run workflow**.

---

## Other free-tier options
- **Google Cloud `e2-micro`** (Always Free, us regions) — only 1 GB RAM; would
  need swap + trimmed JVM heaps. Tight but possible for a demo.
- **Fly.io / Render free** — better suited to deploying the services individually
  (managed Postgres/Redis) rather than this single-VM compose stack.
- **Railway / Koyeb** — can run compose-like stacks but free quotas are small.

Oracle's ARM box is the most generous free option for running the entire stack
together, which is why it's the documented path here.

---

## A note on "everything in one container"
Running Postgres, Kafka, three JVMs and nginx inside a **single** container is an
anti-pattern (no process supervision, no independent restarts, huge image, lost
healthchecks). This setup instead runs one **Compose project** on one host — the
practical meaning of "all together in one place" — with each piece in its own
small container on a shared private network. If you genuinely need a single
image, say so and I'll add a supervisord-based all-in-one variant.
