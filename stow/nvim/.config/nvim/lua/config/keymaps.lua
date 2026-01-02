-- lua/config/keymaps.lua
-- Core key mappings (no plugins)

local keymap = vim.keymap.set

-- --------------------------------------------------
-- Leader key
-- --------------------------------------------------
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- --------------------------------------------------
-- General
-- --------------------------------------------------

-- Clear search highlight
keymap("n", "<leader>h", ":nohlsearch<CR>", { desc = "Clear search highlight" })

-- Better escape
keymap("i", "jk", "<Esc>", { desc = "Exit insert mode" })

-- --------------------------------------------------
-- Window navigation
-- --------------------------------------------------

keymap("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
keymap("n", "<C-j>", "<C-w>j", { desc = "Move to lower window" })
keymap("n", "<C-k>", "<C-w>k", { desc = "Move to upper window" })
keymap("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- --------------------------------------------------
-- Window management
-- --------------------------------------------------

keymap("n", "<leader>sv", "<C-w>v", { desc = "Split vertically" })
keymap("n", "<leader>sh", "<C-w>s", { desc = "Split horizontally" })
keymap("n", "<leader>se", "<C-w>=", { desc = "Equalize splits" })
keymap("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close split" })

-- --------------------------------------------------
-- Buffers
-- --------------------------------------------------

keymap("n", "<leader>bn", "<cmd>bnext<CR>", { desc = "Next buffer" })
keymap("n", "<leader>bp", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
keymap("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Delete buffer" })

-- --------------------------------------------------
-- Visual mode improvements
-- --------------------------------------------------

-- Stay in indent mode
keymap("v", "<", "<gv")
keymap("v", ">", ">gv")

-- Move selected lines up/down
keymap("v", "J", ":m '>+1<CR>gv=gv")
keymap("v", "K", ":m '<-2<CR>gv=gv")
