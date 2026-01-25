# macOS dotfiles

macOS dotfiles with a **single-command bootstrap**, **modular shell setup**, and a
**custom Git workflow (`g`)** optimized for daily use.

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
- Homebrew (installed automatically by bootstrap)
- Xcode Command Line Tools (recommended, but optional)

If needed, CLT can be installed manually with:

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

## Bootstrap with Xcode (explicit opt-in)

By default, **Xcode is NOT configured** when running `bootstrap.sh`.

Xcode installation and configuration can take a long time and is therefore
**explicitly opt-in**.

### Run bootstrap *with* Xcode configuration

To run bootstrap **including Xcode installation / configuration**, execute:

```bash
INSTALL_XCODE=true ./bootstrap.sh
```

This will:
- select the correct Xcode (`xcode-select` / `xcodes`)
- accept the Xcode license automatically
- log all detailed output to `bootstrap.log`

> ⚠️ **Important:**  
> Xcode configuration can take several minutes, especially after a fresh
> install or upgrade.  
> The script will clearly indicate in the console when this step is running.

### Run bootstrap *without* Xcode (default)

```bash
./bootstrap.sh
```

This will:
- install Homebrew and packages
- link dotfiles via GNU Stow
- **skip all Xcode-related steps**

---

### Logging

- All detailed output is written to:
  ```
  bootstrap.log
  ```
- The console shows only high-level progress and long-running steps

This keeps bootstrap:
- quiet and predictable during normal runs
- easy to debug when something fails

---

## Migration / Adopt (important)

This repository uses **GNU Stow** to manage dotfiles.

If configuration files already exist in `$HOME`, bootstrap may fail during
stowing. This is **expected on first run**.

Existing configs must be **explicitly adopted** into the repository using
one-time migration scripts.

See:
- `MIGRATION.md` for the migration model
- `migrate/adopt-<package>.sh` for concrete adopt scripts

Bootstrap will **fail loudly** if migration is required.

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

Migration (`stow --adopt`) is **never automated**.

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
Ad-hoc `brew install` for temporary installs.

---

## Application switching (Hammerspoon)

Fast application switching is implemented using **Hammerspoon**, configured in a
**data-driven and deterministic** way.

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
