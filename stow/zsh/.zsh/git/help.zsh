# -----------------------------------------------------------------------------
# g help
#
# Lightweight, registry-driven help for g commands.
# Descriptions come from G_COMMAND_HELP in commands.zsh.
# -----------------------------------------------------------------------------

g_help() {
  emulate -L zsh
  setopt LOCAL_OPTIONS NO_SH_WORD_SPLIT

  source "$HOME/.zsh/git/commands.zsh"

  local cmd="$1"
  if [[ -z "$cmd" ]]; then
    echo "g commands:"
    for cmd in "${G_COMMANDS[@]}"; do
      printf "  %-10s %s\n" "g $cmd" "${G_COMMAND_HELP[$cmd]:-}"
    done
    echo
    echo "More: g help <command>"
    return
  fi

  if [[ -n "${G_COMMAND_HELP[$cmd]-}" ]]; then
    printf "g %s  –  %s\n" "$cmd" "${G_COMMAND_HELP[$cmd]}"
    case "$cmd" in
      sq) echo "Usage: g sq [N>=2] [--interactive|-i]" ;;
      review) echo "Usage: g review [all|log|stat|diff] (default: all)" ;;
      tag) echo "Usage: g tag <version> <message>  (creates v<version> and pushes)" ;;
      fixup) echo "Options: --no-rebase (skip autosquash rebase)" ;;
      wip) echo "Options: --squash (amend last commit), custom message allowed" ;;
      bfr) echo "Options: --check --cherry-pick <N> --include-merges [YY.MM] (see script for details)" ;;
      *) ;;
    esac
    return
  fi

  echo "Unknown command: $cmd"
  return 1
}
