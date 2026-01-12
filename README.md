# macOS dotfiles

Opinionated macOS dotfiles with a **single-command bootstrap**, **modular shell setup**, and a **custom Git workflow (`g`)** optimized for daily use.

This repository is designed to be:
- deterministic
- reproducible
- easy to reason about
- safe to share (no secrets committed)

---

## Goals

- **One-command bootstrap**  
  New machine → `./bootstrap.sh`

- **Repo can live anywhere**  
  No assumption that dotfiles live in `$HOME`

- **No secrets committed**  
  Local-only Git identity files are ignored

- **Deterministic & idempotent**  
  Safe to run bootstrap multiple times

---

## Requirements

- macOS
- Xcode Command Line Tools  
  ```bash
  xcode-select --install
  ```

---

## Installation

```bash
git clone git@github.com:knselo/dotfiles.git
cd dotfiles
./bootstrap.sh
```

---

## Repository Structure

```
dotfiles/
├── Brewfile
├── bootstrap.sh
├── install/
│   ├── homebrew.sh
│   ├── zsh.sh
│   ├── oh-my-zsh.sh
│   ├── powerlevel10k.sh
│   ├── fonts.sh
│   └── stow.sh
├── stow/
│   ├── zsh/
│   └── hammerspoon/
│       └── .hammerspoon/
│           ├── init.lua
│           └── apps.json
```

---

## GNU Stow model

- The repository **does NOT live in `$HOME`**
- All dotfiles are symlinked using **GNU Stow**
- All stow operations use:

```bash
stow --target="$HOME" <package>
```

---

## Shell setup

- Shell: **zsh (Homebrew)**
- Framework: **Oh My Zsh**
- Prompt: **Powerlevel10k**
- Plugins installed via Homebrew:
  - `zsh-autosuggestions`
  - `zsh-syntax-highlighting`

---

## Runtime management (Java, Node, …)

Language runtimes are managed using a **declarative + explicit** model.

### Core principles

- **Brewfile is the source of truth for long-lived runtimes**
- **Homebrew installs and uninstalls runtimes**
- **Shell modules select the active runtime**
- **No version managers** (`nvm`, `jenv`, `asdf`, etc.)
- **No hidden state**
- **All switching is shell-local**

If a runtime version becomes part of daily use, it **belongs in `Brewfile`**.
Ad-hoc `brew install` is acceptable for temporary testing.

---

## Application switching (Hammerspoon)

Fast application switching is implemented using **Hammerspoon**, configured in a
**data-driven and deterministic** way.

### Why Hammerspoon

- Explicit, scriptable behavior
- No hidden state or heuristics
- Works purely from hotkeys
- Easy to reason about and refactor
- Configuration lives in this repository

This setup is intentionally **not** a window manager.
It only handles:
- launching applications
- focusing existing application windows

---

### Configuration layout

Hammerspoon is managed via GNU Stow.

```
stow/hammerspoon/
└── .hammerspoon/
    ├── init.lua
    └── apps.json
```

After stowing:

```
~/.hammerspoon/
├── init.lua      -> symlink
└── apps.json     -> symlink
```

---

### `apps.json` (declarative app map)

Applications and hotkeys are defined declaratively in `apps.json`.

Each entry specifies:
- application name
- process name
- hotkey

Example (simplified):

```json
{
  "V": {
    "app": "Visual Studio Code",
    "process": "Code",
    "hotkey": ["alt", "cmd", "V"]
  }
}
```

The JSON file contains **no logic** and can be edited safely without touching Lua.

---

### `init.lua` behavior

The Hammerspoon configuration implements a single, explicit rule:

> **If the application is running → focus it**  
> **If not → launch it and focus when ready**

There is:
- no window placement logic
- no space management
- no auto-reload logic
- no background watchers

Reloading the configuration is done manually via the Hammerspoon menu bar,
keeping behavior explicit and predictable.

---

## Git identity model

Git identity is **path-based**, not global.

```
~/development/projects/   → work identity
~/development/privat/     → personal identity
```

Uses Git-native `includeIf gitdir:` with no global identity.

---

## The `g` command

Custom Git workflow wrapper.

### Core commands

| Command | Purpose |
|------|--------|
| `g sync` | Rebase current branch onto default |
| `g cleanup` | Remove merged / gone local branches |
| `g wip` | Create WIP commit |
| `g wip --squash` | Amend last commit |
| `g fixup` | Fixup commit + autosquash |
| `g sq` | Squash last 2 commits |
| `g sq N` | Squash last N commits |
| `g review` | Review branch vs default |
| `g bfr` | move commits from feature to bugfix branch |

### When to use them (quick guide)

- `g sync`: Start of day eller før PR for å rebase branchen på default og unngå konflikter.
- `g cleanup`: Rydd bort lokalt mergete eller “gone” branches; kjør jevnlig for å holde repoet ryddig.
- `g fixup`: Rett en tidligere commit (angi hash eller velg via fzf); autosquasher inn under rebase.
- `g wip` / `g wip --squash`: Midlertidig lagring av arbeid; `--squash` amender siste commit.
- `g sq [N]`: Slå sammen de siste commitene før PR; `--interactive` hvis du vil endre rekkefølge/meldinger.
- `g review [all|log|stat|diff]`: Se hva branchen din endrer vs default før code review.
- `g bfr`: Lag bugfix-branch fra `release/<prosjekt>-<versjon>` og cherry-pick ev. feature-commits; bruk ved hotfix av release.
- `g tag <versjon> <melding>`: Opprett/push `v<versjon>` når du shipper en release eller milepæl.
- `g doctor`: Kjør når en `g`-kommando oppfører seg rart; validerer registry og implementationer.

### Workflow: bugfix branch fra feature (`g bfr` / `git bfr`)

- Purpose: create `bugfix/<feature>` off `release/<project>-<version>` and optionally cherry-pick recent feature commits.
- Preconditions: start on a `feature/*` branch; repo must know `origin`; release branch must exist locally or on `origin`.
- Default flow (`g bfr`): detects project from `origin`, picks latest `release/<project>-YY.MM`, checks out release, creates `bugfix/<feature>`.
- Cherry-pick: add `--cherry-pick <N>` to bring the last N commits from the feature branch; add `--include-merges` to keep merge commits (default skips them).
- Dry-run: `--check` shows which branches/commits would be used without making changes.
- Version override: pass `YY.MM` as the last arg to target a specific release (e.g., `g bfr 24.09`).
- Examples: `g bfr --check`, `g bfr --cherry-pick 2`, `g bfr --cherry-pick 3 --include-merges 24.09`.
- Conflicts during cherry-pick: resolve, then run `git cherry-pick --continue`.

---

## Adding a new `g` command (how-to)

Single source of truth lives in `stow/zsh/.zsh/git/commands.zsh`. To add a new `g <cmd>`:

1) Implement the function  
   - Simple git wrapper: add to `stow/zsh/.zsh/git/simple.zsh` (e.g., `g_mycmd() { git ... }`).  
   - Advanced logic: create or reuse a file under `stow/zsh/.zsh/git/` and ensure it is sourced (the dispatcher already sources `simple.zsh`; add more `source` lines if needed).

2) Register it in `commands.zsh`  
   - `G_COMMAND_DISPATCH`: map `cmd` → function (`g_mycmd`).  
   - `G_COMMANDS`: add `cmd` for ordering/help/completion.  
   - `G_COMMAND_HELP`: add a short description (shown in `g help` and completion).

3) Use it  
   - `g help` will list it, and completion will pick it up automatically.

This keeps `g` commands, help, and completion in sync via one registry.

---

## Completion

- Custom completion files in `~/.zsh/completion/`
- Fish-style autosuggestions
- TAB accepts autosuggestion
- TAB TAB triggers explicit completion

---

## API testing (Okta PKCE helpers)

- Local config (not committed): copy `scripts/examples/rest-pkce.env.example` → `~/.rest-pkce.env` (or `~/.config/rest-pkce.env`) and fill in your values (`OKTA_ISSUER`, `CLIENT_ID`, `USERNAME`, `PASSWORD`, `SCOPE`, `REDIRECT_URI`; optional `CACHE_FILE`, `SKEW_SECONDS`).
- Fetch a token once: `./scripts/rest-login-pkce.sh`  
  Reuse cached token: `./scripts/rest-login-pkce-cache.sh` (stores in `~/.cache/rest-pkce-token.json` by default).
- Fire API calls with caching + logging: `kallrest <METHOD> <URL> [-d BODY] [-o RESP_FILE]` (alias from `stow/zsh/.zsh/aliases/dev.zsh`).  
  - Automatically refreshes the token via `rest-login-pkce-cache.sh`.  
  - Pretty-prints JSON if `jq` is available.  
  - Logs headers/timing to `~/.cache/kallrest.log` (override with `KALLREST_LOG`). Optional `-o` writes the response body to a file.
- Dependencies installed via `brew bundle`: `jq` and `openssl@3` (used by the PKCE scripts).

---

## Troubleshooting

```bash
git config --show-origin --list
stow -nv zsh
stow -nv hammerspoon
which _g
exec zsh
```

---
