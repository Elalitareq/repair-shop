#!/usr/bin/env bash
set -euo pipefail

# Usage: ./check_server_assets.sh https://repairshop.thefallenpc.com
if [ $# -ne 1 ]; then
  echo "Usage: $0 <base_url>"
  exit 1
fi

BASE=$1
echo "Checking assets at: $BASE"

check_asset() {
  url="$BASE$1"
  echo "\nChecking $url"
  echo "HEAD:"
  curl -I --silent --show-error "$url" || true
  echo "First 16 bytes (hex):"
  curl -sS "$url" | head -c 16 | xxd -p -c 16 || true
}

check_asset "/icons/Icon-192.png"
check_asset "/icons/Icon-512.png"
check_asset "/favicon.png"
check_asset "/manifest.json"
check_asset "/flutter_service_worker.js"
check_asset "/flutter_bootstrap.js"

echo "\nDone. Inspect the headers and first bytes above. PNG files should start with 89504e470d0a1a0a (hex). JS files should show ascii in bytes."
