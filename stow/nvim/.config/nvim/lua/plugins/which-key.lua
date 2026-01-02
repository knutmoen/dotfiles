return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    preset = "modern",

    icons = {
      breadcrumb = "»",
      separator = "➜",
      group = "+",
    },

    win = {
      border = "rounded",
      padding = { 1, 2 },
    },

    layout = {
      spacing = 4,
      align = "left",
    },

    show_help = true,
    show_keys = true,
  },
}
