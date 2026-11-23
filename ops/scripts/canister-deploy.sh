#!/usr/bin/env bash
# canister-deploy.sh — Deploy canisters using icp-cli (with dfx fallback and auto-start)
set -euo pipefail

ROOT="${FALCON_ROOT:-$(cd "$(dirname "$0")/../.." && pwd)}"
CANISTER="${FALCON_CANISTER:-app}"
ENV="${FALCON_ENV:-local}"
[[ "${FALCON_NETWORK:-}" == "--network ic" ]] && ENV="ic"

cd "$ROOT"

# Auto-ensure replica is running if deploying to local
if [[ "$ENV" == "local" ]]; then
  # shellcheck source=lib/replica.sh
  source "$ROOT/ops/scripts/lib/replica.sh"
  if ! replica_is_running; then
    echo "==> Local replica is not running — auto-starting local network..."
    start_local_replica
    echo "==> Local network ready on $(replica_api_url)"
  fi
fi

if command -v icp >/dev/null 2>&1 && [[ -f "$ROOT/icp.yaml" ]]; then
  echo "==> Deploying with icp-cli ($CANISTER to $ENV)"
  icp deploy "$CANISTER" -e "$ENV" "$@"
else
  NET="local"
  [[ "$ENV" == "ic" ]] && NET="ic"
  echo "==> Deploying with dfx fallback ($CANISTER to $NET)"
  cd "$ROOT/backend"
  dfx canister create "$CANISTER" --network "$NET" "$@" 2>/dev/null || true
  dfx build "$CANISTER" --network "$NET" "$@"
  dfx deploy "$CANISTER" --mode=upgrade --wasm-memory-persistence keep --network "$NET" "$@" 2>/dev/null \
    || dfx deploy "$CANISTER" --network "$NET" "$@"
fi

# Sync frontend environment when deploying locally
if [[ "$ENV" == "local" && -d "$ROOT/frontend" ]]; then
  # shellcheck source=lib/replica.sh
  source "$ROOT/ops/scripts/lib/replica.sh"
  CAN_ID="$(replica_canister_id)"
  HOST="$(replica_api_url)"
  if [[ -n "$CAN_ID" ]]; then
    cat > "$ROOT/frontend/.env.local" <<EOF
NEXT_PUBLIC_CANISTER_ID=$CAN_ID
NEXT_PUBLIC_IC_HOST=$HOST
NEXT_PUBLIC_II_URL=https://identity.ic0.app
EOF
    echo "==> Synced frontend/.env.local: Canister ID ($CAN_ID) at $HOST"
  fi
fi
