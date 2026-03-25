return {
  -- ── Git signs in the gutter ───────────────────────────────────────────────
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      signs = {
        add          = { text = "▎" },
        change       = { text = "▎" },
        delete       = { text = "" },
        topdelete    = { text = "" },
        changedelete = { text = "▎" },
        untracked    = { text = "▎" },
      },
      on_attach = function(buffer)
        local gs = package.loaded.gitsigns
        local map = function(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
        end

        -- Navigation
        map("n", "]h", gs.next_hunk,                                  "Next hunk")
        map("n", "[h", gs.prev_hunk,                                  "Prev hunk")

        -- Hunk actions
        map({ "n", "v" }, "<leader>gs", ":Gitsigns stage_hunk<CR>",  "Stage hunk")
        map({ "n", "v" }, "<leader>gr", ":Gitsigns reset_hunk<CR>",  "Reset hunk")
        map("n", "<leader>gS", gs.stage_buffer,                       "Stage buffer")
        map("n", "<leader>gu", gs.undo_stage_hunk,                    "Undo stage hunk")
        map("n", "<leader>gR", gs.reset_buffer,                       "Reset buffer")
        map("n", "<leader>gp", gs.preview_hunk,                       "Preview hunk")
        map("n", "<leader>gb", function() gs.blame_line({ full = true }) end, "Blame line")
        map("n", "<leader>gd", gs.diffthis,                           "Diff this")
        map("n", "<leader>gD", function() gs.diffthis("~") end,       "Diff this ~")
        map("n", "<leader>gtb", gs.toggle_current_line_blame,         "Toggle blame")
        map("n", "<leader>gtd", gs.toggle_deleted,                    "Toggle deleted")
      end,
    },
  },

  -- ── LazyGit TUI ───────────────────────────────────────────────────────────
  {
    "kdheepak/lazygit.nvim",
    cmd = {
      "LazyGit", "LazyGitConfig", "LazyGitCurrentFile",
      "LazyGitFilter", "LazyGitFilterCurrentFile",
    },
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
    },
  },
}
