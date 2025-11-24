#!/usr/bin/env bash
set -euo pipefail

# Search for web_entrypoint.dart or other related generated files

echo "Searching for web entrypoint artifacts..."

# Search common build locations
SEARCH_DIRS=(
  "build"
  ".dart_tool"
  "build/web"
)

found=0
for d in "${SEARCH_DIRS[@]}"; do
  if [ -d "$d" ]; then
    echo "Searching $d..."
    matches=$(find "$d" -type f -name "*web_entrypoint*" -print || true)
    if [ -n "$matches" ]; then
      echo "Found:"
      echo "$matches"
      found=1
    fi
  fi
done

if [ $found -eq 0 ]; then
  echo "No web entrypoint artifacts found. Consider running ./scripts/rebuild_web.sh"
fi
