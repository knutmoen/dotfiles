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
  local input resolved

  if [[ -n "$1" ]]; then
    input="$1"
  elif command -v fzf >/dev/null 2>&1; then
    input=$(
      git log --format='%H %s' |
        fzf --height=40% --border --prompt="fixup> " |
        awk '{print $1}'
    )
  else
    input="HEAD~1"
  fi

  [[ -z "$input" ]] && return 1

  if [[ "$input" =~ '^[0-9]+$' ]]; then
    (( input >= 1 )) || { echo "❌ Commit number must be >=1" >&2; return 1; }
    input="HEAD~$((input - 1))"
  fi

  resolved=$(git rev-parse --verify "$input" 2>/dev/null) || {
    echo "❌ Unknown commit: $input" >&2
    return 1
  }

  echo "$resolved"
}
