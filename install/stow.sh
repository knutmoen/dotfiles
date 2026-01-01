#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# Install GNU Stow via Homebrew
# -----------------------------------------------------------------------------

echo "🔗 Setting up GNU Stow..."

# -----------------------------------------------------------------------------
# Install stow
# -----------------------------------------------------------------------------

if brew list stow >/dev/null 2>&1; then
  echo "✅ GNU Stow already installed"
else
  echo "📦 Installing GNU Stow..."
  brew install stow
fi

# -----------------------------------------------------------------------------
# Verify installation
# -----------------------------------------------------------------------------

if ! command -v stow >/dev/null 2>&1; then
  echo "❌ stow command not found after installation"
  exit 1
fi

echo "🔗 GNU Stow version:"
stow --version
