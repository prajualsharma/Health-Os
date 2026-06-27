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
