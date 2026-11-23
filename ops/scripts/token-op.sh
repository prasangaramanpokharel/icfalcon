#!/usr/bin/env bash
set -euo pipefail

SUBCOMMAND="${1:-balance}"
shift || true

ROOT="${FALCON_ROOT:-$(cd "$(dirname "$0")/../.." && pwd)}"
ENV="${FALCON_ENV:-local}"
[[ "${FALCON_NETWORK:-}" == "--network ic" ]] && ENV="ic"

cd "$ROOT"

if command -v icp >/dev/null 2>&1; then
  case "$SUBCOMMAND" in
    balance|bal)
      icp token balance -e "$ENV" "$@"
      ;;
    transfer|send)
      icp token transfer -e "$ENV" "$@"
      ;;
    approve)
      icp token approve -e "$ENV" "$@"
      ;;
    allowance)
      icp token allowance -e "$ENV" "$@"
      ;;
    *)
      icp token "$SUBCOMMAND" -e "$ENV" "$@"
      ;;
  esac
else
  NET="local"
  [[ "$ENV" == "ic" ]] && NET="ic"
  case "$SUBCOMMAND" in
    balance|bal)
      cd "$ROOT/backend"
      dfx ledger balance --network "$NET" "$@"
      ;;
    transfer|send)
      cd "$ROOT/backend"
      dfx ledger transfer --network "$NET" "$@"
      ;;
    *)
      echo "Command $SUBCOMMAND not supported by dfx fallback. Please install icp-cli: npm install -g @icp-sdk/icp-cli"
      exit 1
      ;;
  esac
fi
