#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# Bootstrap dotfiles for macOS
# -----------------------------------------------------------------------------

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "🚀 Bootstrapping dotfiles from $DOTFILES_DIR"

# -----------------------------------------------------------------------------
# Sanity checks
# -----------------------------------------------------------------------------

if [[ "$OSTYPE" != "darwin"* ]]; then
  echo "❌ This bootstrap script is intended for macOS only."
  exit 1
fi

# -----------------------------------------------------------------------------
# Install dependencies
# -----------------------------------------------------------------------------

echo "==> Installing Homebrew"
source "$DOTFILES_DIR/install/homebrew.sh"

echo "==> Installing zsh"
source "$DOTFILES_DIR/install/zsh.sh"

echo "==> Installing Hammerspoon"
source "$DOTFILES_DIR/install/hammerspoon.sh"

echo "==> Installing Oh My Zsh"
source "$DOTFILES_DIR/install/oh-my-zsh.sh"

echo "==> Installing Powerlevel10k"
source "$DOTFILES_DIR/install/powerlevel10k.sh"

echo "==> Installing fonts"
source "$DOTFILES_DIR/install/fonts.sh"

echo "==> Installing GNU Stow"
source "$DOTFILES_DIR/install/stow.sh"

# -----------------------------------------------------------------------------
# Install Homebrew packages
# -----------------------------------------------------------------------------

if [[ -f "$DOTFILES_DIR/Brewfile" ]]; then
  echo "==> Installing Homebrew packages from Brewfile"
  brew bundle --file="$DOTFILES_DIR/Brewfile"
fi

# -----------------------------------------------------------------------------
# Stow dotfiles
# -----------------------------------------------------------------------------

echo "==> Linking dotfiles with stow"
cd "$DOTFILES_DIR/stow"

for pkg in */; do
  stow --target="$HOME" "${pkg%/}"
done

echo "==> Installing Neovim Java tools"
source "$DOTFILES_DIR/install/nvim-java.sh"

echo "✅ Dotfiles installed successfully"

echo
echo "ℹ️  Restart your terminal or run: exec zsh"
