#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# Install Powerlevel10k (Oh My Zsh theme)
# -----------------------------------------------------------------------------

echo "⚡ Setting up Powerlevel10k..."

P10K_DIR="$HOME/.oh-my-zsh/custom/themes/powerlevel10k"

if [[ -d "$P10K_DIR" ]]; then
  echo "✅ Powerlevel10k already installed"
else
  echo "📦 Installing Powerlevel10k..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
fi
