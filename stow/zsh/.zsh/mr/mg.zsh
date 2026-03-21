# stow/zsh/.zsh/mr/mg.zsh
# -----------------------------------------------------------------------------
# mg — multi-git: run git operations across a group of repos
# -----------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# Internal helpers
# ---------------------------------------------------------------------------

# Print a formatted status line for one repo.
__mg_repo_label() {
  local dir="$1"
  local name="${dir##*/}"
  local branch
  branch=$(git -C "$dir" branch --show-current 2>/dev/null) || branch="(detached)"

  local unpushed=0
  if git -C "$dir" rev-parse @{u} &>/dev/null; then
    unpushed=$(git -C "$dir" log @{u}..HEAD --oneline 2>/dev/null | wc -l | tr -d ' ')
  fi

  local dirty_count
  dirty_count=$(git -C "$dir" status --porcelain 2>/dev/null | wc -l | tr -d ' ')

  local status_str=""
  if [[ "$dirty_count" -gt 0 && "$unpushed" -gt 0 ]]; then
    status_str="↑${unpushed} commit(s), ${dirty_count} modified"
  elif [[ "$dirty_count" -gt 0 ]]; then
    status_str="${dirty_count} modified"
  elif [[ "$unpushed" -gt 0 ]]; then
    status_str="↑${unpushed} commit(s)"
  else
    status_str="✓ clean"
  fi

  printf "  %-22s %-20s %s\n" "$name" "$branch" "$status_str"
}

# Auto-stash if dirty. Prints "stashed" if stash was created, "" if not.
__mg_maybe_stash() {
  local dir="$1"
  if git -C "$dir" status --porcelain 2>/dev/null | grep -q .; then
    git -C "$dir" stash push --quiet && echo "stashed" || echo ""
  else
    echo ""
  fi
}

# Pop stash. Returns 1 on failure (conflict or otherwise).
__mg_stash_pop() {
  local dir="$1"
  git -C "$dir" stash pop --quiet 2>/dev/null || return 1
}

# Resolve project name from arg, $PWD inference, or fail.
__mg_resolve_project() {
  local arg="${1:-}"
  if [[ -n "$arg" && -n "${_MR_PROJECTS[$arg]:-}" ]]; then
    echo "$arg"
    return 0
  fi
  if [[ -n "$arg" ]]; then
    echo "❌ Unknown project: '$arg'" >&2
    return 1
  fi
  local inferred
  inferred=$(__mr_infer_project 2>/dev/null) && echo "$inferred" && return 0
  return 1
}

# ---------------------------------------------------------------------------
# Commands
# ---------------------------------------------------------------------------

_mg_list() {
  if [[ ${#_MR_PROJECTS} -eq 0 ]]; then
    echo "No projects registered. Add to ~/.zshrc:"
    echo "  mr_project <name> <path> [<path> ...]"
    return
  fi
  echo "Registered projects:"
  local name
  for name in "${(@ko)_MR_PROJECTS}"; do
    echo "  $name"
    local raw="${_MR_PROJECTS[$name]}"
    local paths=("${(s:|:)raw}")
    local p
    for p in "${paths[@]}"; do
      echo "    $p"
    done
  done
}

_mg_help() {
  cat <<'EOF'
mg — multi-git: run git operations across a group of repos

Usage: mg [command] [project] [args]

Commands:
  (none)               List registered projects
  help                 Show this help
  st   [project]       Status summary for all repos
  fetch [project]      Fetch from origin on all repos
  branch [project] <name> [--all]
                       Create branch per repo (interactive, --all skips prompts)
  co   [project] <branch>
                       Checkout branch across repos (skip if branch missing)
  pull [project]       Smart pull: auto-stash dirty repos, pull, pop stash
  push [project]       Smart push: only repos with unpushed commits
  sync [project]       Fetch + rebase/pull onto default branch per repo

Project is inferred from $PWD if omitted.
EOF
}

_mg_st() {
  local project
  project=$(__mg_resolve_project "${1:-}") || { echo "No project inferred from current directory. Registered projects:"; _mg_list; return 0; }
  echo "● $project"
  local raw="${_MR_PROJECTS[$project]}"
  local repos=("${(s:|:)raw}")
  local r
  for r in "${repos[@]}"; do
    if [[ ! -d "$r/.git" ]]; then
      printf "  %-22s %s\n" "${r##*/}" "⚠️  not a git repo"
    else
      __mg_repo_label "$r"
    fi
  done
}

# ---------------------------------------------------------------------------
# Dispatcher (stub entries for Tasks 3–8 — implementations added per task)
# ---------------------------------------------------------------------------

_mg_fetch() {
  local project
  project=$(__mg_resolve_project "${1:-}") || return 1
  echo "● $project — fetching"
  local raw="${_MR_PROJECTS[$project]}"
  local repos=("${(s:|:)raw}")
  local r
  for r in "${repos[@]}"; do
    printf "  %-22s" "${r##*/}"
    if git -C "$r" fetch origin --quiet 2>/dev/null; then
      echo "✓ fetched"
    else
      echo "❌ fetch failed (no remote?)"
    fi
  done
}
_mg_branch() { echo "❌ mg branch not yet implemented" >&2; return 1; }
_mg_co()     { echo "❌ mg co not yet implemented" >&2; return 1; }
_mg_pull()   { echo "❌ mg pull not yet implemented" >&2; return 1; }
_mg_push()   { echo "❌ mg push not yet implemented" >&2; return 1; }
_mg_sync()   { echo "❌ mg sync not yet implemented" >&2; return 1; }

mg() {
  emulate -L zsh
  setopt LOCAL_OPTIONS NO_SH_WORD_SPLIT

  local cmd="${1:-}"
  [[ -n "$cmd" ]] && shift || true

  case "$cmd" in
    "")      _mg_list ;;
    help)    _mg_help ;;
    st)      _mg_st "$@" ;;
    fetch)   _mg_fetch "$@" ;;
    branch)  _mg_branch "$@" ;;
    co)      _mg_co "$@" ;;
    pull)    _mg_pull "$@" ;;
    push)    _mg_push "$@" ;;
    sync)    _mg_sync "$@" ;;
    *)       echo "❌ Unknown mg command: '$cmd'. Run 'mg help' for usage." >&2; return 1 ;;
  esac
}
