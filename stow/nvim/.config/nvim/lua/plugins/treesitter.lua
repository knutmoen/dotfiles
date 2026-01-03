return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  event = { "BufReadPost", "BufNewFile" },
  cmd = { "TSInstall", "TSUpdate", "TSInstallSync" },
  opts = {
    ensure_installed = {
      "lua",
      "vim",
      "vimdoc",
      "bash",
      "json",
      "yaml",
      "markdown",
      "markdown_inline",
      "java"
    },
    highlight = {
      enable = true,
    },
    indent = {
      enable = true,
    },
  },

  config = function(_, opts)
    local ok_parsers, parsers = pcall(require, "nvim-treesitter.parsers")
    local ok_configs, configs = pcall(require, "nvim-treesitter.configs")
    if not ok_parsers or not ok_configs then
      return
    end

    if not parsers.ft_to_lang then
      parsers.ft_to_lang = function(ft)
        return vim.treesitter.language.get_lang(ft)
      end
    end

    configs.setup(opts)
  end,
}
