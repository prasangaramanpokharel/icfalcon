#!/usr/bin/env bash

ROOT="${FALCON_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
BACKEND="${FALCON_BACKEND_DIR:-$ROOT/backend}"
FRONTEND="$ROOT/frontend"
export ROOT BACKEND FRONTEND FALCON_ROOT="$ROOT" FALCON_BACKEND_DIR="$BACKEND" FALCON_CANISTER="${FALCON_CANISTER:-app}"

# shellcheck source=lib/replica.sh
source "$ROOT/ops/scripts/lib/replica.sh"

deploy_local_canister() {
  "$ROOT/ops/scripts/canister-deploy.sh"
}

write_frontend_env() {
  local id host
  id="$(replica_canister_id)"
  host="$(replica_api_url)"
  cat > "$FRONTEND/.env.local" <<EOF
NEXT_PUBLIC_CANISTER_ID=$id
NEXT_PUBLIC_IC_HOST=$host
NEXT_PUBLIC_II_URL=https://identity.ic0.app
EOF
}

verify_local_ping() {
  "$ROOT/ops/scripts/canister-manage.sh" ping
}
