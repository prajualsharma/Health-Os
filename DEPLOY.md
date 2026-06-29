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

## Deploy free on Oracle Cloud (Always Free)

Oracle's **Always Free** tier includes an Ampere ARM VM with up to **4 OCPU / 24 GB
RAM** — plenty for this stack (3 JVMs + Kafka + Mongo + Postgres + Redis). This is
the recommended free host; the AMD `E2.1.Micro` (1 GB RAM) is **too small**.

### 1. Create the VM
1. Oracle Cloud Console → **Compute → Instances → Create instance**.
2. Image: **Ubuntu 22.04** (or newer). Shape: **VM.Standard.A1.Flex**, 4 OCPU / 24 GB.
3. Add your SSH public key, create.

### 2. Open port 80 in the VCN
Networking → your VCN → Security List (or the instance's NSG) → **Add Ingress Rule**:
- Source `0.0.0.0/0`, IP Protocol `TCP`, Destination port `80` (and `443` if you add TLS).

### 3. Bootstrap
```bash
ssh ubuntu@<vm-public-ip>
git clone <your-repo-url> healthos && cd healthos
bash deploy/oracle-setup.sh
```
The script installs Docker, opens the host firewall (Ubuntu images DROP by default),
generates a `JWT_SECRET`, and runs `docker compose up -d --build`.

Then browse to `http://<vm-public-ip>/`.

### 4. (Optional) HTTPS + domain
Point a domain's A record at the VM IP, then add a TLS terminator. Easiest is to
put Caddy in front, or add a `certbot` companion. Ask and I can wire it in.

---

## Deploy on AWS EC2 (Amazon Linux 2023)

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
| **Deploy** | Push to `main` or manual | Build Docker images on GitHub → rsync to EC2 → `docker load` → compose up |

Runs: [github.com/prajualsharma/Health-Os/actions](https://github.com/prajualsharma/Health-Os/actions)

### Required GitHub repository secrets

Settings → Secrets and variables → Actions:

| Secret | Example |
|---|---|
| `EC2_HOST` | `65.0.109.103` |
| `EC2_USER` | `ec2-user` |
| `EC2_SSH_KEY` | Full contents of `prajual-key.pem` |
| `JWT_SECRET` | 32+ char random string (same as EC2 `.env`) |
| `SMTP_PASSWORD` | Gmail App Password (16 chars, no spaces) |

Optional:

| Secret / Variable | Purpose |
|---|---|
| `OTP_EMAIL_TO` | OTP inbox (default `prajual.sharma.1559@gmail.com`) |
| `VERCEL_TOKEN` | Vercel deploy token |
| Repository variable `DEPLOY_VERCEL` | Set to `true` to deploy NutriKit + API proxy on each push |

### Manual deploy

Actions → **Deploy HealthOS to EC2** → **Run workflow**.

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
