#!/usr/bin/env bash
set -euo pipefail

ROOT="${FALCON_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
BACKEND="${FALCON_BACKEND_DIR:-$ROOT/backend}"
cd "$BACKEND"

METHOD="${1:-}"
shift || true

[[ -n "$METHOD" ]] || { echo "usage: canister:call <method> [candid-args] [--update]"; exit 1; }

UPDATE_FLAG="--query"
ARGS=()

for arg in "$@"; do
  if [[ "$arg" == "--update" ]]; then
    UPDATE_FLAG=""
  else
    ARGS+=("$arg")
  fi
done

CANISTER="${FALCON_CANISTER:-app}"
NETWORK="${FALCON_NETWORK:-}"

if [[ -n "${ARGS[*]:-}" ]]; then
  dfx canister call "$CANISTER" "$METHOD" "${ARGS[@]}" $UPDATE_FLAG $NETWORK
else
  dfx canister call "$CANISTER" "$METHOD" $UPDATE_FLAG $NETWORK
fi
