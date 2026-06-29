#!/usr/bin/env bash
#
# Sync repo to EC2 and run aws-setup.sh.
# Requires: SSH_KEY path to prajwalkey.pem
#
#   export SSH_KEY=~/path/to/prajwalkey.pem
#   bash deploy/ec2-deploy.sh
#
set -euo pipefail

EC2_HOST="${EC2_HOST:-ec2-user@65.0.109.103}"
SSH_KEY="${SSH_KEY:?Set SSH_KEY to your prajwalkey.pem path}"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

chmod 600 "$SSH_KEY"

echo "==> Syncing Health-Os to ${EC2_HOST}..."
ssh -i "$SSH_KEY" -o StrictHostKeyChecking=accept-new "$EC2_HOST" 'mkdir -p ~/healthos'

rsync -avz --delete \
  -e "ssh -i $SSH_KEY -o StrictHostKeyChecking=accept-new" \
  --exclude '.git' \
  --exclude '**/build/' \
  --exclude '**/target/' \
  --exclude '**/.dart_tool/' \
  --exclude '**/node_modules/' \
  --exclude '**/.vercel/' \
  --exclude 'kitchen_app/build/' \
  --exclude 'nutrikit/build/' \
  --exclude 'healthos_flutter/build/' \
  "$REPO_DIR/" "${EC2_HOST}:~/healthos/"

echo "==> Running aws-setup.sh on EC2 (this takes 10–15 min on first build)..."
ssh -i "$SSH_KEY" -o StrictHostKeyChecking=accept-new "$EC2_HOST" \
  'cd ~/healthos && bash deploy/aws-setup.sh'

echo "==> Done. Test: curl -s http://65.0.109.103:8080/actuator/health"
