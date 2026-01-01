#!/usr/bin/env bash
set -euo pipefail

echo "🔤 Installing Meslo Nerd Fonts..."

brew tap homebrew/cask-fonts >/dev/null 2>&1 || true

brew install --cask font-meslo-lg-nerd-font
