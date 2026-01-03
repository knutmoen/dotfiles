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
            local bufdir = vim.fn.expand("%:p:h")
            local target = (bufdir ~= "" and vim.loop.fs_stat(bufdir)) and bufdir or vim.fn.getcwd()
            require("oil").open(target)
        end,
        desc = "Open explorer (buffer dir)",
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
