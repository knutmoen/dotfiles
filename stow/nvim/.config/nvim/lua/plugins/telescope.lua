return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  version = false,

  dependencies = {
    "nvim-lua/plenary.nvim",
  },

  cmd = "Telescope",

  keys = {
    { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
    { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
    { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
    { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help" },
  },

  opts = {
    defaults = {
      prompt_prefix = "❯ ",
      selection_caret = "➜ ",
      path_display = { "smart" },
      sorting_strategy = "ascending",
      layout_config = {
        horizontal = {
          prompt_position = "top",
        },
      },
      mappings = {
        i = {
          ["<C-j>"] = "move_selection_next",
          ["<C-k>"] = "move_selection_previous",
        },
      },
    },

    pickers = {
      buffers = {
        sort_lastused = true,
        previewer = false,
        mappings = {
          i = {
            ["<C-d>"] = "delete_buffer",
          },
        },
      },
    },
  },
}
