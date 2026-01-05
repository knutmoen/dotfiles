# Neovim Cheat Sheet – Daily use (v1)

Compact overview of what’s wired up. Open this file whenever you need a quick reminder.

> **Leader = Space**

---

## 🧭 Project navigation

### 📂 Browse files (Oil.nvim)
**When:** Explore structure, move/rename files.

- `<leader>e` → Open explorer (buffer directory or project root)
- `j / k` → Down / up
- `Enter` → Open file / enter dir
- `-` → Parent directory
- `q` → Close Oil

---

### 🔍 Find fast (Telescope)
**When:** You know what you’re looking for.

- `<leader>ff` → Find files
- `<leader>fg` → Live grep
- `<leader>fb` → Buffers
- `<leader>fh` → Neovim help

In Telescope:
- `Ctrl-j / Ctrl-k` → Move
- `Enter` → Open
- `Esc` → Cancel

---

### 🎯 Rapid file hopping (Harpoon)
**When:** Juggling 3–7 files.

- `<leader>a` → Add current file
- `<leader>1..4` → Jump to file 1–4
- `<leader>h` → Harpoon menu

In the menu:
- `Enter` → Open file
- `d` → Remove file
- `q` → Close menu

---

## 🐚 Shell helpers (zsh)

- `kallrest <METHOD> <URL> [-d BODY] [-o RESP_FILE]`  
  Refreshes Okta token via `rest-login-pkce-cache.sh`, pretty-prints JSON (jq), logs to `~/.cache/kallrest.log`, can write response to file.
- `kallrestlog` → Open the log in `$EDITOR` (default nvim).
- `restkall` → Legacy script directly.
- Navigation: `cproj` (work projects), `cpriv` (personal projects), `cgit` (git repo under `~/development`).

> Copy `scripts/examples/rest-pkce.env.example` to `~/.rest-pkce.env` and fill in Okta values before using `kallrest`.

---

## 🧠 LSP – Understand and navigate code

### 🔎 Movement (constant use)

- `gd` → Go to definition
- `gr` → Find references
- `gi` → Go to implementation
- `gD` → Go to declaration

---

### 🧠 Docs & help

- `K` → Hover docs
- `Ctrl-k` → Signature help

---

### ✏️ Refactoring

- `<leader>rn` → Rename symbol
- `<leader>ca` → Code actions

---

### 🚨 Diagnostics

- `[d` → Previous diagnostic
- `]d` → Next diagnostic
- `<leader>ld` → Line diagnostics
- `<leader>lq` → Diagnostics list

---

## ✍️ Completion (nvim-cmp)

In insert mode:

- Start typing → suggestions appear
- `Ctrl-n / Ctrl-p` → Move suggestions
- `Enter` → Accept
- `Ctrl-Space` → Force completion
- `Tab / Shift-Tab` → Snippets / jump

---

## 🗺️ Keymap overview (which-key)

- `Space` → Show all leader groups
- `Space + key` → Show actions
- `Esc` → Cancel

---

## 🐞 Debugging (nvim-dap)

- `<leader>dc` → Continue/start
- `<leader>db` → Toggle breakpoint
- `<leader>do/di/du` → Step over/into/out
- `<leader>dr` → REPL
- `<leader>dl` → Run last
- `<leader>dU` → Toggle DAP UI

---

## 🔌 REST (Neovim)

- In `.http` files: `<leader>rr` (run) / `<leader>rp` (run last)
- Results open in a split; Treesitter gives highlighting.

---

## 🧠 Mental model (important)

- **Oil** → View/change structure
- **Telescope** → Find things fast
- **Harpoon** → Jump between important files
- **LSP** → Understand code
- **which-key** → Never lost

---
