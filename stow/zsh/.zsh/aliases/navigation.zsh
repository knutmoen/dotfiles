# -----------------------------------------------------------------------------
# Navigation helpers
# -----------------------------------------------------------------------------

# Jump to any work project using fzf
cproj() {
  [[ -z "$WORK_PROJECTS_DIR" ]] && {
    echo "WORK_PROJECTS_DIR not set"
    return 1
  }

  local dir
  dir=$(find "$WORK_PROJECTS_DIR" -type d -maxdepth 3 2>/dev/null | fzf) || return
  cd "$dir"
}

# Jump to personal project
cpriv() {
  [[ -z "$PERSONAL_PROJECTS_DIR" ]] && {
    echo "PERSONAL_PROJECTS_DIR not set"
    return 1
  }

  local dir
  dir=$(find "$PERSONAL_PROJECTS_DIR" -type d -maxdepth 3 2>/dev/null | fzf) || return
  cd "$dir"
}

# Jump to any git repository under ~/development
cgit() {
  local dir
  dir=$(find "$HOME/development" -type d -name .git 2>/dev/null \
    | sed 's|/.git$||' \
    | fzf) || return
  cd "$dir"
}