#!/usr/bin/env bash
#
# Bootstrap Oracle Cloud VM for Health-Os backend (NutriKit + Vercel proxy).
# Recommended: VM.Standard.A1.Flex, Ubuntu 22.04, 2 OCPU / 12 GB RAM.
#
# On the VM (or via deploy/oracle-deploy.sh from your laptop):
#   cd ~/healthos && bash deploy/oracle-setup.sh
#
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_DIR"

COMPOSE="docker compose -f docker-compose.yml \
  -f deploy/docker-compose.backend.yml \
  -f deploy/docker-compose.ec2-email.yml \
  -f deploy/docker-compose.ec2-minimal.yml"

echo "==> [1/6] Installing Docker engine + compose plugin (if missing)..."
if ! command -v docker >/dev/null 2>&1; then
  curl -fsSL https://get.docker.com | sudo sh
  sudo usermod -aG docker "$USER" || true
  echo "    Docker installed. You may need to log out/in for group changes."
fi

echo "==> [2/6] Opening host firewall (SSH, API, optional web)..."
if command -v iptables >/dev/null 2>&1; then
  for port in 22 8080 80 443; do
    sudo iptables -C INPUT -p tcp --dport "$port" -j ACCEPT 2>/dev/null \
      || sudo iptables -I INPUT 5 -p tcp --dport "$port" -m state --state NEW,ESTABLISHED -j ACCEPT || true
  done
  if command -v netfilter-persistent >/dev/null 2>&1; then
    sudo netfilter-persistent save || true
  elif [[ -d /etc/iptables ]]; then
    sudo sh -c 'iptables-save > /etc/iptables/rules.v4' 2>/dev/null || true
  fi
fi
echo "    NOTE: also allow TCP 22 and 8080 in the Oracle VCN Security List / NSG."

echo "==> [3/6] Configuring swap (2 GB) for smaller shapes..."
if ! swapon --show | grep -q /swapfile; then
  if [[ ! -f /swapfile ]]; then
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

echo "==> [4/6] Preparing .env..."
if [[ ! -f .env ]]; then
  cp .env.example .env
  SECRET="$(openssl rand -base64 48 | tr -d '\n')"
  sed -i "s|^JWT_SECRET=.*|JWT_SECRET=${SECRET}|" .env
  echo "    Wrote .env with a freshly generated JWT_SECRET."
else
  echo "    .env already exists, leaving it untouched."
fi

# Ensure email OTP defaults (override SMTP_PASSWORD on the server for production).
upsert_env() {
  local key="$1" val="$2"
  if grep -q "^${key}=" .env; then
    sed -i "s|^${key}=.*|${key}=${val}|" .env
  else
    echo "${key}=${val}" >> .env
  fi
}
upsert_env NOTIFICATION_ENABLED "true"
upsert_env OTP_DEV_BYPASS "${OTP_DEV_BYPASS:-false}"
upsert_env OTP_EMAIL_TO "${OTP_EMAIL_TO:-prajual.sharma.1559@gmail.com}"
upsert_env SMTP_HOST "smtp.gmail.com"
upsert_env SMTP_PORT "587"
upsert_env SMTP_USERNAME "${SMTP_USERNAME:-prajual.sharma.1559@gmail.com}"
upsert_env SMTP_FROM "${SMTP_FROM:-prajual.sharma.1559@gmail.com}"
upsert_env SMTP_ENABLED "true"
if [[ -n "${SMTP_PASSWORD:-}" ]]; then
  upsert_env SMTP_PASSWORD "$SMTP_PASSWORD"
  upsert_env OTP_DEV_BYPASS "false"
fi

echo "==> [5/6] Building and starting backend stack (builds natively on ARM A1.Flex)..."
sudo $COMPOSE up -d --build \
  postgres redis user-management-service api-gateway

echo "==> [6/6] Waiting for api-gateway health..."
for i in $(seq 1 60); do
  if curl -sf http://localhost:8080/actuator/health | grep -q UP; then
    echo "    api-gateway is UP"
    break
  fi
  if [[ "$i" -eq 60 ]]; then
    echo "    WARNING: api-gateway not healthy yet. Check: sudo $COMPOSE logs api-gateway"
  fi
  sleep 5
done

sudo $COMPOSE ps

PUBLIC_IP="$(curl -fsS https://api.ipify.org 2>/dev/null || echo '<your-vm-public-ip>')"
cat <<EOF

============================================================
HealthOS backend is starting on Oracle Cloud.

  API health : http://${PUBLIC_IP}:8080/actuator/health
  Swagger    : http://${PUBLIC_IP}:8080/swagger-ui.html

Set Vercel healthos-api BACKEND_URL=http://${PUBLIC_IP}:8080

Watch logs:    sudo $COMPOSE logs -f user-management-service
Stop stack:    sudo $COMPOSE down
============================================================
EOF
