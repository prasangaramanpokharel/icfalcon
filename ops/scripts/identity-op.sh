#!/usr/bin/env bash
set -euo pipefail

SUBCOMMAND="${1:-list}"
shift || true

if command -v icp >/dev/null 2>&1; then
  case "$SUBCOMMAND" in
    whoami|current|default)
      icp identity default "$@"
      ;;
    principal|get-principal)
      icp identity principal "$@"
      ;;
    address|account-id)
      icp identity account-id "$@"
      ;;
    list|ls)
      icp identity list "$@"
      ;;
    use)
      icp identity default "$@"
      ;;
    new|create)
      icp identity new "$@"
      ;;
    export)
      icp identity export "$@"
      ;;
    import)
      icp identity import "$@"
      ;;
    delete|remove|rm)
      icp identity delete "$@"
      ;;
    rename)
      icp identity rename "$@"
      ;;
    *)
      icp identity "$SUBCOMMAND" "$@"
      ;;
  esac
else
  case "$SUBCOMMAND" in
    whoami|current|default)
      dfx identity whoami "$@"
      ;;
    principal|get-principal)
      dfx identity get-principal "$@"
      ;;
    address|account-id)
      dfx ledger account-id "$@"
      ;;
    list|ls)
      dfx identity list "$@"
      ;;
    use)
      dfx identity use "$@"
      ;;
    new|create)
      dfx identity new "$@"
      ;;
    export)
      dfx identity export "$@"
      ;;
    import)
      dfx identity import "$@"
      ;;
    delete|remove|rm)
      dfx identity remove "$@"
      ;;
    rename)
      dfx identity rename "$@"
      ;;
    *)
      dfx identity "$SUBCOMMAND" "$@"
      ;;
  esac
fi
