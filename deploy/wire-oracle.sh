#!/usr/bin/env bash
#
# Point Vercel healthos-api proxy and local oracle-host.env at a new Oracle VM IP.
#
#   export VERCEL_TOKEN=...   # optional; from vercel.com/account/tokens
#   bash deploy/wire-oracle.sh 129.x.x.x
#
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ORACLE_IP="${1:-}"

if [[ -z "$ORACLE_IP" ]]; then
  echo "Usage: bash deploy/wire-oracle.sh <public-ip>"
  exit 1
fi

SSH_KEY="${SSH_KEY:-/home/pras/Downloads/ssh-key-2026-06-30.key}"
ORACLE_USER="${ORACLE_USER:-ubuntu}"
ORACLE_HOST="${ORACLE_USER}@${ORACLE_IP}"
BACKEND_URL="http://${ORACLE_IP}:8080"

cat > "${REPO_DIR}/deploy/oracle-host.env" <<EOF
ORACLE_HOST=${ORACLE_HOST}
SSH_KEY=${SSH_KEY}
EOF
chmod 600 "${REPO_DIR}/deploy/oracle-host.env"
echo "==> Wrote deploy/oracle-host.env (${ORACLE_HOST})"

if [[ -n "${VERCEL_TOKEN:-}" ]]; then
  echo "==> Updating Vercel BACKEND_URL=${BACKEND_URL}..."
  cd "${REPO_DIR}/deploy/vercel-api"
  printf '%s' "$BACKEND_URL" | npx vercel@54 env rm BACKEND_URL production --yes --token "$VERCEL_TOKEN" 2>/dev/null || true
  printf '%s' "$BACKEND_URL" | npx vercel@54 env add BACKEND_URL production --token "$VERCEL_TOKEN"
  npx vercel@54 deploy --prod --yes --token "$VERCEL_TOKEN"
  echo "==> Vercel proxy redeployed."
else
  echo "==> Set VERCEL_TOKEN to auto-update Vercel, or manually:"
  echo "    cd deploy/vercel-api"
  echo "    npx vercel env add BACKEND_URL production   # value: ${BACKEND_URL}"
  echo "    npx vercel --prod"
fi

echo ""
echo "==> GitHub Actions secrets (Settings → Secrets → Actions):"
echo "    EC2_HOST=${ORACLE_IP}"
echo "    EC2_USER=${ORACLE_USER}"
echo "    EC2_SSH_KEY=<contents of ${SSH_KEY}>"
echo ""
echo "==> Test: curl -s ${BACKEND_URL}/actuator/health"
