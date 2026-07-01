#!/usr/bin/env bash
#
# Full pipeline: OCI auth → create A1.Flex VM → wire deploy host.
#
# Prerequisites (one-time, ~2 min in Oracle Console):
#   1. Profile → API keys → Add API key → Paste public key
#      cat ~/.oci/oci_api_key_public.pem
#   2. Copy User OCID (My profile) and Tenancy OCID (Tenancy: <name>)
#   3. Fill deploy/oci-credentials.env from oci-credentials.env.example
#
# Then:
#   bash deploy/oci-go.sh
#
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CREDS="${REPO_DIR}/deploy/oci-credentials.env"
[[ -f "$CREDS" ]] && source "$CREDS"
[[ -f "${HOME}/.oci/oci-credentials.env" ]] && source "${HOME}/.oci/oci-credentials.env"

export PATH="${HOME}/lib/oracle-cli/bin:${PATH}"
export OCI_USER_OCID OCI_TENANCY_OCID OCI_REGION

bash "${REPO_DIR}/deploy/oci-setup.sh"
bash "${REPO_DIR}/deploy/oracle-create-instance.sh" | tee /tmp/healthos-oracle-create.log

PUBLIC_IP="$(grep -oP 'Public IP: \K[0-9.]+' /tmp/healthos-oracle-create.log | tail -1 || true)"
if [[ -n "$PUBLIC_IP" ]]; then
  ORACLE_USER=ubuntu bash "${REPO_DIR}/deploy/wire-oracle.sh" "$PUBLIC_IP"
  echo ""
  echo "==> VM ready at ${PUBLIC_IP}. Opening security list note:"
  echo "    Allow TCP 22 and 8080 in VCN Security List, then:"
  echo "    bash deploy/oracle-deploy.sh"
fi
