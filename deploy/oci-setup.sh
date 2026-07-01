#!/usr/bin/env bash
#
# Finish OCI CLI auth after uploading ~/.oci/oci_api_key_public.pem in the console.
#
#   export OCI_USER_OCID=ocid1.user.oc1..aaaa...
#   export OCI_TENANCY_OCID=ocid1.tenancy.oc1..aaaa...
#   bash deploy/oci-setup.sh
#
set -euo pipefail

export PATH="${HOME}/lib/oracle-cli/bin:${PATH}"

OCI_USER_OCID="${OCI_USER_OCID:-}"
OCI_TENANCY_OCID="${OCI_TENANCY_OCID:-}"
OCI_REGION="${OCI_REGION:-ap-mumbai-1}"
KEY_FILE="${OCI_KEY_FILE:-${HOME}/.oci/oci_api_key.pem}"
CONFIG_FILE="${OCI_CONFIG_FILE:-${HOME}/.oci/config}"

if [[ -z "$OCI_USER_OCID" || -z "$OCI_TENANCY_OCID" ]]; then
  echo "ERROR: Set OCI_USER_OCID and OCI_TENANCY_OCID"
  echo ""
  echo "Find them in Oracle Console (profile menu, top right):"
  echo "  Tenancy: <name>  → copy OCID"
  echo "  My profile       → copy OCID"
  echo ""
  echo "Upload API public key first:"
  echo "  My profile → API keys → Add API key → Paste public key"
  echo "  Public key file: ${HOME}/.oci/oci_api_key_public.pem"
  exit 1
fi

if [[ ! -f "$KEY_FILE" ]]; then
  echo "ERROR: Private key not found: $KEY_FILE"
  exit 1
fi

mkdir -p "$(dirname "$CONFIG_FILE")"
FINGERPRINT="$(openssl rsa -pubout -outform DER -in "$KEY_FILE" 2>/dev/null | openssl md5 -c | awk '{print $2}')"

cat > "$CONFIG_FILE" <<EOF
[DEFAULT]
user=${OCI_USER_OCID}
fingerprint=${FINGERPRINT}
tenancy=${OCI_TENANCY_OCID}
region=${OCI_REGION}
key_file=${KEY_FILE}
EOF
chmod 600 "$CONFIG_FILE"

echo "==> Wrote ${CONFIG_FILE}"
echo "==> Verifying..."
oci iam availability-domain list --compartment-id "$OCI_TENANCY_OCID" --query 'data[].name' --raw-output
echo "==> OCI CLI is ready. Create VM: bash deploy/oracle-create-instance.sh"
