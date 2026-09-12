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

git_fzf_branch_switch() {
  local branch
  branch=$(
    __g_branch_list_with_metadata "" 0 1 |
      tail -n +2 |
      fzf --height 40% --no-sort --reverse \
          --prompt="Select branch: " \
          --header="SCOPE   LOCAL_REMOTE HEAD_STATUS BRANCH" \
          --query="$1"
  )

  if [[ -n "$branch" ]]; then
    git switch "${branch##* }"
  fi
}

git_fzf_branch_delete() {
  local branch
  branch=$(
    __g_branch_list_with_metadata "" 1 1 |
      tail -n +2 |
      fzf --height 40% --no-sort --reverse \
          --prompt="Delete local branch: " \
          --header="SCOPE   LOCAL_REMOTE HEAD_STATUS BRANCH" \
          --query="$1"
  )

  if [[ -n "$branch" ]]; then
    git branch -d "${branch##* }"
  fi
}

git_reword_commit() {
  if (( $# < 2 )); then
    echo "Bruk: git_reword_commit <nummer> <ny commit-melding>" >&2
    return 2
  fi

  local number="$1"
  shift
  local message="$*"
  local target
  local parent

  if [[ ! "$number" =~ ^[1-9][0-9]*$ ]]; then
    echo "Commit-nummeret må være et positivt heltall." >&2
    return 2
  fi

  if [[ -z "$message" ]]; then
    echo "Commit-meldingen kan ikke være tom." >&2
    return 2
  fi

  if [[ -n "$(git status --porcelain)" ]]; then
    echo "Arbeidsområdet må være rent før rebase." >&2
    return 1
  fi

  target=$(git rev-parse --verify "HEAD~$((number - 1))^{commit}") || {
    echo "Fant ikke commit nummer $number." >&2
    return 1
  }

  parent=$(git rev-parse --verify "${target}^" 2>/dev/null || true)

  if [[ -n "$parent" ]]; then
    GIT_SEQUENCE_EDITOR="sed -i.bak '1s/^pick /edit /'" \
      git rebase -i "$parent" || return 1
  else
    GIT_SEQUENCE_EDITOR="sed -i.bak '1s/^pick /edit /'" \
      git rebase -i --root || return 1
  fi

  git commit --amend -m "$message" || return 1

  GIT_EDITOR=true git rebase --continue
}
