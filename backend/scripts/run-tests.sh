#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."
mkdir -p .mops
mops install
MOC_BIN="$(mops toolchain bin moc 2>/dev/null || which moc || true)"
if [ -n "$MOC_BIN" ] && [ -f "$MOC_BIN" ]; then
  ln -sf "$MOC_BIN" .mops/moc-wrapper
fi
export PATH="$(pwd)/.mops:$PATH"

echo "==> unit tests (moc)"
SOURCES=$(mops sources)
MOC="${MOC:-$(pwd)/.mops/moc-wrapper}"
"$MOC" -r -Werror $SOURCES --package pkg pkg --package app src testing/TestRunner.mo

if command -v icp >/dev/null 2>&1 && [ -f "../icp.yaml" ]; then
  echo "==> icp build app (icp-cli)"
  (cd .. && icp build app)
elif command -v dfx >/dev/null 2>&1; then
  echo "==> dfx build app (--check)"
  dfx build app --check
else
  echo "==> moc compiler check"
  "$MOC" --check $SOURCES --package pkg pkg src/main.mo
fi

echo "==> all tests passed"
