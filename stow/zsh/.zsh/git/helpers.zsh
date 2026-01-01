# -----------------------------------------------------------------------------
# Git internal helpers (not user-facing)
# -----------------------------------------------------------------------------

__g_default_branch() {
  local ref

  ref=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null) || true
  if [[ -n "$ref" ]]; then
    echo "${ref#origin/}"
    return 0
  fi

  for b in main develop master; do
    if git show-ref --verify --quiet "refs/remotes/origin/$b"; then
      echo "$b"
      return 0
    fi
  done

  return 1
}

__g_merged_branches() {
  local target="$1"
  git branch --merged "$target" --format='%(refname:short)' 2>/dev/null |
    grep -v -E "^(\\*\\s*)?$target$" || true
}

__g_gone_branches() {
  git for-each-ref --format='%(refname:short) %(upstream:track)' refs/heads 2>/dev/null |
    awk '$2 ~ /\[gone\]/ {print $1}' || true
}

__g_select_commit() {
  if [[ -n "$1" ]]; then
    echo "$1"
    return 0
  fi

  if command -v fzf >/dev/null 2>&1; then
    git log --oneline --color=always |
      fzf --ansi --height=40% --border --prompt="fixup> " |
      awk '{print $1}'
    return 0
  fi

  git rev-parse --verify HEAD~1 2>/dev/null
}
