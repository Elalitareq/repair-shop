#!/usr/bin/env bash
set -euo pipefail

# Deploy built Flutter web assets to a remote server using rsync.
# Usage:
#  ./scripts/deploy_to_server.sh --host root@1.2.3.4 --remote-path /var/www/repair_shop/build/web --base-url https://repairshop.thefallenpc.com --reload
# Options:
#   --host         Required: user@host for SSH/rsync
#   --remote-path  Required: absolute path on the remote server to copy build/web/ into
#   --port         Optional: SSH port (default: 22)
#   --reload       Optional: if present, will run 'sudo nginx -t && sudo systemctl reload nginx'
#   --chown        Optional: user:group to chown the deployed files (e.g., www-data:www-data)
#   --base-url     Optional: base URL used by check_server_assets.sh (if you want a post-deploy health check)

print_usage() {
  sed -n '1,200p' <<'EOF'
Usage: deploy_to_server.sh --host user@host --remote-path /remote/path [--port 22] [--reload] [--chown owner:group] [--base-url https://example.com]

Examples:
  ./scripts/deploy_to_server.sh --host root@1.2.3.4 --remote-path /var/www/repair_shop/build/web --reload --base-url https://repairshop.thefallenpc.com
  ./scripts/deploy_to_server.sh --host deploy@server --remote-path /srv/repair_shop --port 2222 --chown www-data:www-data
EOF
}

if [ $# -eq 0 ]; then
  print_usage
  exit 1
fi

HOST=""
REMOTE_PATH=""
PORT=22
RELOAD=false
CHOWN=""
BASE_URL=""

while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    --host)
      HOST="$2"
      shift; shift
      ;;
    --remote-path)
      REMOTE_PATH="$2"
      shift; shift
      ;;
    --port)
      PORT="$2"
      shift; shift
      ;;
    --reload)
      RELOAD=true
      shift
      ;;
    --chown)
      CHOWN="$2"
      shift; shift
      ;;
    --base-url)
      BASE_URL="$2"
      shift; shift
      ;;
      --api-base-url)
      API_BASE_URL="$2"
      shift; shift
      ;;
      --env-file)
        ENV_FILE="$2"
        shift; shift
        ;;
    -h|--help)
      print_usage
      exit 0
      ;;
    *)
      echo "Unknown option $1"
      print_usage
      exit 1
      ;;
  esac
done

if [ -z "$HOST" ] || [ -z "$REMOTE_PATH" ]; then
  echo "--host and --remote-path are required"
  print_usage
  exit 1
fi

BUILD_DIR="$(pwd)/build/web"
ENV_FILE="${ENV_FILE:-}"
if [ ! -d "$BUILD_DIR" ]; then
  echo "Build directory not found: $BUILD_DIR"
  echo "Build the web artifacts first: flutter build web"
  exit 1
fi

echo "Deploying $BUILD_DIR -> $HOST:$REMOTE_PATH (port $PORT)"

# Ensure trailing slash to copy contents of build/web
REMOTE_PATH_TRIMMED="$REMOTE_PATH"

echo "Starting rsync..."
# If an API_BASE_URL override is provided, create a runtime `.env` inside build assets
if [ -n "${API_BASE_URL-}" ]; then
  echo "Creating runtime .env in build assets with API_BASE_URL=$API_BASE_URL"
  mkdir -p "$BUILD_DIR/assets"
  echo "API_BASE_URL=$API_BASE_URL" > "$BUILD_DIR/assets/.env"
fi

if [ -n "$ENV_FILE" ]; then
  if [ -f "$ENV_FILE" ]; then
    echo "Copying env file $ENV_FILE into build assets"
    mkdir -p "$BUILD_DIR/assets"
    cp "$ENV_FILE" "$BUILD_DIR/assets/.env"
  else
    echo "Env file $ENV_FILE not found. Skipping."
  fi
fi

echo "Ensuring remote directory exists: $REMOTE_PATH_TRIMMED"
ssh -p "$PORT" "$HOST" "mkdir -p '$REMOTE_PATH_TRIMMED' || true"

# Sync entire build directory
rsync -avz -e "ssh -p $PORT" --delete --progress "$BUILD_DIR/" "$HOST:$REMOTE_PATH_TRIMMED/"

if [ -n "$CHOWN" ]; then
  echo "Setting owner on remote files to $CHOWN"
  ssh -p "$PORT" "$HOST" "sudo chown -R $CHOWN '$REMOTE_PATH_TRIMMED' || true"
fi

if [ "$RELOAD" = true ]; then
  echo "Testing nginx config and reloading..."
  ssh -p "$PORT" "$HOST" "sudo nginx -t && sudo systemctl reload nginx"
fi

if [ -n "$BASE_URL" ]; then
  echo "Running post-deploy asset checks against: $BASE_URL"
  # Run the server asset check script (requires curl and check script in repo)
  # This runs locally and verifies remote responses
  if [ -x "./scripts/check_server_assets.sh" ]; then
    ./scripts/check_server_assets.sh "$BASE_URL"
  else
    echo "Warning: check_server_assets.sh not found or not executable. Skipping check."
  fi
fi

echo "Deploy complete."
