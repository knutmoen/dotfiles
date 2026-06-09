# -----------------------------------------------------------------------------
# Filtered branch helpers
# -----------------------------------------------------------------------------

__g_branch_filter_label() {
  local text="$1"

  if [[ -n "$text" ]]; then
    printf "containing '%s'" "$text"
  else
    printf "containing 'feature/' or 'bugfix/'"
  fi
}

__g_matching_branches() {
  emulate -L zsh
  setopt LOCAL_OPTIONS NO_SH_WORD_SPLIT

  local text="$1"
  local branch
  local -a branches matches

  branches=("${(@f)$(git for-each-ref --format='%(refname:short)' refs/heads 2>/dev/null)}")

  for branch in "${branches[@]}"; do
    if [[ -n "$text" ]]; then
      [[ "$branch" == *"$text"* ]] && matches+=("$branch")
    else
      [[ "$branch" == *feature/* || "$branch" == *bugfix/* ]] && matches+=("$branch")
    fi
  done

  printf "%s\n" "${matches[@]}"
}

g_bfl() {
  emulate -L zsh
  setopt LOCAL_OPTIONS NO_SH_WORD_SPLIT

  local text="$1"
  local -a matches

  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
    echo "❌ Not inside a git repo."
    return 1
  }

  matches=("${(@f)$(__g_matching_branches "$text")}")

  if (( ${#matches[@]} == 0 )); then
    echo "No local branches found $(__g_branch_filter_label "$text")."
    return 0
  fi

  printf "%s\n" "${matches[@]}"
}

g_bfd() {
  emulate -L zsh
  setopt LOCAL_OPTIONS NO_SH_WORD_SPLIT

  local text="$1" current
  local skipped_current=0
  local -a matches

  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
    echo "❌ Not inside a git repo."
    return 1
  }

  matches=("${(@f)$(__g_matching_branches "$text")}")

  if (( ${#matches[@]} == 0 )); then
    echo "No local branches found $(__g_branch_filter_label "$text")."
    return 0
  fi

  current=$(git branch --show-current 2>/dev/null)
  if [[ -n "$current" && ${matches[(Ie)$current]} -gt 0 ]]; then
    matches=(${matches:#$current})
    skipped_current=1
  fi

  if (( ${#matches[@]} == 0 )); then
    echo "No matching local branches can be deleted."
    (( skipped_current )) && echo "Skipped current branch: $current"
    return 0
  fi

  git branch -D "${matches[@]}" || return 1

  (( skipped_current )) && echo "Skipped current branch: $current"
}
