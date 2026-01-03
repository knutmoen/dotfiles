local theme_dir = vim.fn.stdpath("config") .. "/lua/colors"

return {
  name = "knut-colors",
  dir = theme_dir,
  priority = 1000,
  lazy = false,
  config = function()
    require("colors.knut").load()
  end,
}
