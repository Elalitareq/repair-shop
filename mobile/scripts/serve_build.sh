#!/usr/bin/env bash
set -euo pipefail

# Serve the built web artifacts using a small web server.
# Usage:
#  ./scripts/serve_build.sh [port]
#  Example: ./scripts/serve_build.sh 8000

BUILD_DIR="$(dirname "${BASH_SOURCE[0]}")/../build/web"
PORT=${1:-8000}

if [ ! -d "$BUILD_DIR" ]; then
  echo "Build output not found at: $BUILD_DIR"
  echo "Please run 'flutter build web' first or use ./scripts/rebuild_web.sh"
  exit 1
fi

# Prefer the built-in python http server if available
if command -v python3 >/dev/null 2>&1; then
  echo "Serving $BUILD_DIR on http://localhost:$PORT (python3 -m http.server)"
  pushd "$BUILD_DIR" >/dev/null
  python3 -m http.server "$PORT"
  popd >/dev/null
  exit 0
fi

# Fallback to node http-server if installed
if command -v http-server >/dev/null 2>&1; then
  echo "Serving $BUILD_DIR on http://localhost:$PORT (http-server)"
  http-server "$BUILD_DIR" -p "$PORT"
  exit 0
fi

# If neither tool is available, provide instructions
cat <<'EOF'

No suitable web server found. Install one of these commands:

  python3 (already installed on most systems)
    brew install python
  or
  http-server
    npm i -g http-server

Then run:
  ./scripts/serve_build.sh 8000

EOF
exit 1
