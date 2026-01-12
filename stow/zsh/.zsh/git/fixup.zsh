g_fixup() {
  emulate -L zsh
  setopt LOCAL_OPTIONS NO_SH_WORD_SPLIT

  local current commit base ahead behind do_rebase=1

  while [[ "$1" == --* ]]; do
    case "$1" in
      --no-rebase) do_rebase=0 ;;
      *) echo "❌ Unknown option: $1"; return 1 ;;
    esac
    shift
  done

  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
    echo "❌ Not inside a git repo."
    return 1
  }

  current=$(git branch --show-current 2>/dev/null)
  [[ -z "$current" ]] && { echo "❌ Detached HEAD."; return 1; }

  commit=$(__g_select_commit "$1") || return 1

  git merge-base --is-ancestor "$commit" HEAD >/dev/null 2>&1 || {
    echo "❌ Commit is not in the current branch history."
    return 1
  }

  if git diff --quiet && git diff --cached --quiet; then
    echo "❌ No changes to fix up."
    return 1
  fi

  if git rev-parse --abbrev-ref --symbolic-full-name @{u} >/dev/null 2>&1; then
    ahead=$(git rev-list --count @{u}..HEAD)
    behind=$(git rev-list --count HEAD..@{u})

    if (( behind > 0 )); then
      echo "❌ Branch is behind upstream; pull first."
      return 1
    fi

    (( ahead == 0 )) && echo "⚠️  No local commits ahead of upstream; rebasing may rewrite published history."
  fi

  if git diff --cached --quiet; then
    echo "ℹ️  Staging all changes."
    git add --all || return 1
  else
    echo "ℹ️  Using already staged changes."
  fi

  git commit --fixup "$commit" || return 1

  (( do_rebase )) || { echo "ℹ️  Skipping autosquash rebase (--no-rebase)."; return 0; }

  if git rev-parse --verify "${commit}^" >/dev/null 2>&1; then
    base=$(git rev-parse "${commit}^")
    GIT_SEQUENCE_EDITOR=true git rebase -i --autosquash "$base" || return 1
  else
    GIT_SEQUENCE_EDITOR=true git rebase -i --autosquash --root || return 1
  fi

  echo "✅ Fixup applied to $(git rev-parse --short "$commit")."
}
