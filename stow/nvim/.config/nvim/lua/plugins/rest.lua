return {
  "rest-nvim/rest.nvim",
  ft = { "http" },
  keys = {
    { "<leader>rr", "<cmd>Rest run<cr>", desc = "Rest: run request" },
    { "<leader>rp", "<cmd>Rest run last<cr>", desc = "Rest: run last" },
  },

  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      table.insert(opts.ensure_installed, "http")
    end,
  },

  opts = {
    result_split_horizontal = false,
    result_split_in_place = true,
    skip_ssl_verification = false,
    highlight = { enabled = true },
  },

  config = function(_, opts)
    require("rest-nvim").setup(opts)
  end,
}
