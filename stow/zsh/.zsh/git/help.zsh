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

  # Legacy shortcuts (case-based in dispatcher)
  typeset -gA G_LEGACY_HELP=(
    st   "git status -sb"
    co   "git checkout <branch>"
    cb   "git checkout -b <branch>"
    cpr  "git checkout - (previous branch)"
    br   "git branch"
    bc   "git branch --show-current"
    b    "git branch"
    bd   "git branch -d <branch>"
    bD   "git branch -D <branch>"
    aa   "git add --all"
    lg   "git log --oneline --graph --decorate"
    lo   "git log --oneline"
    df   "git diff"
    dc   "git diff --cached"
    p    "git push"
    pf   "git push --force-with-lease"
    pr   "git push origin HEAD --force"
    pl   "git pull"
    plr  "git pull --rebase"
    f    "git fetch"
    rb   "git rebase"
    rbd  "git rebase develop"
    rbi  "git rebase -i"
    rbc  "git rebase --continue"
    rba  "git rebase --abort"
    rbr  "git rebase -i --root"
    rh   "git reset --hard <ref>"
    ci   "git commit"
    ca   "git commit --amend"
    cae  "git commit --amend --no-edit"
    c    "git commit -m \"...\" (or open editor if no msg)"
    doctor "Validate g registry"
  )

  local cmd="$1"
  if [[ -z "$cmd" ]]; then
    echo "g commands:"
    for cmd in "${G_COMMANDS[@]}"; do
      printf "  %-10s %s\n" "g $cmd" "${G_COMMAND_HELP[$cmd]:-}"
    done
    echo
    echo "Shortcuts:"
    for cmd desc in ${(kv)G_LEGACY_HELP}; do
      printf "  %-10s %s\n" "g $cmd" "$desc"
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

  if [[ -n "${G_LEGACY_HELP[$cmd]-}" ]]; then
    printf "g %s  –  %s\n" "$cmd" "${G_LEGACY_HELP[$cmd]}"
    return
  fi

  echo "Unknown command: $cmd"
  return 1
}
