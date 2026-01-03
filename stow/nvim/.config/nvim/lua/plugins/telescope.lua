return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  version = false,

  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },

  -- Ensure Treesitter highlighter API shims exist before Telescope loads
  init = function()
    local function ensure_highlighter_shim()
      local ok_parsers, parsers = pcall(require, "nvim-treesitter.parsers")
      local ok_highlighter, highlighter = pcall(require, "vim.treesitter.highlighter")

      local shim = function(lang, _buf)
        if ok_parsers and parsers.has_parser then
          return parsers.has_parser(lang)
        end
        return false
      end

      if ok_highlighter then
        if type(highlighter.is_enabled) ~= "function" then
          highlighter.is_enabled = shim
        end
        if vim.treesitter and vim.treesitter.highlighter then
          vim.treesitter.highlighter.is_enabled = highlighter.is_enabled
        end
      else
        vim.treesitter = vim.treesitter or {}
        vim.treesitter.highlighter = vim.treesitter.highlighter or {}
        if type(vim.treesitter.highlighter.is_enabled) ~= "function" then
          vim.treesitter.highlighter.is_enabled = shim
        end
      end
    end

    ensure_highlighter_shim()
  end,

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

  config = function(_, opts)
    local ok_parsers, parsers = pcall(require, "nvim-treesitter.parsers")
    if ok_parsers then
      if not parsers.ft_to_lang then
        parsers.ft_to_lang = function(ft)
          return vim.treesitter.language.get_lang(ft)
        end
      end
    end

    local ok_highlighter, highlighter = pcall(require, "vim.treesitter.highlighter")
    if ok_highlighter then
      if type(highlighter.is_enabled) ~= "function" then
        local shim = function(lang, _buf)
          return parsers and parsers.has_parser and parsers.has_parser(lang)
        end
        highlighter.is_enabled = shim
        if vim.treesitter and vim.treesitter.highlighter then
          vim.treesitter.highlighter.is_enabled = shim
        end
      end
    else
      -- Fallback to avoid Telescope preview errors
      vim.treesitter = vim.treesitter or {}
      vim.treesitter.highlighter = vim.treesitter.highlighter or {}
      vim.treesitter.highlighter.is_enabled = vim.treesitter.highlighter.is_enabled
        or function(_lang, _buf)
          return false
        end
    end

    require("telescope").setup(opts)

    -- Telescope's preview ts_highlighter expects treesitter APIs that may not exist on older versions.
    -- Override with a safe implementation that no-ops if highlighting cannot be attached.
    local utils = require("telescope.previewers.utils")
    utils.ts_highlighter = function(bufnr, _)
      if type(bufnr) ~= "number" or not vim.api.nvim_buf_is_valid(bufnr) then
        return
      end

      local ft = vim.api.nvim_get_option_value("filetype", { buf = bufnr })
      local lang = vim.treesitter.language.get_lang(ft)
      if not lang then
        return
      end

      local ok_highlighter, highlighter = pcall(require, "vim.treesitter.highlighter")
      if not ok_highlighter then
        return
      end

      local ok_parser = pcall(vim.treesitter.get_parser, bufnr, lang)
      if not ok_parser then
        return
      end

      if highlighter.active and highlighter.active[bufnr] then
        return
      end

      if highlighter.attach then
        pcall(highlighter.attach, highlighter, bufnr, lang)
      end
    end
  end,
}
