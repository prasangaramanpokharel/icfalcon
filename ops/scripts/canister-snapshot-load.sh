#!/usr/bin/env bash
# Restore a canister snapshot
# Usage: falcon c:sn:load <snapshot-id> [--local]
set -euo pipefail

ROOT="${FALCON_ROOT:-$(cd "$(dirname "$0")/../.." && pwd)}"
BACKEND="${FALCON_BACKEND_DIR:-$ROOT/backend}"
CANISTER="${FALCON_CANISTER:-app}"
NETWORK="${FALCON_NETWORK:-}"
SNAPSHOT_ID="${1:-}"

if [[ -z "$SNAPSHOT_ID" ]]; then
  echo "Usage: falcon c:sn:load <snapshot-id> [--local]" >&2
  exit 1
fi

cd "$BACKEND"
echo "==> Stopping canister $CANISTER..."
dfx canister stop "$CANISTER" $NETWORK

echo "==> Restoring snapshot $SNAPSHOT_ID onto $CANISTER..."
dfx canister snapshot load "$CANISTER" "$SNAPSHOT_ID" $NETWORK

echo "==> Starting canister $CANISTER..."
dfx canister start "$CANISTER" $NETWORK

echo "✓ Snapshot $SNAPSHOT_ID restored successfully."
