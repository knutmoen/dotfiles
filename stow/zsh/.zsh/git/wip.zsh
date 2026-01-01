g_wip() {
  emulate -L zsh
  setopt LOCAL_OPTIONS NO_SH_WORD_SPLIT

  local msg="WIP" squash=0 current

  while [[ "$1" == --* ]]; do
    case "$1" in
      --squash) squash=1 ;;
      *) echo "❌ Unknown option: $1"; return 1 ;;
    esac
    shift
  done

  [[ $# -gt 0 ]] && msg="$*"

  current=$(git branch --show-current 2>/dev/null)
  [[ -z "$current" ]] && { echo "❌ Detached HEAD."; return 1; }

  git diff --quiet && git diff --cached --quiet && {
    echo "ℹ️ No changes to commit."
    return 0
  }

  git add --all || return 1

  (( squash )) \
    && git commit --amend -m "$msg" --no-verify \
    || git commit -m "$msg" --no-verify
}
