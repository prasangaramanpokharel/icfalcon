#!/usr/bin/env bash
set -euo pipefail

SUBCOMMAND="${1:-status}"
shift || true

ROOT="${FALCON_ROOT:-$(cd "$(dirname "$0")/../.." && pwd)}"
CANISTER="${FALCON_CANISTER:-app}"
ENV="${FALCON_ENV:-local}"
[[ "${FALCON_NETWORK:-}" == "--network ic" ]] && ENV="ic"

cd "$ROOT"

if command -v icp >/dev/null 2>&1 && [[ -f "$ROOT/icp.yaml" ]]; then
  case "$SUBCOMMAND" in
    create)
      icp canister create "$CANISTER" -e "$ENV" "$@"
      ;;
    start)
      icp canister start "$CANISTER" -e "$ENV" "$@"
      ;;
    stop)
      icp canister stop "$CANISTER" -e "$ENV" "$@"
      ;;
    delete|del)
      icp canister delete "$CANISTER" -e "$ENV" "$@"
      ;;
    install)
      icp canister install "$CANISTER" -e "$ENV" "$@"
      ;;
    uninstall)
      icp canister uninstall "$CANISTER" -e "$ENV" "$@"
      ;;
    metadata|meta)
      icp canister metadata "$CANISTER" -e "$ENV" "$@"
      ;;
    settings)
      icp canister settings -e "$ENV" "$@"
      ;;
    sync)
      icp sync "$CANISTER" -e "$ENV" "$@"
      ;;
    status)
      icp canister status "$CANISTER" -e "$ENV" "$@"
      ;;
    logs)
      icp canister logs "$CANISTER" -e "$ENV" "$@"
      ;;
    *)
      icp canister "$SUBCOMMAND" "$CANISTER" -e "$ENV" "$@"
      ;;
  esac
else
  NET="local"
  [[ "$ENV" == "ic" ]] && NET="ic"
  cd "$ROOT/backend"
  case "$SUBCOMMAND" in
    create)
      dfx canister create "$CANISTER" --network "$NET" "$@"
      ;;
    start)
      dfx canister start "$CANISTER" --network "$NET" "$@"
      ;;
    stop)
      dfx canister stop "$CANISTER" --network "$NET" "$@"
      ;;
    delete|del)
      dfx canister delete "$CANISTER" --network "$NET" "$@"
      ;;
    install)
      dfx canister install "$CANISTER" --network "$NET" "$@"
      ;;
    uninstall)
      dfx canister uninstall-code "$CANISTER" --network "$NET" "$@"
      ;;
    metadata|meta)
      dfx canister metadata "$CANISTER" "$@" --network "$NET"
      ;;
    status)
      dfx canister status "$CANISTER" --network "$NET" "$@"
      ;;
    logs)
      dfx canister logs "$CANISTER" --network "$NET" "$@"
      ;;
    *)
      dfx canister "$SUBCOMMAND" "$CANISTER" --network "$NET" "$@"
      ;;
  esac
fi
