return {
  -- ── Conform: code formatting ──────────────────────────────────────────────
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    cmd = "ConformInfo",
    keys = {
      {
        "<leader>cf",
        function() require("conform").format({ async = true, lsp_fallback = true }) end,
        desc = "Format file",
      },
    },
    opts = {
      formatters_by_ft = {
        lua              = { "stylua" },
        python           = { "ruff_format" },
        javascript       = { "prettier" },
        typescript       = { "prettier" },
        javascriptreact  = { "prettier" },
        typescriptreact  = { "prettier" },
        json             = { "prettier" },
        jsonc            = { "prettier" },
        yaml             = { "prettier" },
        html             = { "prettier" },
        css              = { "prettier" },
        markdown         = { "prettier" },
        java             = { "google-java-format" },
        sh               = { "shfmt" },
      },
      format_on_save = {
        timeout_ms   = 3000,
        lsp_fallback = true,
      },
    },
  },

  -- ── nvim-lint: async linting ──────────────────────────────────────────────
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufNewFile", "BufWritePost" },
    config = function()
      local lint = require("lint")
      lint.linters_by_ft = {
        javascript      = { "eslint_d" },
        typescript      = { "eslint_d" },
        javascriptreact = { "eslint_d" },
        typescriptreact = { "eslint_d" },
        python          = { "ruff" },
        sh              = { "shellcheck" },
      }

      local group = vim.api.nvim_create_augroup("NvimLint", { clear = true })
      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
        group    = group,
        callback = function()
          lint.try_lint()
        end,
      })
    end,
  },

  -- ── mason-tool-installer: formatters & linters ───────────────────────────
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = {
        -- Formatters
        "stylua",
        "prettier",
        "google-java-format",
        "shfmt",
        -- Linters / formatters (ruff covers both for Python)
        "ruff",
        "eslint_d",
        "shellcheck",
      },
      auto_update   = false,
      run_on_start  = true,
      start_delay   = 3000, -- wait 3s after startup before installing
    },
  },
}
