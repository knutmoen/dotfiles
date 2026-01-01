g_review() {
  emulate -L zsh
  setopt LOCAL_OPTIONS NO_SH_WORD_SPLIT

  local mode="${1:-all}" current target base

  current=$(git branch --show-current 2>/dev/null)
  [[ -z "$current" ]] && { echo "❌ Detached HEAD."; return 1; }

  target=$(__g_default_branch) || return 1
  base="origin/$target"

  case "$mode" in
    all)
      git log --oneline --graph --decorate "$base..HEAD"
      echo
      git diff --stat "$base..HEAD"
      ;;
    log)  git log --oneline --graph --decorate "$base..HEAD" ;;
    stat) git diff --stat "$base..HEAD" ;;
    diff) git diff "$base..HEAD" ;;
    *) echo "Usage: g review [log|stat|diff]"; return 1 ;;
  esac
}
