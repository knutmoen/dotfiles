#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# Install and configure zsh (Homebrew)
# -----------------------------------------------------------------------------

echo "🐚 Setting up zsh via Homebrew..."

# -----------------------------------------------------------------------------
# Install zsh
# -----------------------------------------------------------------------------

if brew list zsh >/dev/null 2>&1; then
  echo "✅ zsh already installed via Homebrew"
else
  echo "📦 Installing zsh..."
  brew install zsh
fi

ZSH_PATH="$(brew --prefix)/bin/zsh"

if [[ ! -x "$ZSH_PATH" ]]; then
  echo "❌ Homebrew zsh not found at $ZSH_PATH"
  exit 1
fi

# -----------------------------------------------------------------------------
# Ensure zsh is listed in /etc/shells
# -----------------------------------------------------------------------------

if ! grep -q "$ZSH_PATH" /etc/shells; then
  echo "🔐 Adding $ZSH_PATH to /etc/shells (requires sudo)"
  echo "$ZSH_PATH" | sudo tee -a /etc/shells >/dev/null
else
  echo "✅ zsh already present in /etc/shells"
fi

# -----------------------------------------------------------------------------
# Set zsh as default shell
# -----------------------------------------------------------------------------

CURRENT_SHELL="$(dscl . -read ~/ UserShell | awk '{print $2}')"

if [[ "$CURRENT_SHELL" != "$ZSH_PATH" ]]; then
  echo "🔁 Changing default shell to zsh"
  chsh -s "$ZSH_PATH"
else
  echo "✅ zsh is already the default shell"
fi

echo "🐚 zsh setup complete"
