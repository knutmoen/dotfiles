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
eval "$(/opt/homebrew/bin/brew shellenv)"
export PATH="/opt/homebrew/bin:$PATH"

# Setting PATH for Python 3.14
# The original version is saved in .zprofile.pysave
PATH="/Library/Frameworks/Python.framework/Versions/3.14/bin:${PATH}"
export PATH
