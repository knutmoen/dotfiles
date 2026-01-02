#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# Install Hammerspoon
# -----------------------------------------------------------------------------

echo "✨ Setting up Hammerspoon..."

if ! command -v brew >/dev/null 2>&1; then
  echo "❌ Homebrew is required but not installed"
  exit 1
fi

if brew list --cask hammerspoon >/dev/null 2>&1; then
  echo "✅ Hammerspoon already installed"
else
  echo "📦 Installing Hammerspoon..."
  brew install --cask hammerspoon
  echo "✅ Hammerspoon installed"
fi
