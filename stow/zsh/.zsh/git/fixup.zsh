g_fixup() {
  emulate -L zsh
  setopt LOCAL_OPTIONS NO_SH_WORD_SPLIT

  local current target base commit do_rebase=1

  while [[ "$1" == --* ]]; do
    case "$1" in
      --no-rebase) do_rebase=0 ;;
      *) echo "❌ Unknown option: $1"; return 1 ;;
    esac
    shift
  done

  current=$(git branch --show-current 2>/dev/null)
  [[ -z "$current" ]] && { echo "❌ Detached HEAD."; return 1; }

  target=$(__g_default_branch) || return 1
  base="origin/$target"

  commit=$(__g_select_commit "$1") || return 1

  git add --all || return 1
  git commit --fixup "$commit" || return 1

  (( do_rebase )) && git rebase -i --autosquash "$base"
}
