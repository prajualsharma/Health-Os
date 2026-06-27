#!/usr/bin/env bash
#
# One-shot bootstrap for a fresh Oracle Cloud "Always Free" VM (Ubuntu 22.04+).
# Recommended shape: VM.Standard.A1.Flex (Ampere ARM, up to 4 OCPU / 24 GB RAM)
# which comfortably fits Postgres + Mongo + Redis + Kafka + 3 JVMs + nginx.
#
# Usage on the VM:
#   git clone <your-repo> healthos && cd healthos
#   bash deploy/oracle-setup.sh
#
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_DIR"

echo "==> [1/5] Installing Docker engine + compose plugin (if missing)..."
if ! command -v docker >/dev/null 2>&1; then
  curl -fsSL https://get.docker.com | sudo sh
  sudo usermod -aG docker "$USER" || true
  echo "    Docker installed. You may need to log out/in for group changes."
fi

echo "==> [2/5] Opening firewall ports 80/443 on the instance..."
# Oracle Ubuntu images default-DROP everything except SSH via iptables.
if command -v iptables >/dev/null 2>&1; then
  sudo iptables -I INPUT 5 -p tcp --dport 80  -m state --state NEW,ESTABLISHED -j ACCEPT || true
  sudo iptables -I INPUT 6 -p tcp --dport 443 -m state --state NEW,ESTABLISHED -j ACCEPT || true
  # Persist the rules across reboots.
  if command -v netfilter-persistent >/dev/null 2>&1; then
    sudo netfilter-persistent save || true
  else
    sudo sh -c 'iptables-save > /etc/iptables/rules.v4' 2>/dev/null || true
  fi
fi
echo "    NOTE: also add an Ingress rule for TCP 80 (and 443) to the VCN"
echo "          Security List / NSG in the Oracle Cloud console."

echo "==> [3/5] Preparing .env..."
if [ ! -f .env ]; then
  cp .env.example .env
  # Generate a strong JWT secret automatically.
  SECRET="$(openssl rand -base64 48 | tr -d '\n')"
  sed -i "s|^JWT_SECRET=.*|JWT_SECRET=${SECRET}|" .env
  echo "    Wrote .env with a freshly generated JWT_SECRET."
else
  echo "    .env already exists, leaving it untouched."
fi

echo "==> [4/5] Building and starting the full stack (this takes a few minutes)..."
sudo docker compose up -d --build

echo "==> [5/5] Done. Current status:"
sudo docker compose ps

PUBLIC_IP="$(curl -fsS https://api.ipify.org 2>/dev/null || echo '<your-vm-public-ip>')"
cat <<EOF

============================================================
HealthOS is starting up.

  Frontend : http://${PUBLIC_IP}/
  Swagger  : http://${PUBLIC_IP}/swagger-ui.html

Watch logs:    sudo docker compose logs -f
Stop stack:    sudo docker compose down
============================================================
EOF
