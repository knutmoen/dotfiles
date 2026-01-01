# -----------------------------------------------------------------------------
# Node.js runtime policy (silent, PATH-safe, no external commands in init)
# -----------------------------------------------------------------------------

# Internal: remove existing Homebrew Node paths from PATH
# Uses only zsh builtins (safe during init)
_node_clean_path() {
  local new_path=()
  local dir

  for dir in ${(s/:/)PATH}; do
    [[ "$dir" == /opt/homebrew/opt/node@*/bin ]] && continue
    new_path+=("$dir")
  done

  PATH="${(j/:/)new_path}"
}

# -----------------------------------------------------------------------------
# Default Node version
# -----------------------------------------------------------------------------
# Policy:
# - One explicit default (LTS)
# - Silent if not installed
# - No brew calls

if [[ -x /opt/homebrew/opt/node@20/bin/node ]]; then
  _node_clean_path
  PATH="/opt/homebrew/opt/node@20/bin:$PATH"
fi

# -----------------------------------------------------------------------------
# Switch Node version (interactive use)
# -----------------------------------------------------------------------------

n() {
  [[ -n "$1" ]] || {
    echo "Usage: n <version>"
    return 1
  }

  local dir="/opt/homebrew/opt/node@$1/bin"

  if [[ ! -x "$dir/node" ]]; then
    echo "❌ Node $1 not installed"
    echo
    echo "Installed versions:"
    nls
    return 1
  fi

  _node_clean_path
  PATH="$dir:$PATH"

  echo "⬢ Node $(node -v)"
}

# -----------------------------------------------------------------------------
# List installed Node versions
# -----------------------------------------------------------------------------

nls() {
  local d name
  for d in /opt/homebrew/opt/node@*/bin; do
    [[ -x "$d/node" ]] || continue
    name="${d:h:t}"      # -> node@18
    echo "${name#node@}" # -> 18
  done
}


# -----------------------------------------------------------------------------
# Delete installed Node versions
# -----------------------------------------------------------------------------

nd() {
  [[ -n "$1" ]] || {
    echo "Usage: nd <version>"
    echo
    echo "Installed Node versions:"
    nls
    return 1
  }

  local version="$1"
  local found=0
  local v

  for v in $(nls); do
    [[ "$v" == "$version" ]] && found=1
  done

  if [[ "$found" -ne 1 ]]; then
    echo "❌ Node $version is not installed."
    echo
    echo "Installed Node versions:"
    nls
    return 1
  fi

  echo "⚠️  This will uninstall Node $version (Homebrew formula: node@$version)"
  read -r "?Proceed? [y/N] " confirm

  [[ "$confirm" == "y" || "$confirm" == "Y" ]] || {
    echo "Aborted."
    return 1
  }

  brew uninstall "node@$version"

  echo "✅ Node $version uninstalled."
}


