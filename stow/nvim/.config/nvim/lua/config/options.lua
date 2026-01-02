-- lua/config/options.lua
-- Core Neovim options (no plugins)

local opt = vim.opt

-- --------------------------------------------------
-- General
-- --------------------------------------------------
opt.mouse = "a"                 -- Enable mouse
opt.clipboard = "unnamedplus"   -- Sync with system clipboard
opt.swapfile = false
opt.backup = false
opt.undofile = true             -- Persistent undo

-- --------------------------------------------------
-- UI
-- --------------------------------------------------
opt.number = true               -- Line numbers
opt.relativenumber = true       -- Relative line numbers
opt.cursorline = true
opt.signcolumn = "yes"          -- Always show sign column
opt.termguicolors = true
opt.wrap = false
opt.scrolloff = 8
opt.sidescrolloff = 8

-- --------------------------------------------------
-- Indentation
-- --------------------------------------------------
opt.expandtab = true            -- Use spaces instead of tabs
opt.shiftwidth = 2
opt.tabstop = 2
opt.smartindent = true

-- --------------------------------------------------
-- Search
-- --------------------------------------------------
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

-- --------------------------------------------------
-- Splits
-- --------------------------------------------------
opt.splitbelow = true
opt.splitright = true

-- --------------------------------------------------
-- Performance / timing
-- --------------------------------------------------
opt.updatetime = 250
opt.timeoutlen = 400

-- --------------------------------------------------
-- Misc
-- --------------------------------------------------
opt.completeopt = { "menu", "menuone", "noselect" }
opt.confirm = true              -- Confirm to save changes before exiting
