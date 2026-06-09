return {
  -- ── Mason: package manager for LSPs / DAP / linters / formatters ──────────
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    keys = { { "<leader>lm", "<cmd>Mason<cr>", desc = "Mason" } },
    build = ":MasonUpdate",
    opts = {
      ui = {
        border = "rounded",
        icons = {
          package_installed   = "✓",
          package_pending     = "➜",
          package_uninstalled = "✗",
        },
      },
    },
  },

  -- ── LSP config + mason-lspconfig ─────────────────────────────────────────
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
      "b0o/SchemaStore.nvim",
      -- Better Lua LSP for Neovim config/plugins
      { "folke/lazydev.nvim", ft = "lua", opts = {} },
    },
    config = function()
      -- ── Keymaps on LSP attach ────────────────────────────────────────────
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("LspKeymaps", { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc)
            vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
          end

          map("gd",         function() require("telescope.builtin").lsp_definitions() end,       "Go to definition")
          map("gD",         vim.lsp.buf.declaration,                                             "Go to declaration")
          map("gr",         function() require("telescope.builtin").lsp_references() end,         "Find references")
          map("gi",         function() require("telescope.builtin").lsp_implementations() end,    "Go to implementation")
          map("gt",         function() require("telescope.builtin").lsp_type_definitions() end,   "Go to type definition")
          map("K",          vim.lsp.buf.hover,                                                   "Hover docs")
          map("<C-k>",      vim.lsp.buf.signature_help,                                          "Signature help")
          map("<leader>lr", vim.lsp.buf.rename,                                                  "Rename symbol")
          map("<leader>la", vim.lsp.buf.code_action,                                             "Code action")
          map("<leader>ls", function() require("telescope.builtin").lsp_document_symbols() end,  "Document symbols")
          map("<leader>lS", function() require("telescope.builtin").lsp_workspace_symbols() end, "Workspace symbols")
          map("<leader>lf", function() vim.lsp.buf.format({ async = true }) end,                 "Format")
          map("<leader>li", "<cmd>LspInfo<cr>",                                                  "LSP info")

          -- Toggle inlay hints when the server supports them
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client:supports_method("textDocument/inlayHint") then
            map("<leader>lh", function()
              vim.lsp.inlay_hint.enable(
                not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf })
              )
            end, "Toggle inlay hints")
          end
        end,
      })

      -- ── Diagnostic appearance ────────────────────────────────────────────
      vim.diagnostic.config({
        underline = true,
        update_in_insert = false,
        virtual_text = { spacing = 4, source = "if_many", prefix = "●" },
        severity_sort = true,
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = " ",
            [vim.diagnostic.severity.WARN]  = " ",
            [vim.diagnostic.severity.HINT]  = " ",
            [vim.diagnostic.severity.INFO]  = " ",
          },
        },
        float = { border = "rounded", source = "always" },
      })

      -- ── Capabilities (advertise nvim-cmp support) ────────────────────────
      local capabilities = vim.tbl_deep_extend(
        "force",
        vim.lsp.protocol.make_client_capabilities(),
        require("cmp_nvim_lsp").default_capabilities()
      )

      -- ── Server definitions ────────────────────────────────────────────────
      -- jdtls is intentionally absent – it is managed by ftplugin/java.lua
      local servers = {
        lua_ls = {
          settings = {
            Lua = {
              workspace = { checkThirdParty = false },
              telemetry = { enable = false },
              diagnostics = { globals = { "vim" } },
            },
          },
        },

        -- TypeScript / JavaScript
        ts_ls = {
          settings = {
            typescript = {
              inlayHints = {
                includeInlayParameterNameHints          = "all",
                includeInlayFunctionParameterTypeHints  = true,
                includeInlayVariableTypeHints           = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints        = true,
              },
            },
            javascript = {
              inlayHints = {
                includeInlayParameterNameHints = "all",
                includeInlayVariableTypeHints  = true,
              },
            },
          },
        },

        eslint = {
          on_attach = function(_, bufnr)
            vim.api.nvim_create_autocmd("BufWritePre", {
              buffer  = bufnr,
              command = "EslintFixAll",
            })
          end,
        },

        -- Python
        pyright = {
          settings = {
            python = {
              analysis = {
                typeCheckingMode   = "basic",
                autoSearchPaths    = true,
                useLibraryCodeForTypes = true,
              },
            },
          },
        },

        -- Shells / markup / config
        bashls  = {},
        html    = {},
        cssls   = {},
        jsonls  = {
          settings = {
            json = {
              schemas  = (function()
                local ok, ss = pcall(require, "schemastore")
                return ok and ss.json.schemas() or {}
              end)(),
              validate = { enable = true },
            },
          },
        },
        yamlls  = {
          settings = {
            yaml = {
              schemaStore = { enable = false, url = "" },
              schemas     = (function()
                local ok, ss = pcall(require, "schemastore")
                return ok and ss.yaml.schemas() or {}
              end)(),
            },
          },
        },
      }

      -- ── mason-lspconfig wiring ────────────────────────────────────────────
      require("mason-lspconfig").setup({
        ensure_installed    = vim.tbl_keys(servers),
        automatic_installation = true,
        handlers = {
          -- Default handler
          function(server_name)
            local cfg = vim.tbl_deep_extend("force", { capabilities = capabilities }, servers[server_name] or {})
            require("lspconfig")[server_name].setup(cfg)
          end,
          -- jdtls is handled by ftplugin/java.lua – skip here
          jdtls = function() end,
        },
      })
    end,
  },

  -- ── Schema store (JSON / YAML) ────────────────────────────────────────────
  { "b0o/SchemaStore.nvim", lazy = true },

  -- ── nvim-jdtls: Java LSP (loaded on .java files, configured in ftplugin) ─
  {
    "mfussenegger/nvim-jdtls",
    ft = "java",
  },

  -- ── Completion ────────────────────────────────────────────────────────────
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "saadparwaiz1/cmp_luasnip",
      "onsails/lspkind.nvim",
      {
        "L3MON4D3/LuaSnip",
        build = "make install_jsregexp",
        dependencies = { "rafamadriz/friendly-snippets" },
        config = function()
          require("luasnip.loaders.from_vscode").lazy_load()
        end,
      },
    },
    config = function()
      local cmp     = require("cmp")
      local luasnip = require("luasnip")
      local lspkind = require("lspkind")

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        window = {
          completion    = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"]     = cmp.mapping.scroll_docs(-4),
          ["<C-f>"]     = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"]     = cmp.mapping.abort(),
          ["<CR>"]      = cmp.mapping.confirm({ select = false }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp", priority = 1000 },
          { name = "luasnip",  priority = 750 },
          { name = "path",     priority = 500 },
          { name = "lazydev",  group_index = 0 },
        }, {
          { name = "buffer", priority = 250 },
        }),
        formatting = {
          format = lspkind.cmp_format({
            mode       = "symbol_text",
            maxwidth   = 50,
            ellipsis_char = "...",
            menu = {
              buffer   = "[Buf]",
              nvim_lsp = "[LSP]",
              luasnip  = "[Snip]",
              path     = "[Path]",
              lazydev  = "[Lazy]",
            },
          }),
        },
        experimental = {
          ghost_text = { hl_group = "CmpGhostText" },
        },
      })

      -- Search completion
      cmp.setup.cmdline({ "/", "?" }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = { { name = "buffer" } },
      })

      -- Command-line completion
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources(
          { { name = "path" } },
          { { name = "cmdline" } }
        ),
      })
    end,
  },
}
