return {
  -- ── Telescope: fuzzy finder ───────────────────────────────────────────────
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    version = false,
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        enabled = vim.fn.executable("make") == 1,
      },
    },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>",                desc = "Find files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>",                 desc = "Find in files (grep)" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>",                   desc = "Find buffers" },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>",                  desc = "Recent files" },
      { "<leader>fs", "<cmd>Telescope grep_string<cr>",               desc = "Find word under cursor" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>",                 desc = "Help" },
      { "<leader>fk", "<cmd>Telescope keymaps<cr>",                   desc = "Keymaps" },
      { "<leader>fd", "<cmd>Telescope diagnostics<cr>",               desc = "Diagnostics" },
      { "<leader>fc", "<cmd>Telescope commands<cr>",                  desc = "Commands" },
      { "<leader>/",  "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Search in buffer" },
      { "<leader>.",  "<cmd>Telescope resume<cr>",                    desc = "Resume last search" },
    },
    config = function()
      local telescope = require("telescope")
      local actions = require("telescope.actions")

      telescope.setup({
        defaults = {
          prompt_prefix = " ",
          selection_caret = " ",
          path_display = { "truncate" },
          sorting_strategy = "ascending",
          layout_config = {
            horizontal = { prompt_position = "top", preview_width = 0.55 },
            width = 0.87,
            height = 0.80,
          },
          mappings = {
            i = {
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
              ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
              ["<esc>"] = actions.close,
            },
          },
        },
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
          },
        },
      })
      pcall(telescope.load_extension, "fzf")
    end,
  },

  -- ── Harpoon 2: fast file marks ────────────────────────────────────────────
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      {
        "<leader>ha",
        function() require("harpoon"):list():add() end,
        desc = "Harpoon add file",
      },
      {
        "<leader>hh",
        function()
          local harpoon = require("harpoon")
          harpoon.ui:toggle_quick_menu(harpoon:list())
        end,
        desc = "Harpoon menu",
      },
      { "<leader>hn", function() require("harpoon"):list():next() end, desc = "Harpoon next" },
      { "<leader>hp", function() require("harpoon"):list():prev() end, desc = "Harpoon prev" },
      -- Quick jump to files 1-5
      { "<leader>1",  function() require("harpoon"):list():select(1) end, desc = "Harpoon file 1" },
      { "<leader>2",  function() require("harpoon"):list():select(2) end, desc = "Harpoon file 2" },
      { "<leader>3",  function() require("harpoon"):list():select(3) end, desc = "Harpoon file 3" },
      { "<leader>4",  function() require("harpoon"):list():select(4) end, desc = "Harpoon file 4" },
      { "<leader>5",  function() require("harpoon"):list():select(5) end, desc = "Harpoon file 5" },
    },
    opts = {
      settings = {
        save_on_toggle = true,
        sync_on_ui_close = true,
      },
    },
  },

  -- ── Oil: edit the filesystem like a buffer ────────────────────────────────
  {
    "stevearc/oil.nvim",
    cmd = "Oil",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "-", "<cmd>Oil<cr>", desc = "Open parent directory (oil)" },
    },
    opts = {
      default_file_explorer = false,
      columns = { "icon", "permissions", "size" },
      view_options = { show_hidden = true },
      keymaps = {
        ["<CR>"]  = "actions.select",
        ["<C-v>"] = "actions.select_vsplit",
        ["<C-x>"] = "actions.select_split",
        ["-"]     = "actions.parent",
        ["g."]    = "actions.toggle_hidden",
        ["q"]     = "actions.close",
        ["g?"]    = "actions.show_help",
      },
    },
  },

  -- ── Which-key: keymap hints ───────────────────────────────────────────────
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      plugins = { spelling = true },
      spec = {
        { "<leader>f", group = "find / file" },
        { "<leader>g", group = "git" },
        { "<leader>l", group = "lsp" },
        { "<leader>d", group = "debug" },
        { "<leader>h", group = "harpoon" },
        { "<leader>b", group = "buffer" },
        { "<leader>s", group = "search" },
        { "<leader>c", group = "code" },
        { "<leader>x", group = "diagnostics" },
        { "<leader>w", group = "window" },
      },
    },
  },

  -- ── Comments ──────────────────────────────────────────────────────────────
  {
    "numToStr/Comment.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
  },

  -- ── Auto-pairs ────────────────────────────────────────────────────────────
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {
      check_ts = true,
      ts_config = {
        lua = { "string" },
        javascript = { "template_string" },
      },
    },
  },

  -- ── Surround motions (ys, cs, ds) ─────────────────────────────────────────
  {
    "kylechui/nvim-surround",
    version = "*",
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
  },

  -- ── Flash: jump anywhere on screen ───────────────────────────────────────
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      { "s",     mode = { "n", "x", "o" }, function() require("flash").jump() end,            desc = "Flash jump" },
      { "S",     mode = { "n", "x", "o" }, function() require("flash").treesitter() end,       desc = "Flash treesitter" },
      { "r",     mode = "o",               function() require("flash").remote() end,           desc = "Flash remote" },
      { "<c-s>", mode = { "c" },           function() require("flash").toggle() end,           desc = "Flash toggle" },
    },
  },
}
