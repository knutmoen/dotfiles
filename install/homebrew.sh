#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# Install Homebrew (macOS, Intel + Apple Silicon)
# -----------------------------------------------------------------------------

echo "🍺 Checking for Homebrew..."

if command -v brew >/dev/null 2>&1; then
  echo "✅ Homebrew already installed"
else
  echo "📦 Installing Homebrew..."

  NONINTERACTIVE=1 \
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  echo "✅ Homebrew installation complete"
fi

# -----------------------------------------------------------------------------
# Configure shell environment for Homebrew
# -----------------------------------------------------------------------------

BREW_PREFIX=""

if [[ "$(uname -m)" == "arm64" ]]; then
  BREW_PREFIX="/opt/homebrew"
else
  BREW_PREFIX="/usr/local"
fi

if [[ ! -x "$BREW_PREFIX/bin/brew" ]]; then
  echo "❌ Homebrew binary not found at expected location: $BREW_PREFIX/bin/brew"
  exit 1
fi

# Ensure brew is available in this shell
eval "$("$BREW_PREFIX/bin/brew" shellenv)"

echo "🍺 Homebrew version:"
brew --version
