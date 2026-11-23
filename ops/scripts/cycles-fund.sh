#!/usr/bin/env bash
# cycles-fund.sh — Friendly cycles funding helper with terminal QR code
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SUGGESTED_ICP="${1:-0.50}"

# Get identity, principal, and account-id using dfx or icp
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

# 1 XDR = 1 Trillion cycles. Assuming ~1 ICP ≈ 10-12 XDR (~10T cycles) or conservative 10T per ICP.
# 0.50 ICP ~ 5.0 Trillion cycles
CYCLES_EST="$(awk -v icp="$SUGGESTED_ICP" 'BEGIN { printf "%.2f", icp * 10.0 }' 2>/dev/null || echo "5.00")"

echo ""
echo "=================================================================="
echo " ⛽ CYCLES FUNDING REQUIRED FOR DEPLOYMENT / RUNTIME"
echo "=================================================================="
echo ""
echo "Your identity needs ICP to mint cycles for creating or powering canisters."
echo ""
echo "  Identity:        $WHOAMI"
echo "  Suggested ICP:   $SUGGESTED_ICP ICP"
echo "  Estimated Yield: ~$CYCLES_EST Trillion Cycles"
echo ""
echo "------------------------------------------------------------------"
echo " 1. Send $SUGGESTED_ICP ICP to your Account ID (Recommended):"
echo "------------------------------------------------------------------"
echo "  $ACCOUNT_ID"
echo ""
echo " 2. Or send to your Principal ID:"
echo "------------------------------------------------------------------"
echo "  $PRINCIPAL"
echo ""
echo "------------------------------------------------------------------"
echo " 3. Scan QR Code from your Mobile Wallet (Plug / Bitfinity / Oisy / NNS):"
echo "------------------------------------------------------------------"

if [[ "$ACCOUNT_ID" != "unknown" && -x "$SCRIPT_DIR/render-qr.sh" ]]; then
  "$SCRIPT_DIR/render-qr.sh" "$ACCOUNT_ID"
else
  echo "[QR Code unavailable: missing account-id or render-qr.sh]"
fi

echo ""
echo "------------------------------------------------------------------"
echo " Next Steps after sending ICP:"
echo "------------------------------------------------------------------"
echo " 1. Check ICP balance:     falcon t:bal"
echo " 2. Mint into cycles:      falcon y:mint $SUGGESTED_ICP"
echo " 3. Topup your canister:   falcon y:topup app ${CYCLES_EST}T"
echo " 4. Resume deploy:         falcon b:deploy"
echo "=================================================================="
echo ""
