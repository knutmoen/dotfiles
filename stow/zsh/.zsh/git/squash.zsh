g_sq() {
  emulate -L zsh
  setopt LOCAL_OPTIONS NO_SH_WORD_SPLIT

  local interactive=0 n base first msg

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

  # Commit before the squash range
  base="HEAD~$n"

  # First commit IN the squash range (the one we keep the message from)
  first="HEAD~$((n - 1))"

  (( interactive )) && { git rebase -i "$base"; return; }

  msg=$(git log --format=%B -n 1 "$first") || return 1
  git reset --soft "$base" || return 1
  git commit -m "$msg"
}
