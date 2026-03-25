# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

A macOS dotfiles repository using [GNU Stow](https://www.gnu.org/software/stow/) to symlink configs from `stow/` into `$HOME`. A single `./bootstrap.sh` command sets up a new Mac end-to-end.

## Bootstrap

```bash
# Full setup (run from repo root, works from any directory)
./bootstrap.sh

# With optional Xcode installation
INSTALL_XCODE=true ./bootstrap.sh
```

Bootstrap is idempotent — safe to re-run. It logs verbosely to `bootstrap.log` and prints only high-level status to the console.

## Stow Packages

Each subdirectory of `stow/` is a GNU Stow package. Running `stow -t "$HOME" <package>` creates symlinks in `$HOME` mirroring the package's directory structure.

Packages:
- `git/` — Multi-identity Git config (personal/work via conditional includes)
- `nvim/` — Neovim config (lazy.nvim, LSP, DAP, Java, formatting)
- `zsh/` — Shell config and plugins
- `tmux/` — Terminal multiplexer config
- `hammerspoon/` — macOS automation (application switching)
- `karabiner/` — Keyboard remapping

## Neovim Configuration

Entry point: `stow/nvim/.config/nvim/init.lua`

```
lua/
├── config/         # options, keymaps, autocmds
└── plugins/        # one file per concern (ui, editor, lsp, git, formatting, debug)
ftplugin/
└── java.lua        # Java-specific jdtls setup
```

**Leader key**: `,` (comma)

Key plugin groupings:
- `plugins/lsp.lua` — Mason, nvim-lspconfig, nvim-cmp, snippets
- `plugins/editor.lua` — Telescope, Harpoon, Oil, Which-key, Flash
- `plugins/debug.lua` — nvim-dap (Node/JS/TS, Python, Java)
- `plugins/formatting.lua` — Conform (format on save), nvim-lint

See `stow/nvim/.config/nvim/README.md` for the full keybinding reference.

## Git Identity

Three files control Git identity:
- `.gitconfig` — Main config; uses `includeIf` to load personal or work config based on directory
- `.gitconfig-personal`, `.gitconfig-work` — Identity-specific settings
- `.gitconfig-local` (gitignored) — Machine-local overrides; copy from `.gitconfig-local.example`

## Adding Packages

To add a new Homebrew package, add it to `Brewfile` then run `brew bundle`.

To add a new stow package:
1. Create `stow/<package-name>/` with the desired directory structure
2. Add the stow call to `bootstrap.sh` alongside the other stow invocations
