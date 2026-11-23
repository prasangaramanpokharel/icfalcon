#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export FALCON_ROOT="$ROOT"
export FALCON_BACKEND_DIR="${FALCON_BACKEND_DIR:-$ROOT/backend}"

# shellcheck source=progress.sh
source "$ROOT/ops/scripts/progress.sh"

prog_header "Updating IcFalcon Framework"

# 1. Update from Git if in git repo
if [[ -d "$ROOT/.git" ]]; then
  if git -C "$ROOT" remote get-url origin >/dev/null 2>&1; then
    prog_run "Pulling latest framework updates from GitHub" git -C "$ROOT" pull --ff-only origin main || true
  fi
fi

# 2. Re-link global CLI
prog_run "Updating global CLI symlink" bash "$ROOT/ops/install.sh"

# 3. Update backend packages
if [[ -d "$FALCON_BACKEND_DIR" ]]; then
  cd "$FALCON_BACKEND_DIR"
  prog_run "Syncing backend packages (mo:core@2.6.1)" mops install
  prog_run "Pinning Motoko toolchain (moc 1.6.0)" mops toolchain use moc 1.6.0
fi

# 4. Run skills validation
prog_run "Validating AI agent skills" bash "$ROOT/ops/scripts/validate-skills.sh"

# 5. Run Motoko code audit
prog_run "Auditing Motoko code against mo:core 2.x standard" bash "$ROOT/ops/scripts/code/motoko/validate-code.sh" --all

prog_success
echo ""
echo "IcFalcon is now fully up to date!"
echo "Run 'falcon help' or 'falcon b:test --local' to verify."
