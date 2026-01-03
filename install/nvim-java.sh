#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# Install Neovim Java tooling (jdtls + debug/test adapters) headless
# -----------------------------------------------------------------------------

echo "🧰 Installing Neovim Java tools (headless)..."

# -----------------------------------------------------------------------------
# Lombok (download jar to stdpath data) if not present
# -----------------------------------------------------------------------------
LOMBOK_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/nvim/lombok"
LOMBOK_JAR="${LOMBOK_DIR}/lombok.jar"

if [[ ! -f "$LOMBOK_JAR" ]]; then
  if command -v curl >/dev/null 2>&1; then
    echo "⬇️  Downloading Lombok jar..."
    mkdir -p "$LOMBOK_DIR"
    if curl -fL "https://projectlombok.org/downloads/lombok.jar" -o "$LOMBOK_JAR"; then
      echo "✅ Lombok downloaded to $LOMBOK_JAR"
    else
      echo "⚠️  Could not download Lombok jar automatically."
      echo "    Manually download to: $LOMBOK_JAR"
    fi
  else
    echo "⚠️  curl not found; skipping Lombok download."
    echo "    Manually download https://projectlombok.org/downloads/lombok.jar to $LOMBOK_JAR"
  fi
fi

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
