#!/usr/bin/env bash
# Create GitHub issues from project task list
# Usage:
#   export GITHUB_TOKEN=ghp_xxx
#   ./scripts/create_github_issues.sh Elalitareq/repair-shop

set -euo pipefail

if [ -z "${1-}" ]; then
  echo "Usage: $0 <owner/repo>"
  exit 1
fi

REPO=$1
TOKEN=${GITHUB_TOKEN:-}

if [ -z "$TOKEN" ]; then
  echo "Set GITHUB_TOKEN environment variable with a token that has repo:issue scope."
  exit 1
fi

# Define issues to create
issues=(
"Items: Implement Items CRUD + IMEI validation|Backend endpoints (GET/POST/PUT/DELETE /items), IMEI uniqueness, validation, and search indexing. Connect to Flutter ItemService.",
"Items: Image upload & management|Add item image upload API, storage path, and mobile upload support. Include thumbnails and metadata.",
"Repairs: Implement repairs CRUD + state workflow|Create repair CRUD endpoints, state transitions, issue tracking, and images upload. Add lifecycle workflow and kanban UI.",
"Sales: Improve payment processing & receipts|Support multiple payment methods, partial payments, refund handling, and PDF receipt generation.",
"Sync: Build offline-first sync with conflict resolution|Design and implement incremental sync, conflict detection and resolution strategy, and test offline queue handling.",
"Stock: Stock movement history + low-stock optimizations|Add movement history, audit logs, and optimize low stock queries for large datasets (raw SQL or DB views).",
"Mobile: Connect Flutter providers to TypeScript API|Wire providers to TypeScript endpoints, implement auth token handling, and test end-to-end.",
"Images: Cloud image storage + compression pipeline|Implement S3-compatible storage support, compression, dedupe and sync support for mobile images.",
"Security: Production hardening & replace default creds|Replace seed password, audit role permissions, rate limiting, and token refresh policies.",
"Testing: Add unit/integration tests + CI pipeline|Add backend unit/integration tests, mobile tests, and create CI workflows for lint, test, and build steps."
)

# Create issues
echo "Ensuring labels exist: priority:high and backend"
# create labels if they don't exist (ignore errors if already present)
curl -s -X POST "https://api.github.com/repos/${REPO}/labels" \
  -H "Authorization: token ${TOKEN}" \
  -H "Accept: application/vnd.github.v3+json" \
  -d '{"name":"priority:high","color":"b60205","description":"High priority work"}' || true

curl -s -X POST "https://api.github.com/repos/${REPO}/labels" \
  -H "Authorization: token ${TOKEN}" \
  -H "Accept: application/vnd.github.v3+json" \
  -d '{"name":"backend","color":"0e8a16","description":"Backend work"}' || true

for issue in "${issues[@]}"; do
  title="${issue%%|*}"
  body="${issue#*|}"
  echo "Creating issue: $title"
  curl -s -X POST "https://api.github.com/repos/${REPO}/issues" \
    -H "Authorization: token ${TOKEN}" \
    -H "Accept: application/vnd.github.v3+json" \
    -d "{\"title\": \"${title}\", \"body\": \"${body}\", \"labels\": [\"priority:high\", \"backend\"] }"
  echo -e "\n"
done

echo "Done creating issues."
