#!/usr/bin/env bash
#
# Vercel build step for the NutriKit Flutter web app.
# Vercel has no native Flutter support, so we fetch the SDK on the build
# machine and compile the web bundle into build/web (the Output Directory).
#
# Configure these as Vercel Project -> Settings -> Environment Variables:
#   API_URL    https URL of the HealthOS api-gateway   (required unless MOCK_AUTH=true)
#   MOCK_AUTH  false  -> real phone auth + user saved to Postgres   (default: false)
#   USE_MOCK   true   -> content screens use mock data              (default: true)
#                        (the backend has no /v1/* content endpoints yet)
#   FLUTTER_CHANNEL  stable (default)
#
set -euo pipefail

FLUTTER_CHANNEL="${FLUTTER_CHANNEL:-stable}"
FLUTTER_HOME="${FLUTTER_HOME:-$HOME/flutter}"

API_URL="${API_URL:-}"
USE_MOCK="${USE_MOCK:-true}"
MOCK_AUTH="${MOCK_AUTH:-true}"

if [[ "${MOCK_AUTH}" != "true" && -z "${API_URL}" ]]; then
  echo "ERROR: MOCK_AUTH=${MOCK_AUTH} but API_URL is empty."
  echo "       Set API_URL to the public https URL of your api-gateway in"
  echo "       Vercel project env vars, or set MOCK_AUTH=true for a demo build."
  exit 1
fi

echo "==> Installing Flutter ($FLUTTER_CHANNEL)..."
if [[ ! -x "$FLUTTER_HOME/bin/flutter" ]]; then
  git clone --depth 1 -b "$FLUTTER_CHANNEL" https://github.com/flutter/flutter.git "$FLUTTER_HOME"
fi
export PATH="$FLUTTER_HOME/bin:$PATH"

git config --global --add safe.directory "$FLUTTER_HOME" || true
flutter --version
flutter config --enable-web --no-analytics

echo "==> Resolving dependencies..."
flutter pub get

echo "==> Building web (API_URL='${API_URL}' USE_MOCK=${USE_MOCK} MOCK_AUTH=${MOCK_AUTH})..."
flutter build web --release \
  --dart-define=API_URL="${API_URL}" \
  --dart-define=USE_MOCK="${USE_MOCK}" \
  --dart-define=MOCK_AUTH="${MOCK_AUTH}"

echo "==> Done. Output in build/web"
