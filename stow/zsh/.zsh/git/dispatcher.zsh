# -----------------------------------------------------------------------------
# g dispatcher
#
# Uses g as a function (not OMZ alias) and dispatches:
# - registry-based g commands (authoritative)
# - legacy shorthand commands (case-based)
# - fallback to git
# -----------------------------------------------------------------------------

# Ensure g is a function, not an alias
unalias g 2>/dev/null

# Load authoritative command registry
source "$HOME/.zsh/git/commands.zsh"
# Load help text
source "$HOME/.zsh/git/help.zsh"
# Load shorthand implementations
source "$HOME/.zsh/git/simple.zsh"

g() {
  emulate -L zsh
  setopt LOCAL_OPTIONS NO_SH_WORD_SPLIT

  local cmd="$1"
  shift || true

  # Help first
  if [[ "$cmd" == "help" || "$cmd" == "-h" || "$cmd" == "--help" ]]; then
    g_help "$@"
    return
  fi

  # --------------------------------------------------
  # Registry-based g commands (authoritative)
  # --------------------------------------------------
  if [[ -n "$cmd" && -n "${G_COMMAND_DISPATCH[$cmd]}" ]]; then
    "${G_COMMAND_DISPATCH[$cmd]}" "$@"
    return
  fi

  # Default status
  if [[ -z "$cmd" ]]; then
    g_st
    return
  fi

  # Fallback to raw git
  git "$cmd" "$@"
}
