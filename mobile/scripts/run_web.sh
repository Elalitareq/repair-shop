#!/usr/bin/env bash
set -euo pipefail

# Start a debugging run for web (Chrome) and ensure the build regenerates and streamlines the run
# Usage: ./scripts/run_web.sh

pushd "$(dirname "$0")/.." >/dev/null

# Ensure packages and web enabled
flutter pub get
flutter config --enable-web || true

# Use chrome by default
DEVICE=${1:-chrome}

# Forward all args to flutter run
flutter run -d "$DEVICE"

popd >/dev/null
