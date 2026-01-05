# -----------------------------------------------------------------------------
# Core shell helpers
# Safe to load in all shells
# -----------------------------------------------------------------------------

mkcd() {
  mkdir -p "$1" && cd "$1"
}

# -----------------------------------------------------------------------------
# Interactive-only guard
# -----------------------------------------------------------------------------

[[ -o interactive ]] || return 0

# -----------------------------------------------------------------------------
# Completion path (before compinit)
# -----------------------------------------------------------------------------

fpath=("$HOME/.zsh/completion" $fpath)

# -----------------------------------------------------------------------------
# Runtime environments (PATH-agnostic policy only)
# -----------------------------------------------------------------------------

for file in \
  "$ZSH_CONFIG_DIR/java.zsh" \
  "$ZSH_CONFIG_DIR/node.zsh" \
  "$ZSH_CONFIG_DIR/tmux.zsh"; do
  [[ -r "$file" ]] && source "$file"
done

# -----------------------------------------------------------------------------
# Completion behavior
# -----------------------------------------------------------------------------

setopt AUTO_MENU
setopt COMPLETE_IN_WORD

zstyle ':completion:*' matcher-list \
  'm:{a-z}={A-Z}' \
  'r:|[._-]=* r:|=*' \
  'l:|=* r:|=*'

zstyle ':completion:*' menu select

# -----------------------------------------------------------------------------
# Common aliases / simple functions
# -----------------------------------------------------------------------------

for file in \
  "$ZSH_CONFIG_DIR/aliases/common.zsh" \
  "$ZSH_CONFIG_DIR/aliases/dev.zsh" \
  "$ZSH_CONFIG_DIR/aliases/navigation.zsh"; do
  [[ -r "$file" ]] && source "$file"
done

# -----------------------------------------------------------------------------
# Profile-specific aliases (work / personal)
# -----------------------------------------------------------------------------

if [[ -n "$WORK_PROFILE" ]]; then
  [[ -r "$ZSH_CONFIG_DIR/aliases/work.zsh" ]] && source "$ZSH_CONFIG_DIR/aliases/work.zsh"
else
  [[ -r "$ZSH_CONFIG_DIR/aliases/personal.zsh" ]] && source "$ZSH_CONFIG_DIR/aliases/personal.zsh"
fi

# -----------------------------------------------------------------------------
# Self-healing git hook installation (dotfiles repo only)
# -----------------------------------------------------------------------------

if git_root="$(git rev-parse --show-toplevel 2>/dev/null)"; then
  install_script="$git_root/scripts/install-git-hooks.sh"
  hook="$git_root/.git/hooks/pre-commit"

  if [[ -x "$install_script" && ! -x "$hook" ]]; then
    "$install_script" >/dev/null 2>&1
  fi
fi
