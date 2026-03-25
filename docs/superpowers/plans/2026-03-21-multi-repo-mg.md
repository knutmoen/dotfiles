# Multi-Repo `mg` Command Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a `mg` ("multi-git") command to the zsh dotfiles that manages named groups of git repos with state-aware multi-repo operations (status, branch, checkout, pull, push, sync).

**Architecture:** Two new zsh files under `stow/zsh/.zsh/mr/` — `projects.zsh` for the group registry and `mg.zsh` for the command implementation. All git operations use `git -C <dir>` to avoid changing directories. A new source block in `stow/zsh/.zshrc` loads the `mr/` directory. User-specific project paths are registered in `~/.zshrc` (not version-controlled).

**Tech Stack:** zsh, git (no new Homebrew dependencies)

---

### Task 1: Create `projects.zsh` — group registry

**Files:**
- Create: `stow/zsh/.zsh/mr/projects.zsh`

- [ ] **Step 1: Create the file**

```zsh
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
```

- [ ] **Step 2: Verify the registry by sourcing in a fresh zsh**

```zsh
zsh -c '
  source stow/zsh/.zsh/mr/projects.zsh
  mr_project test "/tmp/repo-a" "/tmp/repo-b"
  echo "${_MR_PROJECTS[test]}"
'
# Expected output: /tmp/repo-a|/tmp/repo-b
```

- [ ] **Step 3: Commit**

```bash
git add stow/zsh/.zsh/mr/projects.zsh
git commit -m "feat(mg): add mr_project registry"
```

---

### Task 2: `mg.zsh` — dispatcher, list, help, and `mg st`

**Files:**
- Create: `stow/zsh/.zsh/mr/mg.zsh`

- [ ] **Step 1: Set up two local test repos (used by verification steps in Tasks 2–5)**

```bash
mkdir -p /tmp/mg-test/repo-a /tmp/mg-test/repo-b
git -C /tmp/mg-test/repo-a init -b main && git -C /tmp/mg-test/repo-a commit --allow-empty -m "init"
git -C /tmp/mg-test/repo-b init -b main && git -C /tmp/mg-test/repo-b commit --allow-empty -m "init"
```

- [ ] **Step 2: Create `mg.zsh` with shared helpers, `mg st`, and the dispatcher**

```zsh
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
  if git -C "$dir" rev-parse @{u} &>/dev/null 2>&1; then
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
    git -C "$dir" stash push --quiet 2>/dev/null && echo "stashed" || echo ""
  else
    echo ""
  fi
}

# Pop stash. Returns 1 on conflict.
__mg_stash_pop() {
  local dir="$1"
  git -C "$dir" stash pop --quiet 2>/dev/null
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
  project=$(__mg_resolve_project "${1:-}") || { _mg_list; return 0; }
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

_mg_fetch()  { echo "❌ mg fetch not yet implemented" >&2; return 1; }
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
```

- [ ] **Step 3: Verify list and help**

```zsh
zsh -c '
  source stow/zsh/.zsh/mr/projects.zsh
  source stow/zsh/.zsh/mr/mg.zsh
  mr_project demo "/tmp/mg-test/repo-a" "/tmp/mg-test/repo-b"
  mg
  echo "---"
  mg help
'
# Expected: "demo" listed with both paths, then command reference
```

- [ ] **Step 4: Verify `mg st`**

```zsh
zsh -c '
  source stow/zsh/.zsh/mr/projects.zsh
  source stow/zsh/.zsh/mr/mg.zsh
  mr_project demo "/tmp/mg-test/repo-a" "/tmp/mg-test/repo-b"
  mg st demo
'
# Expected:
# ● demo
#   repo-a                 main                 ✓ clean
#   repo-b                 main                 ✓ clean
```

- [ ] **Step 5: Verify `mg st` infers project from $PWD**

```zsh
zsh -c '
  source stow/zsh/.zsh/mr/projects.zsh
  source stow/zsh/.zsh/mr/mg.zsh
  mr_project demo "/tmp/mg-test/repo-a" "/tmp/mg-test/repo-b"
  cd /tmp/mg-test/repo-a
  mg st
'
# Expected: same output as above (inferred "demo" from PWD)
```

- [ ] **Step 6: Commit**

```bash
git add stow/zsh/.zsh/mr/mg.zsh
git commit -m "feat(mg): add dispatcher, list, help, st"
```

---

### Task 3: `mg fetch`

**Files:**
- Modify: `stow/zsh/.zsh/mr/mg.zsh` — replace `_mg_fetch` stub

- [ ] **Step 1: Replace the `_mg_fetch` stub with the implementation**

Find:
```zsh
_mg_fetch()  { echo "❌ mg fetch not yet implemented" >&2; return 1; }
```

Replace with:
```zsh
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
```

- [ ] **Step 2: Verify (test repos have no remote — expect "fetch failed")**

```zsh
zsh -c '
  source stow/zsh/.zsh/mr/projects.zsh
  source stow/zsh/.zsh/mr/mg.zsh
  mr_project demo "/tmp/mg-test/repo-a" "/tmp/mg-test/repo-b"
  mg fetch demo
'
# Expected: both repos show "❌ fetch failed (no remote?)" — no crash
```

- [ ] **Step 3: Commit**

```bash
git add stow/zsh/.zsh/mr/mg.zsh
git commit -m "feat(mg): add mg fetch"
```

---

### Task 4: `mg branch` — interactive branch creation

**Files:**
- Modify: `stow/zsh/.zsh/mr/mg.zsh` — replace `_mg_branch` stub

- [ ] **Step 1: Replace the `_mg_branch` stub**

Find:
```zsh
_mg_branch() { echo "❌ mg branch not yet implemented" >&2; return 1; }
```

Replace with:
```zsh
_mg_branch() {
  local project branch skip_prompt=0
  local args=()
  local a
  for a in "$@"; do
    [[ "$a" == "--all" ]] && skip_prompt=1 || args+=("$a")
  done

  if [[ ${#args[@]} -eq 2 ]]; then
    project="${args[1]}"; branch="${args[2]}"
  elif [[ ${#args[@]} -eq 1 ]]; then
    branch="${args[1]}"
  else
    echo "Usage: mg branch [project] <branch-name> [--all]" >&2; return 1
  fi

  project=$(__mg_resolve_project "${project:-}") || return 1
  [[ -z "$branch" ]] && { echo "❌ Branch name required." >&2; return 1; }

  echo "● $project — create branch '$branch'?"
  local raw="${_MR_PROJECTS[$project]}"
  local repos=("${(s:|:)raw}")
  local r answer
  for r in "${repos[@]}"; do
    local name="${r##*/}"
    local current
    current=$(git -C "$r" branch --show-current 2>/dev/null) || current="(detached)"

    if git -C "$r" show-ref --verify --quiet "refs/heads/$branch" 2>/dev/null; then
      # Branch already exists — offer to switch
      printf "  %-22s [%s] already exists — switch? [y/n] " "$name" "$current"
      if [[ "$skip_prompt" -eq 1 ]]; then
        echo "y (--all)"
        git -C "$r" checkout "$branch" --quiet 2>/dev/null && echo "    ✓ switched" || echo "    ❌ failed"
      else
        read -r answer </dev/tty
        if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
          git -C "$r" checkout "$branch" --quiet 2>/dev/null && echo "    ✓ switched" || echo "    ❌ failed"
        else
          echo "    skipped"
        fi
      fi
    else
      # New branch
      printf "  %-22s [%s] create? [y/n] " "$name" "$current"
      if [[ "$skip_prompt" -eq 1 ]]; then
        echo "y (--all)"
        git -C "$r" checkout -b "$branch" --quiet 2>/dev/null && echo "    ✓ created" || echo "    ❌ failed"
      else
        read -r answer </dev/tty
        if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
          git -C "$r" checkout -b "$branch" --quiet 2>/dev/null && echo "    ✓ created" || echo "    ❌ failed"
        else
          echo "    skipped"
        fi
      fi
    fi
  done
}
```

- [ ] **Step 2: Verify interactive prompts (answer y for repo-a, n for repo-b)**

```zsh
source stow/zsh/.zsh/mr/projects.zsh
source stow/zsh/.zsh/mr/mg.zsh
mr_project demo "/tmp/mg-test/repo-a" "/tmp/mg-test/repo-b"
mg branch demo feature/test
# Enter: y <enter> n <enter>
# Expected: repo-a gets feature/test, repo-b skipped
```

- [ ] **Step 3: Verify `--all` creates on both repos**

```zsh
mg branch demo feature/test2 --all
# Expected: both repos get branch without prompting
```

- [ ] **Step 4: Verify "already exists" path**

```zsh
mg branch demo feature/test --all
# Expected: both repos show "already exists — switch? y (--all)  ✓ switched"
```

- [ ] **Step 5: Commit**

```bash
git add stow/zsh/.zsh/mr/mg.zsh
git commit -m "feat(mg): add mg branch with interactive prompts"
```

---

### Task 5: `mg co` — smart checkout

**Files:**
- Modify: `stow/zsh/.zsh/mr/mg.zsh` — replace `_mg_co` stub

- [ ] **Step 1: Replace the `_mg_co` stub**

Find:
```zsh
_mg_co()     { echo "❌ mg co not yet implemented" >&2; return 1; }
```

Replace with:
```zsh
_mg_co() {
  local project branch
  if [[ $# -eq 2 ]]; then
    project="$1"; branch="$2"
  elif [[ $# -eq 1 ]]; then
    branch="$1"
  else
    echo "Usage: mg co [project] <branch>" >&2; return 1
  fi

  project=$(__mg_resolve_project "${project:-}") || return 1
  [[ -z "$branch" ]] && { echo "❌ Branch name required." >&2; return 1; }

  echo "● $project — checkout '$branch'"
  local raw="${_MR_PROJECTS[$project]}"
  local repos=("${(s:|:)raw}")
  local needs_attention=()
  local r
  for r in "${repos[@]}"; do
    local name="${r##*/}"
    # Check if branch exists locally or on remote
    local exists=0
    git -C "$r" show-ref --verify --quiet "refs/heads/$branch" 2>/dev/null && exists=1
    [[ "$exists" -eq 0 ]] && git -C "$r" show-ref --verify --quiet "refs/remotes/origin/$branch" 2>/dev/null && exists=1

    if [[ "$exists" -eq 0 ]]; then
      printf "  %-22s skipped (branch not found)\n" "$name"
      continue
    fi

    local stashed=""
    stashed=$(__mg_maybe_stash "$r")

    if git -C "$r" checkout "$branch" --quiet 2>/dev/null; then
      if [[ -n "$stashed" ]]; then
        if __mg_stash_pop "$r"; then
          printf "  %-22s ✓ checked out (stash restored)\n" "$name"
        else
          printf "  %-22s ⚠️  checked out but stash pop conflicted — resolve manually\n" "$name"
          needs_attention+=("$name")
        fi
      else
        printf "  %-22s ✓ checked out\n" "$name"
      fi
    else
      [[ -n "$stashed" ]] && __mg_stash_pop "$r" 2>/dev/null || true
      printf "  %-22s ❌ checkout failed\n" "$name"
    fi
  done

  if [[ ${#needs_attention[@]} -gt 0 ]]; then
    echo ""
    echo "⚠️  Needs attention:"
    local n
    for n in "${needs_attention[@]}"; do echo "  $n"; done
  fi
}
```

- [ ] **Step 2: Verify checkout of an existing branch**

```zsh
source stow/zsh/.zsh/mr/projects.zsh
source stow/zsh/.zsh/mr/mg.zsh
mr_project demo "/tmp/mg-test/repo-a" "/tmp/mg-test/repo-b"
# repo-a has feature/test (created in Task 4), repo-b does not
mg co demo feature/test
# Expected:
#   repo-a   ✓ checked out
#   repo-b   skipped (branch not found)
```

- [ ] **Step 3: Verify auto-stash on dirty repo**

```bash
echo "dirty" > /tmp/mg-test/repo-a/dirty.txt
```

```zsh
mg co demo main
# Expected: repo-a stashes, checks out main, pops stash → "✓ checked out (stash restored)"
# Cleanup:
```

```bash
rm /tmp/mg-test/repo-a/dirty.txt
```

- [ ] **Step 4: Commit**

```bash
git add stow/zsh/.zsh/mr/mg.zsh
git commit -m "feat(mg): add mg co (smart checkout)"
```

---

### Task 6: `mg pull` — smart pull

**Files:**
- Modify: `stow/zsh/.zsh/mr/mg.zsh` — replace `_mg_pull` stub

- [ ] **Step 1: Replace the `_mg_pull` stub**

Find:
```zsh
_mg_pull()   { echo "❌ mg pull not yet implemented" >&2; return 1; }
```

Replace with:
```zsh
_mg_pull() {
  local project
  project=$(__mg_resolve_project "${1:-}") || return 1
  echo "● $project — pulling"
  local raw="${_MR_PROJECTS[$project]}"
  local repos=("${(s:|:)raw}")
  local needs_attention=()
  local r
  for r in "${repos[@]}"; do
    local name="${r##*/}"
    local stashed=""
    stashed=$(__mg_maybe_stash "$r")

    if git -C "$r" pull --rebase --quiet 2>/dev/null; then
      if [[ -n "$stashed" ]]; then
        if __mg_stash_pop "$r"; then
          printf "  %-22s ✓ pulled (stash restored)\n" "$name"
        else
          printf "  %-22s ⚠️  pulled but stash pop conflicted — resolve manually\n" "$name"
          needs_attention+=("$name")
        fi
      else
        printf "  %-22s ✓ pulled\n" "$name"
      fi
    else
      [[ -n "$stashed" ]] && __mg_stash_pop "$r" 2>/dev/null || true
      printf "  %-22s ❌ pull failed (no remote?)\n" "$name"
      needs_attention+=("$name")
    fi
  done

  if [[ ${#needs_attention[@]} -gt 0 ]]; then
    echo ""
    echo "⚠️  Needs attention:"
    local n
    for n in "${needs_attention[@]}"; do echo "  $n"; done
  fi
}
```

- [ ] **Step 2: Verify pull (repos have no remote — expect "pull failed")**

```zsh
zsh -c '
  source stow/zsh/.zsh/mr/projects.zsh
  source stow/zsh/.zsh/mr/mg.zsh
  mr_project demo "/tmp/mg-test/repo-a" "/tmp/mg-test/repo-b"
  mg pull demo
'
# Expected: both show "❌ pull failed (no remote?)" — no crash
```

- [ ] **Step 3: Verify pull works on a repo with a real remote**

```zsh
zsh -c '
  source stow/zsh/.zsh/mr/projects.zsh
  source stow/zsh/.zsh/mr/mg.zsh
  mr_project dotfiles "$HOME/dotfiles"
  mg pull dotfiles
'
# Expected: ✓ pulled (dotfiles repo has origin)
```

- [ ] **Step 4: Commit**

```bash
git add stow/zsh/.zsh/mr/mg.zsh
git commit -m "feat(mg): add mg pull (smart pull with auto-stash)"
```

---

### Task 7: `mg push` — smart push

**Files:**
- Modify: `stow/zsh/.zsh/mr/mg.zsh` — replace `_mg_push` stub

- [ ] **Step 1: Replace the `_mg_push` stub**

Find:
```zsh
_mg_push()   { echo "❌ mg push not yet implemented" >&2; return 1; }
```

Replace with:
```zsh
_mg_push() {
  local project
  project=$(__mg_resolve_project "${1:-}") || return 1
  echo "● $project — pushing"
  local raw="${_MR_PROJECTS[$project]}"
  local repos=("${(s:|:)raw}")
  local r
  for r in "${repos[@]}"; do
    local name="${r##*/}"
    local has_upstream=0
    git -C "$r" rev-parse @{u} &>/dev/null 2>&1 && has_upstream=1

    local unpushed=0
    if [[ "$has_upstream" -eq 1 ]]; then
      unpushed=$(git -C "$r" log @{u}..HEAD --oneline 2>/dev/null | wc -l | tr -d ' ')
    else
      unpushed=$(git -C "$r" log --oneline 2>/dev/null | wc -l | tr -d ' ')
    fi

    if [[ "$unpushed" -eq 0 ]]; then
      printf "  %-22s nothing to push\n" "$name"
      continue
    fi

    if [[ "$has_upstream" -eq 1 ]]; then
      if git -C "$r" push --quiet 2>/dev/null; then
        printf "  %-22s ✓ pushed\n" "$name"
      else
        printf "  %-22s ❌ push failed\n" "$name"
      fi
    else
      if git -C "$r" push -u origin HEAD --quiet 2>/dev/null; then
        printf "  %-22s ✓ pushed (upstream set)\n" "$name"
      else
        printf "  %-22s ❌ push failed (no remote?)\n" "$name"
      fi
    fi
  done
}
```

- [ ] **Step 2: Verify "nothing to push" path**

```zsh
zsh -c '
  source stow/zsh/.zsh/mr/projects.zsh
  source stow/zsh/.zsh/mr/mg.zsh
  mr_project dotfiles "$HOME/dotfiles"
  mg push dotfiles
'
# Expected: "nothing to push" (dotfiles is clean and up-to-date)
```

- [ ] **Step 3: Commit**

```bash
git add stow/zsh/.zsh/mr/mg.zsh
git commit -m "feat(mg): add mg push (smart push)"
```

---

### Task 8: `mg sync`

**Files:**
- Modify: `stow/zsh/.zsh/mr/mg.zsh` — replace `_mg_sync` stub, add `__mg_default_branch` helper

Note: the existing `__g_default_branch` helper in `helpers.zsh` operates on `$PWD`. We need a local version that accepts a directory path argument.

- [ ] **Step 1: Add `__mg_default_branch` to the internal helpers section, and replace the `_mg_sync` stub**

Add after `__mg_stash_pop`:
```zsh
# Like __g_default_branch but accepts a repo directory argument.
__mg_default_branch() {
  local dir="$1"
  local ref
  ref=$(git -C "$dir" symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null) || true
  if [[ -n "$ref" ]]; then
    echo "${ref#origin/}"
    return 0
  fi
  local b
  for b in main develop master; do
    if git -C "$dir" show-ref --verify --quiet "refs/remotes/origin/$b" 2>/dev/null; then
      echo "$b"; return 0
    fi
  done
  # Fall back to local branches when no remote exists
  for b in main develop master; do
    if git -C "$dir" show-ref --verify --quiet "refs/heads/$b" 2>/dev/null; then
      echo "$b"; return 0
    fi
  done
  return 1
}
```

Find:
```zsh
_mg_sync()   { echo "❌ mg sync not yet implemented" >&2; return 1; }
```

Replace with:
```zsh
_mg_sync() {
  local project
  project=$(__mg_resolve_project "${1:-}") || return 1
  echo "● $project — syncing"
  local raw="${_MR_PROJECTS[$project]}"
  local repos=("${(s:|:)raw}")
  local needs_attention=()
  local r
  for r in "${repos[@]}"; do
    local name="${r##*/}"
    local stashed=""
    stashed=$(__mg_maybe_stash "$r")

    git -C "$r" fetch origin --quiet 2>/dev/null || true

    local default current
    default=$(__mg_default_branch "$r") || {
      [[ -n "$stashed" ]] && __mg_stash_pop "$r" 2>/dev/null || true
      printf "  %-22s ❌ could not determine default branch\n" "$name"
      needs_attention+=("$name")
      continue
    }
    current=$(git -C "$r" branch --show-current 2>/dev/null) || current=""

    local ok=0
    if [[ "$current" == "$default" ]]; then
      git -C "$r" pull --rebase --quiet 2>/dev/null && ok=1
    else
      git -C "$r" rebase "origin/$default" --quiet 2>/dev/null && ok=1
    fi

    if [[ "$ok" -eq 1 ]]; then
      if [[ -n "$stashed" ]]; then
        if __mg_stash_pop "$r"; then
          printf "  %-22s ✓ synced (stash restored)\n" "$name"
        else
          printf "  %-22s ⚠️  synced but stash pop conflicted — resolve manually\n" "$name"
          needs_attention+=("$name")
        fi
      else
        printf "  %-22s ✓ synced\n" "$name"
      fi
    else
      [[ -n "$stashed" ]] && __mg_stash_pop "$r" 2>/dev/null || true
      printf "  %-22s ❌ sync failed\n" "$name"
      needs_attention+=("$name")
    fi
  done

  if [[ ${#needs_attention[@]} -gt 0 ]]; then
    echo ""
    echo "⚠️  Needs attention:"
    local n
    for n in "${needs_attention[@]}"; do echo "  $n"; done
  fi
}
```

- [ ] **Step 2: Verify sync with the dotfiles repo**

```zsh
zsh -c '
  source stow/zsh/.zsh/mr/projects.zsh
  source stow/zsh/.zsh/mr/mg.zsh
  mr_project dotfiles "$HOME/dotfiles"
  mg sync dotfiles
'
# Expected: ✓ synced (or ❌ sync failed if remote is unreachable — no crash)
```

- [ ] **Step 3: Commit**

```bash
git add stow/zsh/.zsh/mr/mg.zsh
git commit -m "feat(mg): add mg sync"
```

---

### Task 9: Wire `.zshrc` and end-to-end smoke test

**Files:**
- Modify: `stow/zsh/.zshrc` — add `mr/` source block

- [ ] **Step 1: Add the `mr/` source block to `stow/zsh/.zshrc`**

In `stow/zsh/.zshrc`, after the `git/` sourcing block (after line 49), add:

```zsh
# -----------------------------------------------------------------------------
# Multi-repo (mg) modules
# -----------------------------------------------------------------------------

for file in "$ZSH_CONFIG_DIR/mr/"*.zsh; do
  [[ -r "$file" ]] && source "$file"
done
```

- [ ] **Step 2: Add `mr_project` calls to `~/.zshrc` (machine-specific, not version-controlled)**

In `~/.zshrc`, directly after the existing `tmux_project admin ...` block, add:

```zsh
mr_project admin \
  "/Users/knselo/development/projects/asko-netthandel/admin-api" \
  "/Users/knselo/development/projects/ngf-admin/ngf-admin-web"
```

Note: use the actual paths from the existing `tmux_project admin` call on line 76 of `~/.zshrc`.

- [ ] **Step 3: Reload the shell**

```bash
exec zsh
```

- [ ] **Step 4: End-to-end smoke test**

```zsh
mg                    # should list "admin" with both paths
mg help               # should print command reference
mg st admin           # should show both repos with branch + status
mg st                 # run from inside one of the admin repo dirs — should infer project
mg fetch admin        # should attempt fetch on both repos
```

- [ ] **Step 5: Commit the stow file change**

```bash
git add stow/zsh/.zshrc
git commit -m "feat(mg): wire mr/ source block into .zshrc"
```

---

### Task 10: Clean up test repos

- [ ] **Step 1: Remove the temporary test repos created in Task 2**

```bash
rm -rf /tmp/mg-test
```
