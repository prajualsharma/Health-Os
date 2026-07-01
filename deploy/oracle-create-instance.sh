#!/usr/bin/env bash
#
# Create an Always Free A1.Flex Ubuntu VM in Oracle Cloud (ap-mumbai-1).
# Requires OCI CLI: https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm
#
# One-time setup:
#   bash deploy/oci-setup.sh   # after uploading ~/.oci/oci_api_key_public.pem in console
#   # or: oci setup config
#
# Then:
#   bash deploy/oracle-create-instance.sh
#
set -euo pipefail

export PATH="${HOME}/lib/oracle-cli/bin:${PATH}"

CREDS_FILE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/deploy/oci-credentials.env"
if [[ -f "$CREDS_FILE" ]]; then
  # shellcheck disable=SC1090
  source "$CREDS_FILE"
fi

INSTANCE_NAME="${INSTANCE_NAME:-HealthOs}"
SHAPE="${SHAPE:-VM.Standard.A1.Flex}"
OCPUS="${OCPUS:-1}"
MEMORY_GB="${MEMORY_GB:-6}"
BOOT_VOLUME_GB="${BOOT_VOLUME_GB:-50}"
SSH_PUB_KEY="${SSH_PUB_KEY:-/home/pras/Downloads/ssh-key-2026-06-30.key.pub}"
REGION="${OCI_REGION:-ap-mumbai-1}"

if ! command -v oci >/dev/null 2>&1; then
  echo "ERROR: Install OCI CLI first: https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm"
  exit 1
fi

if [[ ! -f "$SSH_PUB_KEY" ]]; then
  echo "ERROR: SSH public key not found: $SSH_PUB_KEY"
  exit 1
fi

COMPARTMENT_ID="${OCI_TENANCY_OCID:-}"
if [[ -z "$COMPARTMENT_ID" && -f "${HOME}/.oci/config" ]]; then
  COMPARTMENT_ID="$(awk -F= '/^tenancy=/{print $2}' "${HOME}/.oci/config" | tr -d ' ')"
fi
if [[ -z "$COMPARTMENT_ID" ]]; then
  COMPARTMENT_ID="$(oci iam compartment list --compartment-id-in-subtree true --all \
    --query 'data[?name==`root`].id | [0]' --raw-output 2>/dev/null || true)"
fi
if [[ -z "$COMPARTMENT_ID" || "$COMPARTMENT_ID" == "null" ]]; then
  echo "ERROR: Set OCI_TENANCY_OCID or configure ~/.oci/config"
  exit 1
fi

echo "==> Using compartment: $COMPARTMENT_ID"
echo "==> Region: $REGION"

mapfile -t AVAILABILITY_DOMAINS < <(oci iam availability-domain list \
  --compartment-id "$COMPARTMENT_ID" \
  --query 'data[].name' --raw-output | tr -d '[],"' | tr ' ' '\n' | sed '/^$/d')
echo "==> Availability domains: ${AVAILABILITY_DOMAINS[*]}"

UBUNTU_IMAGE_ID="$(oci compute image list \
  --compartment-id "$COMPARTMENT_ID" \
  --operating-system 'Canonical Ubuntu' \
  --operating-system-version '22.04' \
  --shape "$SHAPE" \
  --sort-by TIMECREATED \
  --sort-order DESC \
  --query 'data[0].id' --raw-output)"

if [[ -z "$UBUNTU_IMAGE_ID" || "$UBUNTU_IMAGE_ID" == "null" ]]; then
  echo "ERROR: No Ubuntu 22.04 image found for $SHAPE in $REGION"
  exit 1
fi
echo "==> Image: $UBUNTU_IMAGE_ID"

VCN_ID="$(oci network vcn list --compartment-id "$COMPARTMENT_ID" \
  --query 'data[0].id' --raw-output)"
SUBNET_ID="$(oci network subnet list --compartment-id "$COMPARTMENT_ID" --vcn-id "$VCN_ID" \
  --query 'data[?"prohibit-public-ip-on-vnic"==`false`] | [0].id' --raw-output)"

if [[ -z "$SUBNET_ID" || "$SUBNET_ID" == "null" ]]; then
  SUBNET_ID="$(oci network subnet list --compartment-id "$COMPARTMENT_ID" --vcn-id "$VCN_ID" \
    --query 'data[0].id' --raw-output)"
fi
echo "==> Subnet: $SUBNET_ID"

MAX_ATTEMPTS="${MAX_ATTEMPTS:-720}"
RETRY_DELAY_SEC="${RETRY_DELAY_SEC:-120}"

echo "==> Launching $INSTANCE_NAME ($SHAPE: ${OCPUS} OCPU / ${MEMORY_GB} GB)..."
INSTANCE_JSON=""
LAST_ERR=""
for attempt in $(seq 1 "$MAX_ATTEMPTS"); do
  for ad in "${AVAILABILITY_DOMAINS[@]}"; do
    echo "==> Attempt ${attempt}/${MAX_ATTEMPTS}: availability domain ${ad}..."
    set +e
    err_file="$(mktemp)"
    INSTANCE_JSON="$(oci compute instance launch \
      --availability-domain "$ad" \
      --compartment-id "$COMPARTMENT_ID" \
      --display-name "$INSTANCE_NAME" \
      --shape "$SHAPE" \
      --shape-config "{\"ocpus\":${OCPUS},\"memoryInGBs\":${MEMORY_GB}}" \
      --image-id "$UBUNTU_IMAGE_ID" \
      --subnet-id "$SUBNET_ID" \
      --assign-public-ip true \
      --boot-volume-size-in-gbs "$BOOT_VOLUME_GB" \
      --ssh-authorized-keys-file "$SSH_PUB_KEY" \
      --wait-for-state RUNNING 2>"$err_file")"
    launch_rc=$?
    LAST_ERR="$(cat "$err_file")"
    rm -f "$err_file"
    set -e
    if [[ $launch_rc -eq 0 && -n "$INSTANCE_JSON" ]]; then
      echo "==> Launched in ${ad}"
      break 2
    fi
    if [[ "$LAST_ERR" == *"Out of capacity"* || "$LAST_ERR" == *"OutOfCapacity"* \
       || "$LAST_ERR" == *"Out of host capacity"* \
       || "$LAST_ERR" == *"TooManyRequests"* || "$LAST_ERR" == *"Too many requests"* \
       || "$LAST_ERR" == *"timed out"* || "$LAST_ERR" == *"Connection"* ]]; then
      echo "    Capacity/rate limit/network in ${ad}, trying next..."
    else
      echo "ERROR: Instance launch failed:"
      echo "$LAST_ERR"
      exit 1
    fi
  done
  if [[ $attempt -lt $MAX_ATTEMPTS ]]; then
    echo "==> All domains full. Retrying in ${RETRY_DELAY_SEC}s..."
    sleep "$RETRY_DELAY_SEC"
  fi
done

if [[ -z "$INSTANCE_JSON" ]]; then
  echo "ERROR: Out of capacity in all availability domains after ${MAX_ATTEMPTS} attempts."
  echo "Last error: $LAST_ERR"
  exit 1
fi

INSTANCE_ID="$(echo "$INSTANCE_JSON" | python3 -c "import sys,json; print(json.load(sys.stdin)['data']['id'])")"
echo "==> Instance ID: $INSTANCE_ID"

PUBLIC_IP="$(oci compute instance list-vnics \
  --instance-id "$INSTANCE_ID" \
  --query 'data[0]."public-ip"' --raw-output)"

echo ""
echo "============================================================"
echo "  Instance: $INSTANCE_NAME"
echo "  Public IP: $PUBLIC_IP"
echo "  SSH: ssh -i /home/pras/Downloads/ssh-key-2026-06-30.key ubuntu@${PUBLIC_IP}"
echo ""
echo "  Open VCN ingress TCP 22 and 8080, then:"
echo "    bash deploy/wire-oracle.sh ${PUBLIC_IP}"
echo "    bash deploy/oracle-deploy.sh"
echo "============================================================"
