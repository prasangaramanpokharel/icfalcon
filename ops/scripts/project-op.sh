#!/usr/bin/env bash
set -euo pipefail

SUBCOMMAND="${1:-show}"
shift || true

ROOT="${FALCON_ROOT:-$(cd "$(dirname "$0")/../.." && pwd)}"

cd "$ROOT"

if command -v icp >/dev/null 2>&1; then
  case "$SUBCOMMAND" in
    show|project:show)
      icp project show "$@"
      ;;
    env|environment|env:list)
      icp environment list "$@"
      ;;
    completions)
      SHELL_NAME="${1:-bash}"
      icp completions "$SHELL_NAME"
      ;;
    settings)
      icp settings "$@"
      ;;
    *)
      icp "$SUBCOMMAND" "$@"
      ;;
  esac
else
  case "$SUBCOMMAND" in
    show|project:show)
      cat "$ROOT/icp.yaml" 2>/dev/null || cat "$ROOT/backend/dfx.json"
      ;;
    *)
      echo "Command $SUBCOMMAND requires icp-cli. Please install: npm install -g @icp-sdk/icp-cli"
      exit 1
      ;;
  esac
fi
