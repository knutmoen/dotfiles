#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# Install Neovim Java tooling (jdtls + debug/test adapters) headless
# -----------------------------------------------------------------------------

echo "🧰 Installing Neovim Java tools (headless)..."

if ! command -v nvim >/dev/null 2>&1; then
  echo "⚠️  Neovim not found in PATH, skipping Java tools install"
  exit 0
fi

# First ensure plugins are installed
if ! nvim --headless "+Lazy! sync" "+qa"; then
  echo "⚠️  Lazy sync failed headless. Run manually:"
  echo "    nvim --headless '+Lazy! sync' '+qa'"
  exit 0
fi

# Then install Mason packages (after mason.nvim is present)
if nvim --headless "+MasonUpdate" "+MasonInstall jdtls java-debug-adapter java-test" "+qa"; then
  echo "✅ Installed jdtls, java-debug-adapter, java-test via Mason"
else
  echo "⚠️  Could not complete Mason install (Neovim headless failed). Run manually:"
  echo "    nvim --headless '+MasonUpdate' '+MasonInstall jdtls java-debug-adapter java-test' '+qa'"
fi
