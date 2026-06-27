#!/usr/bin/env bash
# Build Flutter web and deploy to Vercel (static demo).
#
# First-time setup (once):
#   npx vercel login
# Or set a token from https://vercel.com/account/tokens:
#   export VERCEL_TOKEN=your_token
#
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

FLUTTER="${FLUTTER:-$HOME/flutter/bin/flutter}"
if [[ ! -x "$FLUTTER" ]]; then
  echo "Flutter not found at $FLUTTER. Set FLUTTER=/path/to/flutter or install Flutter."
  exit 1
fi

echo "==> Building Flutter web (release)..."
"$FLUTTER" build web --release

echo "==> Writing SPA rewrite for go_router deep links..."
cat > build/web/vercel.json <<'EOF'
{
  "rewrites": [{ "source": "/(.*)", "destination": "/index.html" }]
}
EOF

echo "==> Checking Vercel auth..."
if ! npx --yes vercel whoami &>/dev/null; then
  if [[ -z "${VERCEL_TOKEN:-}" ]]; then
    echo ""
    echo "Not logged in to Vercel."
    echo "  Run:  npx vercel login"
    echo "  Or:   export VERCEL_TOKEN=<token from vercel.com/account/tokens>"
    echo "Then re-run: ./deploy.sh"
    echo ""
    echo "Build is ready at build/web — you can also drag that folder to https://app.netlify.com/drop"
    exit 1
  fi
fi

echo "==> Deploying to Vercel (production)..."
cd build/web
npx --yes vercel --prod --yes

echo ""
echo "Done. Share the production URL printed above."
