# -----------------------------------------------------------------------------
# zprofile – login shell configuration
# -----------------------------------------------------------------------------

# Homebrew
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# Force interactive zsh to load .zshrc
if [[ -o login ]]; then
  [[ -f ~/.zshrc ]] && source ~/.zshrc
fi

export WORK_PROFILE=1
