# Neovim Configuration

Leader key: `,`

Press `,` and **wait** — which-key will show all available mappings.

---

## Navigation

### Files & Search (Telescope)

| Key | Action |
|-----|--------|
| `,ff` | Find files in project |
| `,fg` | Live grep (search text) |
| `,fb` | Open buffers |
| `,fr` | Recently opened files |
| `,fs` | Search word under cursor |
| `,/`  | Search inside current buffer |
| `,.`  | Resume last search |
| `,fd` | Show all diagnostics |
| `,fh` | Search help tags |

### Harpoon 2 — fast file marks

| Key | Action |
|-----|--------|
| `,ha` | Add current file to harpoon list |
| `,hh` | Open harpoon menu |
| `,1` – `,5` | Jump to harpoon file 1–5 |
| `,hn` | Next harpoon file |
| `,hp` | Prev harpoon file |

**Workflow:** open the files you work with most → `,ha` on each → jump between them with `,1`, `,2`, etc.

### File Tree (Neo-tree)

| Key | Action |
|-----|--------|
| `,e` | Toggle file tree sidebar |
| `,E` | Reveal current file in tree |

### File Manager (Oil)

| Key | Action |
|-----|--------|
| `-`  | Open parent directory as a buffer |
| `<CR>` | Open file / enter directory |
| `-`  | Go up one level |
| `g.` | Toggle hidden files |
| `q`  | Close oil |

Oil lets you rename, move, and delete files by editing the buffer like normal text.

### Flash — jump anywhere on screen

| Key | Action |
|-----|--------|
| `s` | Jump to any location (type 2 chars) |
| `S` | Jump using treesitter node |

---

## Windows & Buffers

| Key | Action |
|-----|--------|
| `Ctrl+h/j/k/l` | Move between windows |
| `Ctrl+arrows`  | Resize window |
| `,-`  | Split horizontal |
| `,\|` | Split vertical |
| `,wd` | Close window |
| `Shift+h` | Previous buffer |
| `Shift+l` | Next buffer |
| `,bd` | Delete buffer |
| `,bo` | Delete all other buffers |
| `Ctrl+s` | Save file |
| `,qq` | Quit all |

---

## LSP

| Key | Action |
|-----|--------|
| `gd`  | Go to definition |
| `gD`  | Go to declaration |
| `gr`  | Find all references |
| `gi`  | Go to implementation |
| `gt`  | Go to type definition |
| `K`   | Hover documentation |
| `Ctrl+k` | Signature help |
| `,lr` | Rename symbol |
| `,la` | Code actions |
| `,ls` | Document symbols |
| `,lS` | Workspace symbols |
| `,lf` | Format file |
| `,lh` | Toggle inlay hints |
| `,li` | LSP info |
| `,lm` | Open Mason (install/manage tools) |
| `[d` / `]d` | Previous / next diagnostic |
| `,cd` | Show diagnostic float |

### Diagnostics list (Trouble)

| Key | Action |
|-----|--------|
| `,xx` | All project diagnostics |
| `,xX` | Current buffer diagnostics |
| `,xq` | Quickfix list |
| `,xl` | Location list |

---

## Git

| Key | Action |
|-----|--------|
| `,gg` | Open LazyGit TUI |
| `]h` / `[h` | Next / prev hunk |
| `,gs` | Stage hunk |
| `,gr` | Reset hunk |
| `,gS` | Stage entire buffer |
| `,gp` | Preview hunk |
| `,gb` | Blame current line |
| `,gd` | Diff this |

---

## Debugging (DAP)

| Key | Action |
|-----|--------|
| `,db` | Toggle breakpoint |
| `,dB` | Conditional breakpoint |
| `,dc` | Continue |
| `,di` | Step into |
| `,do` | Step over |
| `,dO` | Step out |
| `,dt` | Terminate session |
| `,du` | Toggle DAP UI |
| `,de` | Evaluate expression (normal & visual) |
| `,dr` | Open REPL |
| `,dl` | Re-run last session |

Supported runtimes: **Node/JS/TS**, **Python**, **Java**

---

## Java (additional keymaps)

| Key | Action |
|-----|--------|
| `,jo` | Organize imports |
| `,jv` | Extract variable |
| `,jc` | Extract constant |
| `,jt` | Run nearest test method |
| `,jT` | Run test class |
| `,ju` | Update jdtls config |

Lombok is loaded automatically. jdtls starts when you open a `.java` file.

---

## Code editing

| Key | Action |
|-----|--------|
| `gc` + motion | Toggle comment |
| `gcc` | Toggle line comment |
| `ys` + motion + char | Surround with char (e.g. `ysiw"`) |
| `cs` + old + new | Change surrounding char |
| `ds` + char | Delete surrounding char |
| `Alt+j/k` | Move line / selection up or down |
| `>` / `<` in visual | Indent / unindent (stays in visual) |
| `p` in visual | Paste without overwriting clipboard |

### Treesitter text objects

| Key | Action |
|-----|--------|
| `af` / `if` | Outer / inner function |
| `ac` / `ic` | Outer / inner class |
| `aa` / `ia` | Outer / inner parameter |
| `al` / `il` | Outer / inner loop |
| `]f` / `[f` | Jump to next / prev function |
| `]c` / `[c` | Jump to next / prev class |

---

## Formatting & Linting

Formatting runs **automatically on save**. To trigger manually:

| Key | Action |
|-----|--------|
| `,cf` | Format current file |
| `:ConformInfo` | Show active formatters |

Linting runs automatically on save and when leaving insert mode.

---

## TODOs

| Key | Action |
|-----|--------|
| `,st` | Search all TODO/FIXME/NOTE comments |
| `]t` / `[t` | Jump to next / prev TODO |

---

## Plugin management

| Key / Command | Action |
|---------------|--------|
| `:Lazy` | Open plugin manager UI |
| `:Lazy sync` | Update all plugins |
| `:Lazy health` | Run health checks |
| `:Mason` or `,lm` | Manage LSPs, formatters, linters, DAP adapters |

---

## File locations

```
~/.config/nvim/
├── init.lua              # entry point
├── ftplugin/java.lua     # Java LSP (jdtls)
└── lua/
    ├── config/
    │   ├── options.lua   # editor settings
    │   ├── keymaps.lua   # base keymaps
    │   └── autocmds.lua  # autocommands
    └── plugins/
        ├── init.lua      # lazy.nvim bootstrap
        ├── ui.lua        # catppuccin, lualine, neo-tree, noice
        ├── editor.lua    # telescope, harpoon, oil, which-key, flash
        ├── git.lua       # gitsigns, lazygit
        ├── lsp.lua       # mason, lspconfig, nvim-cmp, snippets
        ├── formatting.lua # conform, nvim-lint
        ├── treesitter.lua
        └── debug.lua     # nvim-dap
```
