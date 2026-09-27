#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

# shellcheck source=progress.sh
source "$ROOT/ops/scripts/progress.sh"
# shellcheck source=lib/replica.sh
source "$ROOT/ops/scripts/lib/replica.sh"

export FALCON_BACKEND_DIR="${FALCON_BACKEND_DIR:-$ROOT/backend}"

cd "$FALCON_BACKEND_DIR"

prog_run "Stopping local replica" stop_local_replica
prog_ok "Local replica stopped"
