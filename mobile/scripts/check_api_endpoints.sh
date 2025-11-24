#!/usr/bin/env bash
set -euo pipefail

# Usage:
#  ./scripts/check_api_endpoints.sh https://repairshop.thefallenpc.com /api/health /api/backups/download /api/items
# If no endpoints provided, default to /api and /api/health

if [ $# -lt 1 ]; then
  echo "Usage: $0 <base_url> [endpoint ...]"
  exit 1
fi

BASE=$1
shift || true
ENDPOINTS=("/api" "/api/health")
if [ $# -gt 0 ]; then
  ENDPOINTS=($@)
fi

for ep in "${ENDPOINTS[@]}"; do
  URL="$BASE$ep"
  echo "\n--- Checking $URL ---"
  echo "HEAD:"
  curl -I --location --silent --show-error "$URL" || true
  echo "\nFirst 128 bytes (hex):"
  curl -sS --location "$URL" | head -c 128 | xxd -p -c 128 || true
  echo "\nFull response (truncated to 1200 bytes):"
  curl -sS --location "$URL" | head -c 1200 || true
  echo "\n"
done

echo "Done"
