# -----------------------------------------------------------------------------
# g tag
#
# Create and push an annotated version tag.
#
# Usage:
#   g tag <version> <message>
#
# Example:
#   g tag 1.0.2 "small fixes and improvements"
# -----------------------------------------------------------------------------

g_tag() {
  emulate -L zsh
  setopt LOCAL_OPTIONS NO_SH_WORD_SPLIT

  local version="$1"
  shift || true

  [[ -n "$version" ]] || {
    echo "❌ Usage: g tag <version> <message>"
    return 1
  }

  [[ $# -gt 0 ]] || {
    echo "❌ Usage: g tag <version> <message>"
    return 1
  }

  local tag="v$version"
  local message="$tag – $*"

  # Ensure working tree is clean
  if ! git diff --quiet || ! git diff --cached --quiet; then
    echo "❌ Working tree is not clean. Commit or stash changes first."
    return 1
  fi

  # Ensure tag does not already exist
  if git rev-parse "$tag" >/dev/null 2>&1; then
    echo "❌ Tag '$tag' already exists."
    return 1
  fi

  git tag -a "$tag" -m "$message" || return 1
  git push origin "$tag"
}
