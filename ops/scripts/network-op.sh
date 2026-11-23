#!/usr/bin/env bash
set -euo pipefail

SUBCOMMAND="${1:-status}"
shift || true

ROOT="${FALCON_ROOT:-$(cd "$(dirname "$0")/../.." && pwd)}"

cd "$ROOT"

if command -v icp >/dev/null 2>&1; then
  case "$SUBCOMMAND" in
    start)
      icp network start "$@"
      ;;
    stop)
      icp network stop "$@"
      ;;
    ping)
      icp network ping "$@"
      ;;
    status)
      icp network status "$@"
      ;;
    list|ls)
      icp network list "$@"
      ;;
    update)
      icp network update "$@"
      ;;
    *)
      icp network "$SUBCOMMAND" "$@"
      ;;
  esac
else
  case "$SUBCOMMAND" in
    start)
      bash "$ROOT/ops/scripts/replica-start.sh" "$@"
      ;;
    stop)
      bash "$ROOT/ops/scripts/replica-stop.sh" "$@"
      ;;
    ping)
      cd "$ROOT/backend"
      dfx ping "$@"
      ;;
    *)
      echo "Network command $SUBCOMMAND not supported by fallback. Please install icp-cli: npm install -g @icp-sdk/icp-cli"
      exit 1
      ;;
  esac
fi
