# Multi-Repo `mg` Command — Design Spec

**Date:** 2026-03-21
**Status:** Approved

---

## Overview

A `mg` ("multi-git") command for managing groups of related repositories as a virtual monorepo. Designed to integrate naturally with the existing `g` command system and `tmux_project` project model.

The core principle: operations are **repo-state-aware** — they act only where meaningful, skip where not, and never blindly run across all repos.

---

## Architecture & File Structure

Two new files added to the dotfiles stow package:

```
stow/zsh/.zsh/
└── mr/
    ├── projects.zsh     # mr_project registry + associative arrays
    └── mg.zsh           # mg command implementation
```

A new source block is added to `.zshrc`, **after** the `git/` sourcing block and **before** any `mr_project` registration calls:

```zsh
for file in "$ZSH_CONFIG_DIR/mr/"*.zsh; do
  [[ -r "$file" ]] && source "$file"
done
```

---

## Group Definition API

`projects.zsh` exposes a registration function:

```zsh
mr_project <name> <repo-path> [<repo-path> ...]
```

Groups are stored in an associative array mapping project name to a pipe-separated list of paths.

**`mr_project` and `tmux_project` are independent registrations with different schemas.** `tmux_project` uses fixed positional arguments (`backend`, `frontend`, `aicli`) for tmux pane layout. `mr_project` takes a variadic list of repo paths for git operations. Both use the same project name but must be called separately. The user registers both in `.zshrc`:

```zsh
# ~/.zshrc
tmux_project admin  "/path/to/admin-api"  "/path/to/ngf-admin-web"
mr_project   admin  "/path/to/admin-api"  "/path/to/ngf-admin-web"
```

---

## Command Set

The main entry point is `mg`. All commands accept an optional project name as the first argument. If omitted, `mg` infers the project from `$PWD` by checking which registered group contains the current directory. If multiple groups match, the first match (alphabetical by project name) wins. If no match is found, `mg` lists all registered projects and exits.

| Command | Behavior |
|---|---|
| `mg` | List all registered projects with their repo paths |
| `mg help` | Show command reference |
| `mg st [project]` | Show each repo's current branch and working tree status |
| `mg branch [project] <name>` | Interactively create a branch per repo (prompts y/n per repo, or `--all` to skip prompts) |
| `mg co [project] <branch>` | Checkout branch on each repo — skip repos that don't have it |
| `mg fetch [project]` | Fetch from origin on all repos |
| `mg pull [project]` | Smart pull: stash dirty repos, pull, pop stash |
| `mg push [project]` | Smart push: only push repos with unpushed commits |
| `mg sync [project]` | Per-repo: pull if on default branch, rebase onto default if not |

### Example output

`mg st admin`:
```
● admin
  admin-api        main          ✓ clean
  ngf-admin-web    feature/x     ↑1 commit, 2 modified
```

`mg branch admin feature/new-thing`:
```
● admin — create branch 'feature/new-thing'?
  admin-api     [main]        create? [y/n] y  ✓
  ngf-admin-web [feature/old] create? [y/n] n  skipped
```

---

## State-Aware Logic

### Smart pull (`mg pull`)
1. For each repo: check if working tree is dirty
2. If dirty → `git stash push`, pull with `--rebase`, then `git stash pop`
3. If stash pop causes a conflict → mark that repo as "needs attention", leave it in the partially-applied state for the user to resolve manually, and **continue** with the remaining repos
4. If clean → `git pull --rebase` directly
5. After all repos have run, print a summary of successes and any repos needing attention

### Smart push (`mg push`)
1. For each repo: check for unpushed commits via `git log @{u}..HEAD`
2. If commits exist and upstream is set → `git push`
3. If commits exist but **no upstream is set** → `git push -u origin HEAD` to push and set the upstream in one step
4. If nothing to push → skip, show "nothing to push" in summary

### Smart checkout (`mg co`)
1. For each repo: check if the branch exists locally or on remote
2. If exists and working tree is clean → checkout
3. If exists and working tree is dirty → auto-stash, checkout, pop stash (same pattern as `mg pull`); if stash pop conflicts, mark as "needs attention" and continue
4. If doesn't exist → skip with a note (does not auto-create; use `mg branch` for that)

### Branch create (`mg branch`)
1. For each repo: show current branch and prompt `create? [y/n]` (or skip prompt if `--all` is passed)
2. If branch already exists on that repo → show `[already exists] switch? [y/n]` and checkout instead of creating
3. If user answers `n` → skip that repo
4. Branch is created **locally only**. Push to origin via `mg push` (which will run `git push -u origin HEAD` since no upstream is set yet). `--all` applies only to `mg branch` since `mg co` has no interactive prompts.

### Sync (`mg sync`)
Mirrors the logic of `g sync` per repo:
1. For each repo: check if working tree is dirty
2. If dirty → auto-stash before proceeding; pop stash after; if stash pop conflicts → mark "needs attention" and continue (same pattern as `mg pull`)
3. Fetch from origin
4. Determine the default branch (`main` or `master`)
5. If currently on the default branch → `git pull --rebase`
6. If on any other branch → `git rebase origin/<default>`
7. Errors are per-repo; continue across all repos and report needs-attention in summary

### Error handling
Each repo operation runs independently. One repo failing does not abort the others. All repos run, then a summary shows what succeeded and what needs attention.

---

## Integration Points

- **Project names**: same names used by `tmux_project` — `tp admin` and `mg st admin` refer to the same group (separate registrations, same name convention)
- **`g` command**: `mg` is a sibling command, not a subcommand of `g`. Both live in the zsh config directory.
- **No new Homebrew dependencies**: pure zsh, no myrepos/Perl required
