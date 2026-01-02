-- lua/plugins/oil.lua

return {
  "stevearc/oil.nvim",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },

  cmd = "Oil",

  keys = {
    {
        "<leader>e",
        function()
            require("oil").open(vim.fn.getcwd())
        end,
        desc = "Open explorer (project root)",
    },
  },

  opts = {
    default_file_explorer = true,

    view_options = {
      show_hidden = true,
    },

    skip_confirm_for_simple_edits = true,

    keymaps = {
      ["q"] = "actions.close",
      ["<CR>"] = "actions.select",
      ["-"] = "actions.parent",
    },
  },
}
