g_sq() {
  emulate -L zsh
  setopt LOCAL_OPTIONS NO_SH_WORD_SPLIT

  local interactive=0 n base msg

  while [[ "$1" == --* ]]; do
    case "$1" in
      --interactive|-i) interactive=1 ;;
      *) echo "❌ Unknown option: $1"; return 1 ;;
    esac
    shift
  done

  n="${1:-2}"

  [[ ! "$n" =~ '^[0-9]+$' || "$n" -lt 2 ]] && {
    echo "❌ Usage: g sq [N>=2] [--interactive|-i]"
    return 1
  }

  [[ -z "$(git branch --show-current 2>/dev/null)" ]] && {
    echo "❌ Detached HEAD."
    return 1
  }

  base="HEAD~$n"

  (( interactive )) && { git rebase -i "$base"; return; }

  msg=$(git log --format=%B -n 1 "$base") || return 1
  git reset --soft "$base" || return 1
  git commit -m "$msg"
}
