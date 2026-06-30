#!/usr/bin/env bash
#
# Sync Health-Os to Oracle Cloud and run oracle-setup.sh (backend + email OTP).
#
#   export SSH_KEY=/home/pras/Downloads/ssh-key-2026-06-30.key
#   export ORACLE_HOST=ubuntu@<public-ip>   # Ubuntu 22.04 on A1.Flex
#   bash deploy/oracle-deploy.sh
#
# Optional: put ORACLE_HOST and SSH_KEY in deploy/oracle-host.env (gitignored).
#
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="${REPO_DIR}/deploy/oracle-host.env"

if [[ -f "$ENV_FILE" ]]; then
  # shellcheck disable=SC1090
  source "$ENV_FILE"
fi

SSH_KEY="${SSH_KEY:-/home/pras/Downloads/ssh-key-2026-06-30.key}"
ORACLE_HOST="${ORACLE_HOST:-}"

if [[ -z "$ORACLE_HOST" ]]; then
  echo "ERROR: Set ORACLE_HOST (e.g. ubuntu@129.x.x.x) or create deploy/oracle-host.env"
  echo "  ORACLE_HOST=ubuntu@<ip>"
  echo "  SSH_KEY=/path/to/ssh-key-2026-06-30.key"
  exit 1
fi

if [[ ! -f "$SSH_KEY" ]]; then
  echo "ERROR: SSH key not found: $SSH_KEY"
  exit 1
fi

chmod 600 "$SSH_KEY"

echo "==> Syncing Health-Os to ${ORACLE_HOST}..."
ssh -i "$SSH_KEY" -o StrictHostKeyChecking=accept-new "$ORACLE_HOST" 'mkdir -p ~/healthos'

rsync -avz --delete \
  -e "ssh -i $SSH_KEY -o StrictHostKeyChecking=accept-new" \
  --exclude '.git' \
  --exclude '**/build/' \
  --exclude '**/target/' \
  --exclude '**/.dart_tool/' \
  --exclude '**/node_modules/' \
  --exclude '**/.vercel/' \
  --exclude 'deploy/oracle-host.env' \
  "$REPO_DIR/" "${ORACLE_HOST}:~/healthos/"

if command -v docker >/dev/null 2>&1 \
  && docker image inspect healthos-user-management-service >/dev/null 2>&1 \
  && docker image inspect healthos-api-gateway >/dev/null 2>&1; then
  echo "==> Transferring pre-built backend images (for micro VMs without RAM to build)..."
  docker save healthos-user-management-service healthos-api-gateway \
    | gzip \
    | ssh -i "$SSH_KEY" -o StrictHostKeyChecking=accept-new "$ORACLE_HOST" \
      'gunzip | (sudo docker load 2>/dev/null || sudo podman load 2>/dev/null || cat > /dev/null)'
fi

echo "==> Running oracle-setup.sh on Oracle..."
ssh -i "$SSH_KEY" -o StrictHostKeyChecking=accept-new "$ORACLE_HOST" \
  'cd ~/healthos && bash deploy/oracle-setup.sh'

ORACLE_IP="${ORACLE_HOST#*@}"
echo "==> Done. Test: curl -s http://${ORACLE_IP}:8080/actuator/health"
echo "    Then set Vercel healthos-api BACKEND_URL=http://${ORACLE_IP}:8080"
