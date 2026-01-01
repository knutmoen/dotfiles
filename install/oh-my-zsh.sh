#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# Install Oh My Zsh
# -----------------------------------------------------------------------------

echo "✨ Setting up Oh My Zsh..."

OMZ_DIR="$HOME/.oh-my-zsh"

if [[ -d "$OMZ_DIR" ]]; then
  echo "✅ Oh My Zsh already installed"
else
  echo "📦 Installing Oh My Zsh..."

  RUNZSH=no \
  CHSH=no \
  KEEP_ZSHRC=yes \
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

  echo "✅ Oh My Zsh installed"
fi
