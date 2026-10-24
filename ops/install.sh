#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TARGET="$HOME/.local/bin/falcon"
SOURCE="$ROOT/ops/falcon"

mkdir -p "$HOME/.local/bin"
ln -sf "$SOURCE" "$TARGET"
chmod +x "$SOURCE"

if ! echo ":$PATH:" | grep -q ":$HOME/.local/bin:"; then
  SHELL_NAME="$(basename "${SHELL:-bash}")"
  RC_FILE="$HOME/.bashrc"
  if [[ "$SHELL_NAME" == "zsh" ]] || [[ "$(uname -s)" == "Darwin" ]]; then
    RC_FILE="$HOME/.zshrc"
  fi

  if [[ -f "$RC_FILE" ]] && ! grep -q '\.local/bin' "$RC_FILE" 2>/dev/null; then
    echo "" >> "$RC_FILE"
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$RC_FILE"
    echo "Added ~/.local/bin to $RC_FILE"
    echo "Run: source $RC_FILE (or open a new terminal)"
  else
    echo "Add to $RC_FILE:"
    echo '  export PATH="$HOME/.local/bin:$PATH"'
  fi
fi

echo "Installed: $TARGET -> $SOURCE"
echo ""
echo "Try:"
echo "  falcon help"
echo "  falcon b:test --local"
