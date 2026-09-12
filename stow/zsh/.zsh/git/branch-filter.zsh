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

__g_branch_matches_filter() {
  local branch="$1" text="$2" all_branches="${3:-0}"

  (( all_branches )) && return 0

  if [[ -n "$text" ]]; then
    [[ "$branch" == *"$text"* ]]
  else
    [[ "$branch" == *feature/* || "$branch" == *bugfix/* ]]
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
    __g_branch_matches_filter "$branch" "$text" && matches+=("$branch")
  done

  printf "%s\n" "${matches[@]}"
}

__g_branch_list_with_metadata() {
  emulate -L zsh
  setopt LOCAL_OPTIONS NO_SH_WORD_SPLIT

  local text="$1" local_only="${2:-0}" all_branches="${3:-0}"
  local branch ref scope merge_ref merge_label sync_label sync_counts local_ahead remote_ahead
  local -a counts
  local -a local_branches remote_refs branches
  local -A local_refs remote_refs_by_branch seen

  local_branches=("${(@f)$(git for-each-ref --format='%(refname:short)' refs/heads 2>/dev/null)}")
  remote_refs=("${(@f)$(git for-each-ref --format='%(refname)' refs/remotes 2>/dev/null)}")

  for branch in "${local_branches[@]}"; do
    __g_branch_matches_filter "$branch" "$text" "$all_branches" || continue
    local_refs[$branch]=1
    branches+=("$branch")
    seen[$branch]=1
  done

  for ref in "${remote_refs[@]}"; do
    [[ "$ref" == */HEAD ]] && continue

    branch="${ref#refs/remotes/}"
    branch="${branch#*/}"
    __g_branch_matches_filter "$branch" "$text" "$all_branches" || continue
    remote_refs_by_branch[$branch]="$ref"

    (( local_only )) && [[ -z "${local_refs[$branch]-}" ]] && continue

    if [[ -z "${seen[$branch]-}" ]]; then
      branches+=("$branch")
      seen[$branch]=1
    fi
  done

  (( ${#branches[@]} == 0 )) && return 0

  printf "%-7s %-12s %-11s %s\n" "SCOPE" "LOCAL_REMOTE" "HEAD_STATUS" "BRANCH"
  for branch in "${branches[@]}"; do
    if [[ -n "${local_refs[$branch]-}" && -n "${remote_refs_by_branch[$branch]-}" ]]; then
      scope="both"
      sync_counts=$(git rev-list --left-right --count "refs/heads/$branch...${remote_refs_by_branch[$branch]}" 2>/dev/null)
      counts=(${=sync_counts})
      local_ahead="${counts[1]:-0}"
      remote_ahead="${counts[2]:-0}"

      if (( local_ahead == 0 && remote_ahead == 0 )); then
        sync_label="same"
      elif (( local_ahead > 0 && remote_ahead == 0 )); then
        sync_label="local-ahead"
      elif (( local_ahead == 0 && remote_ahead > 0 )); then
        sync_label="local-behind"
      else
        sync_label="diverged"
      fi
    elif [[ -n "${local_refs[$branch]-}" ]]; then
      scope="local"
      sync_label="local-only"
    else
      scope="remote"
      sync_label="remote-only"
    fi

    if [[ -n "${local_refs[$branch]-}" ]]; then
      merge_ref="refs/heads/$branch"
    else
      merge_ref="${remote_refs_by_branch[$branch]}"
    fi

    if git merge-base --is-ancestor "$merge_ref" HEAD >/dev/null 2>&1; then
      merge_label="in-head"
    else
      merge_label="not-in-head"
    fi

    printf "%-7s %-12s %-11s %s\n" "$scope" "$sync_label" "$merge_label" "$branch"
  done
}

g_bfl() {
  emulate -L zsh
  setopt LOCAL_OPTIONS NO_SH_WORD_SPLIT

  local text="$1"
  local -a listing

  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
    echo "❌ Not inside a git repo."
    return 1
  }

  listing=("${(@f)$(__g_branch_list_with_metadata "$text")}")

  if (( ${#listing[@]} == 0 )); then
    echo "No local or remote branches found $(__g_branch_filter_label "$text")."
    return 0
  fi

  printf "%s\n" "${listing[@]}"
}

g_bfd() {
  emulate -L zsh
  setopt LOCAL_OPTIONS NO_SH_WORD_SPLIT

  local text="$1" current
  local skipped_current=0
  local -a matches

  [[ -z "$text" ]] && {
    echo "❌ Usage: g bfd <branch>"
    return 1
  }

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
