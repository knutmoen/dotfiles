# -----------------------------------------------------------------------------
# g doctor
#
# Verifies that the g command registry is consistent.
#
# Checks:
# - every registered command has an implementation
# - no missing implementations
#
# Explicitly does NOT:
# - validate internal helper functions (e.g. g_doctor)
# -----------------------------------------------------------------------------

g_doctor() {
  emulate -L zsh
  setopt LOCAL_OPTIONS NO_SH_WORD_SPLIT

  source "$HOME/.zsh/git/commands.zsh"

  local ok=1

  # Check that all registered commands are implemented
  local cmd func
  for cmd func in ${(kv)G_COMMAND_DISPATCH}; do
    if ! typeset -f "$func" >/dev/null 2>&1; then
      echo "❌ g command '$cmd' missing implementation: $func"
      ok=0
    fi
  done

  [[ "$ok" -eq 1 ]]
}
