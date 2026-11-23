#!/usr/bin/env bash
# cycles-fund.sh — Cycles funding helper with terminal QR code and auto-deploy
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

SUGGESTED_ICP="0.50"
DEPLOY_ARGS=()

# Parse arguments: extract suggested ICP if numeric, otherwise collect for deploy
for arg in "$@"; do
  if [[ "$arg" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
    SUGGESTED_ICP="$arg"
  else
    DEPLOY_ARGS+=("$arg")
  fi
done

WHOAMI=""
PRINCIPAL=""
ACCOUNT_ID=""

if command -v dfx >/dev/null 2>&1; then
  WHOAMI="$(dfx identity whoami 2>/dev/null || true)"
  PRINCIPAL="$(dfx identity get-principal 2>/dev/null || true)"
  ACCOUNT_ID="$(dfx ledger account-id 2>/dev/null || true)"
fi

if [[ -z "$WHOAMI" ]] && command -v icp >/dev/null 2>&1; then
  WHOAMI="$(icp identity whoami 2>/dev/null || true)"
fi
if [[ -z "$PRINCIPAL" ]] && command -v icp >/dev/null 2>&1; then
  PRINCIPAL="$(icp identity principal 2>/dev/null || true)"
fi
if [[ -z "$ACCOUNT_ID" ]] && command -v icp >/dev/null 2>&1; then
  ACCOUNT_ID="$(icp identity account-id 2>/dev/null || true)"
fi

WHOAMI="${WHOAMI:-default}"
PRINCIPAL="${PRINCIPAL:-unknown}"
ACCOUNT_ID="${ACCOUNT_ID:-unknown}"

CYCLES_EST="$(awk -v icp="$SUGGESTED_ICP" 'BEGIN { printf "%.2f", icp * 10.0 }' 2>/dev/null || echo "5.00")"

echo ""
echo "=================================================================="
echo "CYCLES FUNDING REQUIRED"
echo "=================================================================="
echo ""
echo "Identity:        $WHOAMI"
echo "Required:        ~$CYCLES_EST T Cycles"
echo "Suggested:       $SUGGESTED_ICP ICP"
echo ""
echo "Account ID (Recommended):"
echo "  $ACCOUNT_ID"
echo ""
echo "Principal ID:"
echo "  $PRINCIPAL"
echo ""
echo "Scan QR Code:"

if [[ "$ACCOUNT_ID" != "unknown" && -x "$SCRIPT_DIR/render-qr.sh" ]]; then
  "$SCRIPT_DIR/render-qr.sh" "$ACCOUNT_ID"
fi

echo "=================================================================="
echo ""

# Interactive prompt: confirms transfer and deploys automatically
CONFIRM_SENT=""
if [[ -t 0 ]]; then
  read -r -p "I have sent [y/N]: " CONFIRM_SENT
else
  # Read from stdin when piped
  read -r CONFIRM_SENT || CONFIRM_SENT=""
fi

CONFIRM_SENT="$(echo "$CONFIRM_SENT" | tr '[:upper:]' '[:lower:]' | xargs)"

if [[ "$CONFIRM_SENT" == "y" || "$CONFIRM_SENT" == "yes" || "$CONFIRM_SENT" == "i have sent" || "$CONFIRM_SENT" == "i have sended" ]]; then
  echo ""
  echo "Proceeding to deploy..."
  echo ""
  FALCON_BIN="$ROOT/ops/falcon"
  if [[ -x "$FALCON_BIN" ]]; then
    exec "$FALCON_BIN" b:deploy "${DEPLOY_ARGS[@]}"
  else
    exec dfx deploy "${DEPLOY_ARGS[@]}"
  fi
else
  echo "Deployment paused."
  exit 0
fi
