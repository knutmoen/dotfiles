#!/usr/bin/env bash
set -euo pipefail

INSTALL_XCODE="${INSTALL_XCODE:-false}"

# -----------------------------------------------------------------------------
# Bootstrap dotfiles for macOS
# -----------------------------------------------------------------------------

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_FILE="$DOTFILES_DIR/bootstrap.log"

# -----------------------------------------------------------------------------
# Logging setup
# -----------------------------------------------------------------------------

# fd 3 = console, fd 1/2 = log file
exec 3>&1
: >"$LOG_FILE"
exec >"$LOG_FILE" 2>&1

log() {
  echo "$@"
}

log_console() {
  echo "$@" >&3
}

trap 'log_console "❌ Bootstrap failed – see bootstrap.log"' ERR

log "🚀 Bootstrapping dotfiles from $DOTFILES_DIR"
log_console "🔇 Running bootstrap (logs in bootstrap.log)..."

# -----------------------------------------------------------------------------
# Sanity checks
# -----------------------------------------------------------------------------

if [[ "$OSTYPE" != "darwin"* ]]; then
  log "❌ Not running on macOS (OSTYPE=$OSTYPE)"
  log_console "❌ This bootstrap script is intended for macOS only."
  exit 1
fi

# -----------------------------------------------------------------------------
# Install dependencies
# -----------------------------------------------------------------------------

log "==> Installing Homebrew"
source "$DOTFILES_DIR/install/homebrew.sh"

log "==> Installing zsh"
source "$DOTFILES_DIR/install/zsh.sh"

log "==> Installing Hammerspoon"
source "$DOTFILES_DIR/install/hammerspoon.sh"

log "==> Installing Oh My Zsh"
source "$DOTFILES_DIR/install/oh-my-zsh.sh"

log "==> Installing Powerlevel10k"
source "$DOTFILES_DIR/install/powerlevel10k.sh"

log "==> Installing fonts"
source "$DOTFILES_DIR/install/fonts.sh"

log "==> Installing GNU Stow"
source "$DOTFILES_DIR/install/stow.sh"

# -----------------------------------------------------------------------------
# Install Homebrew packages
# -----------------------------------------------------------------------------

if [[ -f "$DOTFILES_DIR/Brewfile" ]]; then
  log "==> Installing Homebrew packages from Brewfile"
  log_console "==> Installing Homebrew packages..."
  brew bundle --file="$DOTFILES_DIR/Brewfile"
  brew upgrade claude-code
  log_console "==> Homebrew packages installed"
fi

# -----------------------------------------------------------------------------
# Xcode: select correct path + accept license
# -----------------------------------------------------------------------------

log "==> Xcode configuration step"
log "INSTALL_XCODE=$INSTALL_XCODE"

if [[ "$INSTALL_XCODE" == "true" ]]; then
  log_console "==> Configuring Xcode (this may take a while)..."

  if command -v xcodes >/dev/null 2>&1; then
    log "Selecting Xcode via xcodes"
    sudo xcodes select || true
  else
    XCODE_PATH="/Applications/Xcode.app/Contents/Developer"
    if [[ -d "$XCODE_PATH" ]]; then
      if [[ "$(xcode-select -p 2>/dev/null)" != "$XCODE_PATH" ]]; then
        log "Switching xcode-select to $XCODE_PATH"
        sudo xcode-select --switch "$XCODE_PATH"
      fi
    else
      log "Xcode not found at expected path"
    fi
  fi

  log "Accepting Xcode license (if needed)"
  sudo xcodebuild -license accept || true

  log_console "==> Xcode configuration complete ✅"
else
  log "Skipping Xcode configuration (INSTALL_XCODE=false)"
fi

# -----------------------------------------------------------------------------
# Stow dotfiles
# -----------------------------------------------------------------------------

log "==> Linking dotfiles with stow"
cd "$DOTFILES_DIR/stow"

for pkg in */; do
  log "Stowing package: ${pkg%/}"
  stow --target="$HOME" "${pkg%/}" || {
    log_console "❌ Stow failed for package: ${pkg%/}"
    log_console "   If this is an existing config, run:"
    log_console "     migrate/adopt-${pkg%/}.sh"
    exit 1
  }
done

# -----------------------------------------------------------------------------
# Post-install steps
# -----------------------------------------------------------------------------

log "==> Installing Neovim Java tools"
source "$DOTFILES_DIR/install/nvim-java.sh"

log "✅ Dotfiles installed successfully"

log_console "ℹ️  Restart your terminal or run: exec zsh"
log_console "✅ Bootstrap complete (see bootstrap.log)"
