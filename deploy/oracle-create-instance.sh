#!/usr/bin/env bash
#
# Create an Always Free A1.Flex Ubuntu VM in Oracle Cloud (ap-mumbai-1).
# Requires OCI CLI: https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm
#
# One-time setup:
#   oci setup config
#   # upload ssh-key-2026-06-30.key.pub when prompted
#
# Then:
#   bash deploy/oracle-create-instance.sh
#
set -euo pipefail

INSTANCE_NAME="${INSTANCE_NAME:-HealthOs}"
SHAPE="${SHAPE:-VM.Standard.A1.Flex}"
OCPUS="${OCPUS:-2}"
MEMORY_GB="${MEMORY_GB:-12}"
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

COMPARTMENT_ID="$(oci iam compartment list --compartment-id-in-subtree true --all \
  --query "data[?name=='$(oci iam compartment list --query 'data[0].name' --raw-output 2>/dev/null || echo root)'].id | [0]" \
  --raw-output 2>/dev/null || true)"

if [[ -z "$COMPARTMENT_ID" || "$COMPARTMENT_ID" == "null" ]]; then
  COMPARTMENT_ID="$(oci iam compartment list --query 'data[0].id' --raw-output)"
fi

echo "==> Using compartment: $COMPARTMENT_ID"
echo "==> Region: $REGION"

AVAILABILITY_DOMAIN="$(oci iam availability-domain list \
  --compartment-id "$COMPARTMENT_ID" \
  --query 'data[0].name' --raw-output)"
echo "==> Availability domain: $AVAILABILITY_DOMAIN"

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
  --query 'data[?\"prohibit-public-ip-on-vnic\"==\`false\`] | [0].id' --raw-output)"

if [[ -z "$SUBNET_ID" || "$SUBNET_ID" == "null" ]]; then
  SUBNET_ID="$(oci network subnet list --compartment-id "$COMPARTMENT_ID" --vcn-id "$VCN_ID" \
    --query 'data[0].id' --raw-output)"
fi
echo "==> Subnet: $SUBNET_ID"

SSH_KEY_CONTENT="$(cat "$SSH_PUB_KEY")"

echo "==> Launching $INSTANCE_NAME ($SHAPE: ${OCPUS} OCPU / ${MEMORY_GB} GB)..."
INSTANCE_JSON="$(oci compute instance launch \
  --availability-domain "$AVAILABILITY_DOMAIN" \
  --compartment-id "$COMPARTMENT_ID" \
  --display-name "$INSTANCE_NAME" \
  --shape "$SHAPE" \
  --shape-config "{\"ocpus\":${OCPUS},\"memoryInGBs\":${MEMORY_GB}}" \
  --image-id "$UBUNTU_IMAGE_ID" \
  --subnet-id "$SUBNET_ID" \
  --assign-public-ip true \
  --boot-volume-size-in-gbs "$BOOT_VOLUME_GB" \
  --ssh-authorized-keys-file "$SSH_PUB_KEY" \
  --wait-for-state RUNNING)"

INSTANCE_ID="$(echo "$INSTANCE_JSON" | python3 -c "import sys,json; print(json.load(sys.stdin)['data']['id'])")"
echo "==> Instance ID: $INSTANCE_ID"

PUBLIC_IP="$(oci compute instance list-vnics \
  --instance-id "$INSTANCE_ID" \
  --query 'data[0].\"public-ip\"' --raw-output)"

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
