-- lua/plugins/lsp.lua

return {
  -- Ingen ekstern plugin nødvendig for core LSP
  -- Dette er kun for Lazy-arkitekturens skyld
  "neovim/nvim-lspconfig",
  lazy = true,

  config = function()
    -- 🔌 nvim-cmp capabilities
    local capabilities = require("cmp_nvim_lsp").default_capabilities()
    local function on_attach(client, bufnr)
      if client.server_capabilities.semanticTokensProvider then
        vim.lsp.semantic_tokens.start(bufnr, client.id)
      end
    end

    -- 🟦 TypeScript / JavaScript
    vim.lsp.start({
      name = "tsserver",
      cmd = { "typescript-language-server", "--stdio" },
      root_dir = vim.fs.root(0, {
        "package.json",
        "tsconfig.json",
        ".git",
      }),
      capabilities = capabilities,
      on_attach = on_attach,
    })

    -- 🟦 Lua (Neovim config)
    vim.lsp.start({
      name = "lua_ls",
      cmd = { "lua-language-server" },
      root_dir = vim.fs.root(0, { ".luarc.json", ".git" }),
      capabilities = capabilities,
      on_attach = on_attach,
      settings = {
        Lua = {
          diagnostics = {
            globals = { "vim" },
          },
          workspace = {
            library = vim.api.nvim_get_runtime_file("", true),
          },
        },
      },
    })
  end,
}
