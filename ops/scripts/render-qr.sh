#!/usr/bin/env bash
# Render UTF-8 QR code in terminal using npx qrcode or fallback
set -euo pipefail

PAYLOAD="${1:-}"

if [[ -z "$PAYLOAD" ]]; then
  echo "Usage: $0 <text-or-address>" >&2
  exit 1
fi

TMP_FILE="$(mktemp /tmp/falcon-qr-XXXXXX.txt)"
trap 'rm -f "$TMP_FILE"' EXIT

# Attempt npx qrcode with utf8 blocks
if command -v npx >/dev/null 2>&1; then
  if npx --yes qrcode -t utf8 -o "$TMP_FILE" "$PAYLOAD" >/dev/null 2>&1; then
    cat "$TMP_FILE"
    exit 0
  fi
fi

# Fallback ASCII notice if npx / qrcode is unreachable
echo "┌────────────────────────────────────────────────────────┐"
echo "│ [QR Code generator requires internet or npx qrcode]    │"
echo "│ Text Payload:                                          │"
echo "│ $PAYLOAD"
echo "└────────────────────────────────────────────────────────┘"
