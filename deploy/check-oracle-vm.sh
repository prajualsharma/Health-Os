#!/usr/bin/env bash
# Quick reachability check for Oracle VM before deploy.
# Usage: bash deploy/check-oracle-vm.sh 144.24.219.167
set -euo pipefail

IP="${1:-}"
if [[ -z "$IP" ]]; then
  echo "Usage: bash deploy/check-oracle-vm.sh <public-ip>"
  exit 1
fi

echo "==> Checking ${IP}..."

check_port() {
  local port="$1"
  if timeout 5 bash -c "echo >/dev/tcp/${IP}/${port}" 2>/dev/null; then
    echo "  TCP ${port}: OPEN"
    return 0
  fi
  echo "  TCP ${port}: CLOSED or filtered"
  return 1
}

SSH_OK=false
API_OK=false
check_port 22 && SSH_OK=true || true
check_port 8080 && API_OK=true || true

echo ""
if [[ "$SSH_OK" == true ]]; then
  echo "SSH reachable — run: ORACLE_HOST=opc@${IP} bash deploy/oracle-deploy.sh"
else
  echo "SSH (22) not reachable. In Oracle Console:"
  echo "  Networking → VCN → Security List → Add Ingress:"
  echo "    Source 0.0.0.0/0, TCP 22"
  echo "  Then use Instance Console Connection if sshd is not running yet."
fi

if [[ "$API_OK" == true ]]; then
  echo "API (8080) reachable — curl http://${IP}:8080/actuator/health"
else
  echo "API (8080) not reachable. Add ingress rule:"
  echo "    Source 0.0.0.0/0, TCP 8080"
  echo "  After deploy, Vercel BACKEND_URL should be http://${IP}:8080"
fi
