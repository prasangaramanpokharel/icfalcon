#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export FALCON_ROOT="$ROOT"
export FALCON_BACKEND_DIR="${FALCON_BACKEND_DIR:-$ROOT/backend}"

# shellcheck source=progress.sh
source "$ROOT/ops/scripts/progress.sh"

prog_header "Updating IcFalcon Framework"

# 1. Framework Source Synchronization
IS_OFFICIAL_REPO=false
if [[ -d "$ROOT/.git" ]]; then
  ORIGIN_URL="$(git -C "$ROOT" remote get-url origin 2>/dev/null || true)"
  if [[ "$ORIGIN_URL" == *"prasangaramanpokharel/icfalcon"* ]]; then
    IS_OFFICIAL_REPO=true
  fi
fi

if [[ "$IS_OFFICIAL_REPO" == "true" ]]; then
  prog_run "Pulling latest framework updates from GitHub" git -C "$ROOT" pull --ff-only origin main || true
else
  # Standalone project or custom repository: download framework update bundle
  prog_run "Fetching latest framework assets from GitHub" bash -c '
    TMP_DIR=$(mktemp -d)
    trap "rm -rf $TMP_DIR" EXIT
    curl -fsSL https://codeload.github.com/prasangaramanpokharel/icfalcon/tar.gz/refs/heads/main | tar -xz -C "$TMP_DIR"
    EXTRACTED="$TMP_DIR/icfalcon-main"
    if [[ -d "$EXTRACTED" ]]; then
      if command -v rsync >/dev/null 2>&1; then
        rsync -a "$EXTRACTED/ops/" "$FALCON_ROOT/ops/"
        rsync -a "$EXTRACTED/.agent/" "$FALCON_ROOT/.agent/"
        rsync -a "$EXTRACTED/backend/pkg/" "$FALCON_ROOT/backend/pkg/"
      else
        cp -R "$EXTRACTED/ops/"* "$FALCON_ROOT/ops/"
        cp -R "$EXTRACTED/.agent/"* "$FALCON_ROOT/.agent/"
        cp -R "$EXTRACTED/backend/pkg/"* "$FALCON_ROOT/backend/pkg/"
      fi
    fi
  '
fi

# 2. Re-link local CLI
prog_run "Updating local CLI symlink" bash "$ROOT/ops/install.sh"

# 3. Update backend toolchain & dependencies in backend/mops.toml
if [[ -d "$FALCON_BACKEND_DIR" ]]; then
  MOPS_TOML="$FALCON_BACKEND_DIR/mops.toml"
  if [[ -f "$MOPS_TOML" ]]; then
    if grep -q 'core *= *' "$MOPS_TOML"; then
      sed -i.bak -E 's/core *= *"[^"]*"/core = "2.6.1"/' "$MOPS_TOML" && rm -f "$MOPS_TOML.bak"
    elif grep -q '\[dependencies\]' "$MOPS_TOML"; then
      sed -i.bak '/\[dependencies\]/a\
core = "2.6.1"
' "$MOPS_TOML" && rm -f "$MOPS_TOML.bak"
    fi

    if grep -q '\[toolchain\]' "$MOPS_TOML"; then
      if grep -q 'moc *= *' "$MOPS_TOML"; then
        sed -i.bak -E 's/moc *= *"[^"]*"/moc = "1.6.0"/' "$MOPS_TOML" && rm -f "$MOPS_TOML.bak"
      else
        sed -i.bak '/\[toolchain\]/a\
moc = "1.6.0"
' "$MOPS_TOML" && rm -f "$MOPS_TOML.bak"
      fi
    else
      printf '\n[toolchain]\nmoc = "1.6.0"\n' >> "$MOPS_TOML"
    fi
  fi

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
echo "IcFalcon framework is now fully up to date!"
echo ""
echo "Protected & Preserved:"
echo "  ✓ backend/src/     (Your canister services, APIs, and business logic)"
echo "  ✓ frontend/        (Your Next.js user interface and components)"
echo "  ✓ .env / canisters (Your secrets, identities, and canister state)"
echo ""
echo "Updated to Latest:"
echo "  ✓ ops/             (Framework CLI, scripts, and linters)"
echo "  ✓ .agent/skills/   (Latest Motoko 1.6 & mo:core 2.x agent skills)"
echo "  ✓ backend/pkg/     (Standard Hub packages with 0 warnings)"
echo "  ✓ Toolchain        (moc 1.6.0, mo:core 2.6.1)"
echo ""
echo "Tip: To update global npm packages, run:"
echo "  npm install -g icfalcon@latest create-icfalcon@latest"
echo ""
echo "Run 'falcon help' or 'falcon b:test --local' to verify."
