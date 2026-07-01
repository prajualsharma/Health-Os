#!/usr/bin/env bash
#
# Sync Health-Os to Oracle Cloud and run oracle-setup.sh.
#
#   export SSH_KEY=/home/pras/Downloads/ssh-key-2026-06-30.key
#   export ORACLE_HOST=ubuntu@<public-ip>
#   export ORACLE_STACK=dev            # recommended: gateway + user-mgmt + kitchen + datastores, OTP 123456
#   export ORACLE_STACK=minimal        # auth only (no kitchen/mongo/kafka)
#   export ORACLE_STACK=full           # + notification-service
#   export SMTP_PASSWORD=...           # optional; disables OTP_DEV_BYPASS when set
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
ORACLE_STACK="${ORACLE_STACK:-dev}"

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

echo "==> Syncing Health-Os to ${ORACLE_HOST} (stack: ${ORACLE_STACK})..."
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

REMOTE_ARCH="$(ssh -i "$SSH_KEY" -o StrictHostKeyChecking=accept-new "$ORACLE_HOST" 'uname -m' 2>/dev/null || echo unknown)"
LOCAL_ARCH="$(uname -m)"

if command -v docker >/dev/null 2>&1 \
  && docker image inspect healthos-user-management-service >/dev/null 2>&1 \
  && docker image inspect healthos-api-gateway >/dev/null 2>&1 \
  && [[ "$REMOTE_ARCH" == "$LOCAL_ARCH" ]]; then
  echo "==> Transferring pre-built backend images (for micro VMs without RAM to build)..."
  IMAGES=(healthos-user-management-service healthos-api-gateway)
  if [[ "$ORACLE_STACK" == "dev" || "$ORACLE_STACK" == "full" ]] \
    && docker image inspect healthos-kitchen-service >/dev/null 2>&1; then
    IMAGES+=(healthos-kitchen-service)
  fi
  if [[ "$ORACLE_STACK" == "full" ]] \
    && docker image inspect healthos-notification-service >/dev/null 2>&1; then
    IMAGES+=(healthos-notification-service)
  fi
  docker save "${IMAGES[@]}" \
    | gzip \
    | ssh -i "$SSH_KEY" -o StrictHostKeyChecking=accept-new "$ORACLE_HOST" \
      'gunzip | (sudo docker load 2>/dev/null || sudo podman load 2>/dev/null || cat > /dev/null)'
elif [[ "$REMOTE_ARCH" != "$LOCAL_ARCH" ]]; then
  echo "==> Skipping image transfer (remote ${REMOTE_ARCH} != local ${LOCAL_ARCH}); will build on VM."
fi

REMOTE_ENV="ORACLE_STACK=${ORACLE_STACK} RESET_DB=${RESET_DB:-true}"
if [[ -n "${SMTP_PASSWORD:-}" ]]; then
  REMOTE_ENV="${REMOTE_ENV} SMTP_PASSWORD=$(printf '%q' "$SMTP_PASSWORD")"
fi
if [[ -n "${OTP_EMAIL_TO:-}" ]]; then
  REMOTE_ENV="${REMOTE_ENV} OTP_EMAIL_TO=$(printf '%q' "$OTP_EMAIL_TO")"
fi

echo "==> Running oracle-setup.sh on Oracle..."
ssh -i "$SSH_KEY" -o StrictHostKeyChecking=accept-new "$ORACLE_HOST" \
  "cd ~/healthos && ${REMOTE_ENV} bash deploy/oracle-setup.sh"

ORACLE_IP="${ORACLE_HOST#*@}"
echo "==> Done. Test: curl -s http://${ORACLE_IP}:8080/actuator/health"
echo "    Then set Vercel healthos-api BACKEND_URL=http://${ORACLE_IP}:8080"
