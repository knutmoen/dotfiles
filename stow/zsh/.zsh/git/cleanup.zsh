g_cleanup() {
  emulate -L zsh
  setopt LOCAL_OPTIONS NO_SH_WORD_SPLIT

  local current target target_ref merged gone
  current=$(git branch --show-current 2>/dev/null)
  [[ -z "$current" ]] && { echo "❌ Detached HEAD – cannot cleanup."; return 1; }

  target=$(__g_default_branch) || {
    echo "❌ Could not determine default branch."
    return 1
  }
  target_ref="origin/$target"

  echo "🧹 Cleaning up branches (base: $target_ref)…"

  git fetch origin --prune || return 1

  merged=("${(@f)$(__g_merged_branches "$target_ref")}")
  merged=(${merged:#$current})

  gone=("${(@f)$(__g_gone_branches)}")
  gone=(${gone:#$current})
  gone=(${gone:#$target})

  (( ${#merged[@]} == 0 && ${#gone[@]} == 0 )) && {
    echo "✅ Nothing to clean."
    return 0
  }

  [[ ${#merged[@]} -gt 0 ]] && {
    echo "\nMerged branches:"
    printf "  • %s\n" "${merged[@]}"
  }

  [[ ${#gone[@]} -gt 0 ]] && {
    echo "\nGone branches:"
    printf "  • %s\n" "${gone[@]}"
  }

  echo
  read -r "reply?Delete these branches? [y/N] "
  [[ "$reply" =~ ^[Yy]$ ]] || return 0

  [[ ${#merged[@]} -gt 0 ]] && git branch -d "${merged[@]}" || true
  [[ ${#gone[@]} -gt 0 ]] && git branch -d "${gone[@]}" || true
}
