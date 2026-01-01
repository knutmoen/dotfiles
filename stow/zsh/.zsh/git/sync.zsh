g_sync() {
  emulate -L zsh
  setopt LOCAL_OPTIONS NO_SH_WORD_SPLIT

  local current target

  current=$(git branch --show-current 2>/dev/null)
  [[ -z "$current" ]] && { echo "❌ Detached HEAD – cannot sync."; return 1; }

  target=$(__g_default_branch) || {
    echo "❌ Could not determine default branch."
    return 1
  }

  echo "🔄 Syncing '$current' with '$target'…"

  git fetch origin || return 1

  if [[ "$current" == "$target" ]]; then
    git pull --rebase
  else
    git rebase "origin/$target"
  fi
}
