#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# Neovim bootstrap: download Lombok, then trigger lazy.nvim sync so that
# Mason auto-installs all LSPs, formatters, linters, and DAP adapters.
# -----------------------------------------------------------------------------

echo "🧰 Bootstrapping Neovim plugins and tools..."

# ── Lombok (required for Java development with jdtls) ─────────────────────
LOMBOK_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/nvim/lombok"
LOMBOK_JAR="${LOMBOK_DIR}/lombok.jar"

if [[ ! -f "$LOMBOK_JAR" ]]; then
  if command -v curl >/dev/null 2>&1; then
    echo "⬇️  Downloading Lombok..."
    mkdir -p "$LOMBOK_DIR"
    if curl -fsSL "https://projectlombok.org/downloads/lombok.jar" -o "$LOMBOK_JAR"; then
      echo "✅ Lombok saved to $LOMBOK_JAR"
    else
      echo "⚠️  Could not download Lombok. Manually place it at: $LOMBOK_JAR"
    fi
  else
    echo "⚠️  curl not found – skipping Lombok. Manually place it at: $LOMBOK_JAR"
  fi
else
  echo "✅ Lombok already present"
fi

# ── Headless plugin sync ───────────────────────────────────────────────────
if ! command -v nvim >/dev/null 2>&1; then
  echo "⚠️  Neovim not in PATH – skipping plugin sync. Run after install:"
  echo "    nvim --headless '+Lazy! sync' '+qa'"
  exit 0
fi

echo "🔄 Syncing lazy.nvim plugins (headless)..."
if nvim --headless "+Lazy! sync" "+qa" 2>&1; then
  echo "✅ lazy.nvim sync complete"
else
  echo "⚠️  Headless sync failed. Open nvim and run :Lazy sync manually."
fi
