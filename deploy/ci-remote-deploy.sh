#!/usr/bin/env bash
#
# Run on the VM from GitHub Actions (or locally via SSH) after rsync.
# Configures .env from environment variables, then starts the stack via oracle-setup.sh.
#
#   ORACLE_STACK=dev RESET_DB=false JWT_SECRET=... bash deploy/ci-remote-deploy.sh
#
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_DIR"

ORACLE_STACK="${ORACLE_STACK:-dev}"
RESET_DB="${RESET_DB:-false}"

if [[ ! -f .env ]]; then
  cp .env.example .env
fi

upsert_env() {
  local key="$1" val="$2"
  if grep -q "^${key}=" .env; then
    sed -i "s|^${key}=.*|${key}=${val}|" .env
  else
    echo "${key}=${val}" >> .env
  fi
}

if [[ -n "${JWT_SECRET:-}" ]]; then
  upsert_env JWT_SECRET "$JWT_SECRET"
fi

upsert_env NOTIFICATION_ENABLED "${NOTIFICATION_ENABLED:-true}"
upsert_env OTP_EMAIL_TO "${OTP_EMAIL_TO:-prajual.sharma.1559@gmail.com}"
upsert_env SMTP_HOST "${SMTP_HOST:-smtp.gmail.com}"
upsert_env SMTP_PORT "${SMTP_PORT:-587}"
upsert_env SMTP_USERNAME "${SMTP_USERNAME:-${OTP_EMAIL_TO:-prajual.sharma.1559@gmail.com}}"
upsert_env SMTP_FROM "${SMTP_FROM:-${OTP_EMAIL_TO:-prajual.sharma.1559@gmail.com}}"
upsert_env SMTP_ENABLED "${SMTP_ENABLED:-true}"

if [[ "$ORACLE_STACK" == "dev" ]]; then
  upsert_env NOTIFICATION_ENABLED "false"
  upsert_env OTP_DEV_BYPASS "true"
  upsert_env DEV_OTP_CODE "${DEV_OTP_CODE:-123456}"
  upsert_env KAFKA_NOTIFICATIONS_ENABLED "true"
  upsert_env KAFKA_BOOTSTRAP_SERVERS "kafka:9092"
  upsert_env NOTIFICATION_TOPIC "notification-topic"
  upsert_env ONBOARDING_REMINDER_DELAY_MINUTES "${ONBOARDING_REMINDER_DELAY_MINUTES:-120}"
  upsert_env NUTRIKIT_RESUME_BASE_URL "${NUTRIKIT_RESUME_BASE_URL:-https://nutrikit.vercel.app}"
elif [[ -n "${SMTP_PASSWORD:-}" ]]; then
  upsert_env SMTP_PASSWORD "$SMTP_PASSWORD"
  upsert_env OTP_DEV_BYPASS "false"
else
  echo "WARNING: SMTP_PASSWORD not set — OTP_DEV_BYPASS stays enabled"
  upsert_env OTP_DEV_BYPASS "true"
fi

export ORACLE_STACK RESET_DB
bash deploy/oracle-setup.sh
