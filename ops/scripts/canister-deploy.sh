#!/usr/bin/env bash
# canister-deploy.sh — Deploy canisters using icp-cli (with dfx fallback)
set -euo pipefail

ROOT="${FALCON_ROOT:-$(cd "$(dirname "$0")/../.." && pwd)}"
CANISTER="${FALCON_CANISTER:-app}"
ENV="${FALCON_ENV:-local}"
[[ "${FALCON_NETWORK:-}" == "--network ic" ]] && ENV="ic"

cd "$ROOT"

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
