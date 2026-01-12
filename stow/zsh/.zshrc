# -----------------------------------------------------------------------------
# Powerlevel10k instant prompt (must be first)
# -----------------------------------------------------------------------------

typeset -g POWERLEVEL9K_INSTANT_PROMPT=off

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# -----------------------------------------------------------------------------
# Base configuration
# -----------------------------------------------------------------------------

export ZSH_CONFIG_DIR="$HOME/.zsh"

# -----------------------------------------------------------------------------
# Core shell configuration
# (PATH-agnostic: runtime policy, aliases, hooks, completion config)
# -----------------------------------------------------------------------------

source "$ZSH_CONFIG_DIR/core.zsh"

# -----------------------------------------------------------------------------
# Oh My Zsh (sets PATH, runs compinit)
# -----------------------------------------------------------------------------

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git)

source "$ZSH/oh-my-zsh.sh"

# -----------------------------------------------------------------------------
# Powerlevel10k prompt config
# -----------------------------------------------------------------------------

[[ -r "$HOME/.p10k.zsh" ]] && source "$HOME/.p10k.zsh"

# -----------------------------------------------------------------------------
# Git workflow modules (g, g doctor, etc.)
# -----------------------------------------------------------------------------

for file in "$ZSH_CONFIG_DIR/git/"*.zsh; do
  [[ -r "$file" ]] && source "$file"
done

# -----------------------------------------------------------------------------
# Dotfiles help (dfhelp)
# -----------------------------------------------------------------------------

[[ -r "$ZSH_CONFIG_DIR/help.zsh" ]] && source "$ZSH_CONFIG_DIR/help.zsh"

# -----------------------------------------------------------------------------
# Autosuggestions (after PATH is ready)
# -----------------------------------------------------------------------------

if command -v brew >/dev/null 2>&1; then
  source "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
# TAB accepts autosuggestion
bindkey '^I' autosuggest-accept

# TAB TAB triggers completion
bindkey '^I^I' complete-word
fi

# -----------------------------------------------------------------------------
# Syntax highlighting (must be last)
# -----------------------------------------------------------------------------

if command -v brew >/dev/null 2>&1; then
  source "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi
