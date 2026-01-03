return {
  "williamboman/mason.nvim",
  build = ":MasonUpdate",
  cmd = { "Mason", "MasonInstall", "MasonUpdate", "MasonUninstall" },

  config = function()
    require("mason").setup()

    local ensure = {
      -- LSP
      "jdtls",
      "lua-language-server",
      "typescript-language-server",
      -- Debugging/testing for Java
      "java-debug-adapter",
      "vscode-java-test",
    }

    local mr = require("mason-registry")
    local function ensure_installed()
      for _, name in ipairs(ensure) do
        local ok, pkg = pcall(mr.get_package, name)
        if ok then
          if not pkg:is_installed() then
            pkg:install()
          end
        end
      end
    end

    if mr.refresh then
      mr.refresh(ensure_installed)
    else
      ensure_installed()
    end
  end,
}
