# stow/zsh/.zsh/mr/projects.zsh
# -----------------------------------------------------------------------------
# mr_project registry
#
# Usage:
#   mr_project <name> <repo-path> [<repo-path> ...]
#
# Stores groups in _MR_PROJECTS as: name → "path1|path2|..."
# -----------------------------------------------------------------------------

typeset -gA _MR_PROJECTS

mr_project() {
  local name="$1"
  shift
  [[ $# -eq 0 ]] && { echo "mr_project: at least one path required" >&2; return 1; }
  local paths=("$@")
  _MR_PROJECTS[$name]="${(j:|:)paths}"
}

# Returns the pipe-separated path string for a project name.
# Prints to stdout; returns 1 if not found.
__mr_repos_for() {
  local name="$1"
  local raw="${_MR_PROJECTS[$name]:-}"
  [[ -z "$raw" ]] && return 1
  echo "$raw"
}

# Infer project from $PWD. Returns first alphabetical match.
# Prints project name to stdout; returns 1 if no match.
__mr_infer_project() {
  local cwd="$PWD"
  local name
  for name in "${(@ko)_MR_PROJECTS}"; do
    local raw="${_MR_PROJECTS[$name]}"
    local paths=("${(s:|:)raw}")
    local p
    for p in "${paths[@]}"; do
      if [[ "$cwd" == "$p" || "$cwd" == "$p"/* ]]; then
        echo "$name"
        return 0
      fi
    done
  done
  return 1
}
