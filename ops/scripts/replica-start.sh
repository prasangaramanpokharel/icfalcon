#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

# shellcheck source=progress.sh
source "$ROOT/ops/scripts/progress.sh"
# shellcheck source=lib/replica.sh
source "$ROOT/ops/scripts/lib/replica.sh"

export FALCON_BACKEND_DIR="${FALCON_BACKEND_DIR:-$ROOT/backend}"
export FALCON_CANISTER="${FALCON_CANISTER:-app}"

cd "$FALCON_BACKEND_DIR"

if replica_is_running; then
  prog_ok "Local replica already running"
else
  prog_run "Starting local replica" start_local_replica
  prog_ok "Local replica started"
fi

prog_info "API" "$(replica_api_url)"

canister_id="$(replica_canister_id)"
if [[ -n "$canister_id" ]]; then
  prog_info "Canister" "$canister_id"
fi
