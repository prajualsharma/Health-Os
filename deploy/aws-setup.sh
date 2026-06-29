#!/usr/bin/env bash
#
# One-shot bootstrap for AWS EC2 (Amazon Linux 2023).
# Tuned for t2.micro: adds swap, installs Docker, deploys backend-only stack.
#
# Usage on EC2:
#   git clone <your-repo> healthos && cd healthos
#   bash deploy/aws-setup.sh
#
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_DIR"

COMPOSE="docker compose -f docker-compose.yml -f deploy/docker-compose.backend.yml"

echo "==> [1/6] Installing Docker (if missing)..."
if ! command -v docker >/dev/null 2>&1; then
  if command -v dnf >/dev/null 2>&1; then
    sudo dnf install -y docker docker-compose-plugin
    sudo systemctl enable --now docker
  else
    curl -fsSL https://get.docker.com | sudo sh
  fi
  sudo usermod -aG docker "${USER}" || true
  echo "    Docker installed. Log out/in if 'docker' permission denied."
fi

# Compose file build requires buildx 0.17+ (Amazon Linux docker may ship 0.12).
echo "    Ensuring Docker Buildx >= 0.17..."
BUILDX_VERSION="${BUILDX_VERSION:-v0.19.3}"
sudo mkdir -p /usr/local/lib/docker/cli-plugins
sudo curl -fsSL \
  "https://github.com/docker/buildx/releases/download/${BUILDX_VERSION}/buildx-${BUILDX_VERSION}.linux-amd64" \
  -o /usr/local/lib/docker/cli-plugins/docker-buildx
sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-buildx
# Remove older distro buildx if present (Amazon Linux ships 0.12).
sudo rm -f /usr/libexec/docker/cli-plugins/docker-buildx 2>/dev/null || true
docker buildx version || sudo docker buildx version || true

echo "==> [2/6] Configuring swap (2 GB) for small instances..."
if ! swapon --show | grep -q /swapfile; then
  if [ ! -f /swapfile ]; then
    sudo fallocate -l 2G /swapfile 2>/dev/null || sudo dd if=/dev/zero of=/swapfile bs=1M count=2048
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
  fi
  sudo swapon /swapfile || true
  if ! grep -q '/swapfile' /etc/fstab 2>/dev/null; then
    echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
  fi
fi
free -h || true

echo "==> [3/6] Preparing .env..."
if [ ! -f .env ]; then
  cp .env.example .env
  SECRET="$(openssl rand -base64 48 | tr -d '\n')"
  sed -i "s|^JWT_SECRET=.*|JWT_SECRET=${SECRET}|" .env
  echo "    Wrote .env with a freshly generated JWT_SECRET."
else
  echo "    .env already exists, leaving it untouched."
fi

echo "==> [4/6] Building and starting backend stack (first run may take 10–15 min)..."
sudo $COMPOSE up -d --build

echo "==> [5/6] Waiting for api-gateway health..."
for i in $(seq 1 60); do
  if curl -sf http://localhost:8080/actuator/health | grep -q UP; then
    echo "    api-gateway is UP"
    break
  fi
  if [ "$i" -eq 60 ]; then
    echo "    WARNING: api-gateway not healthy yet. Check: sudo $COMPOSE logs api-gateway"
  fi
  sleep 5
done

echo "==> [6/6] Status:"
sudo $COMPOSE ps

PUBLIC_IP="$(curl -fsS --max-time 5 http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null \
  || curl -fsS --max-time 5 https://api.ipify.org 2>/dev/null \
  || echo '<ec2-public-ip>')"

cat <<EOF

============================================================
HealthOS backend is starting.

  API health : http://${PUBLIC_IP}:8080/actuator/health
  Swagger    : http://${PUBLIC_IP}:8080/swagger-ui.html

  Test OTP login:
    curl -s -X POST http://${PUBLIC_IP}:8080/auth/phone/initiate \\
      -H 'Content-Type: application/json' -d '{"phone":"+919534015459"}'
    curl -s -X POST http://${PUBLIC_IP}:8080/auth/phone/verify \\
      -H 'Content-Type: application/json' -d '{"phone":"+919534015459","otp":"123456"}'

  HTTPS for NutriKit (run in another terminal):
    curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o cloudflared
    chmod +x cloudflared && ./cloudflared tunnel --url http://localhost:8080

  Logs:  sudo $COMPOSE logs -f api-gateway user-management-service
  Stop:  sudo $COMPOSE down
============================================================
EOF
