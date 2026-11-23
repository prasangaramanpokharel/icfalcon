#!/usr/bin/env bash
set -euo pipefail

SUBCOMMAND="${1:-balance}"
shift || true

ROOT="${FALCON_ROOT:-$(cd "$(dirname "$0")/../.." && pwd)}"
CANISTER="${FALCON_CANISTER:-app}"
ENV="${FALCON_ENV:-local}"
[[ "${FALCON_NETWORK:-}" == "--network ic" ]] && ENV="ic"

cd "$ROOT"

if command -v icp >/dev/null 2>&1; then
  case "$SUBCOMMAND" in
    balance|bal)
      icp cycles balance -e "$ENV" "$@" 2>/dev/null || icp canister status "$CANISTER" -e "$ENV" "$@"
      ;;
    mint)
      icp cycles mint -e "$ENV" "$@"
      ;;
    transfer|send)
      icp cycles transfer -e "$ENV" "$@"
      ;;
    buy)
      icp cycles buy -e "$ENV" "$@"
      ;;
    topup|top-up)
      icp canister top-up "$CANISTER" -e "$ENV" "$@"
      ;;
    *)
      icp cycles "$SUBCOMMAND" -e "$ENV" "$@"
      ;;
  esac
else
  NET="local"
  [[ "$ENV" == "ic" ]] && NET="ic"
  cd "$ROOT/backend"
  case "$SUBCOMMAND" in
    balance|bal)
      dfx canister status "$CANISTER" --network "$NET" "$@"
      ;;
    topup|top-up)
      dfx canister deposit-cycles "$@" "$CANISTER" --network "$NET"
      ;;
    *)
      echo "Cycles command $SUBCOMMAND not supported by dfx fallback. Please install icp-cli: npm install -g @icp-sdk/icp-cli"
      exit 1
      ;;
  esac
fi
