#!/usr/bin/env bash
set -euo pipefail

ROOT="${FALCON_ROOT:-$(cd "$(dirname "$0")/../.." && pwd)}"
CANISTER="${FALCON_CANISTER:-app}"
ENV="${FALCON_ENV:-local}"

cd "$ROOT"

if command -v icp >/dev/null 2>&1 && [[ -f "$ROOT/icp.yaml" ]]; then
  echo "==> Building with icp-cli ($CANISTER)"
  icp build "$CANISTER"
else
  echo "==> Building with dfx ($CANISTER)"
  cd "$ROOT/backend"
  dfx build "$CANISTER"
fi
