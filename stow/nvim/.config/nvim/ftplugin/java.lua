-- Java LSP via nvim-jdtls
-- Automatically sourced by Neovim for every Java buffer.
-- nvim-jdtls is installed by lazy.nvim (ft = "java"); jdtls itself via Mason.

local jdtls  = require("jdtls")
local mason  = vim.fn.stdpath("data") .. "/mason/packages"

-- ── Workspace (per-project data directory) ────────────────────────────────
local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
local workspace    = vim.fn.stdpath("data") .. "/jdtls-workspace/" .. project_name

-- ── Lombok ────────────────────────────────────────────────────────────────
-- Downloaded by install/nvim.sh during bootstrap; warn if missing.
local lombok_jar = vim.fn.expand("~/.local/share/nvim/lombok/lombok.jar")
if not vim.uv.fs_stat(lombok_jar) then
  vim.notify(
    "Lombok jar not found at " .. lombok_jar .. "\nRun install/nvim.sh or :!curl … to download it.",
    vim.log.levels.WARN,
    { title = "nvim-jdtls" }
  )
  lombok_jar = nil
end

-- ── Debug / test bundles (installed by mason-nvim-dap) ───────────────────
local bundles = {}
local debug_server = mason .. "/java-debug-adapter/extension/server"
local test_server  = mason .. "/vscode-java-test/extension/server"

if vim.fn.isdirectory(debug_server) == 1 then
  vim.list_extend(bundles, vim.split(
    vim.fn.glob(debug_server .. "/*.jar"), "\n", { trimempty = true }
  ))
end
if vim.fn.isdirectory(test_server) == 1 then
  vim.list_extend(bundles, vim.split(
    vim.fn.glob(test_server .. "/*.jar"), "\n", { trimempty = true }
  ))
end

-- ── jdtls binary paths (from Mason) ──────────────────────────────────────
local jdtls_path = mason .. "/jdtls"
local config_dir
if vim.fn.has("mac") == 1 then
  config_dir = jdtls_path .. "/config_mac"
else
  config_dir = jdtls_path .. "/config_linux"
end
local launcher = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")

-- ── Build cmd ─────────────────────────────────────────────────────────────
local cmd = {
  "java",
  "-Declipse.application=org.eclipse.jdt.ls.core.id1",
  "-Dosgi.bundles.defaultStartLevel=4",
  "-Declipse.product=org.eclipse.jdt.ls.core.product",
  "-Dlog.protocol=true",
  "-Dlog.level=ALL",
  "-Xms1g",
  "--add-modules=ALL-SYSTEM",
  "--add-opens", "java.base/java.util=ALL-UNNAMED",
  "--add-opens", "java.base/java.lang=ALL-UNNAMED",
  "-jar", launcher,
  "-configuration", config_dir,
  "-data", workspace,
}
if lombok_jar then
  table.insert(cmd, 4, "-javaagent:" .. lombok_jar)
end

-- ── Full config ───────────────────────────────────────────────────────────
local config = {
  cmd          = cmd,
  root_dir     = require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }),
  capabilities = require("cmp_nvim_lsp").default_capabilities(),

  settings = {
    java = {
      eclipse             = { downloadSources = true },
      maven               = { downloadSources = true },
      configuration       = { updateBuildConfiguration = "interactive" },
      implementationsCodeLens = { enabled = true },
      referencesCodeLens  = { enabled = true },
      references          = { includeDecompiledSources = true },
      inlayHints          = { parameterNames = { enabled = "all" } },
      format              = { enabled = true },
      signatureHelp       = { enabled = true },
      completion = {
        favoriteStaticMembers = {
          "org.hamcrest.MatcherAssert.assertThat",
          "org.hamcrest.Matchers.*",
          "org.junit.Assert.*",
          "org.junit.jupiter.api.Assertions.*",
          "org.mockito.Mockito.*",
          "org.mockito.ArgumentMatchers.*",
        },
        importOrder = { "java", "javax", "com", "org" },
      },
      sources = {
        organizeImports = { starThreshold = 9999, staticStarThreshold = 9999 },
      },
      codeGeneration = {
        toString = {
          template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
        },
        useBlocks = true,
      },
    },
  },

  init_options = { bundles = bundles },

  on_attach = function(_, bufnr)
    -- Enable DAP integration (requires java-debug-adapter bundle)
    jdtls.setup_dap({ hotcodereplace = "auto" })
    require("jdtls.dap").setup_dap_main_class_configs()

    -- Java-specific keymaps
    local map = function(keys, func, desc)
      vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "Java: " .. desc })
    end
    map("<leader>jo", jdtls.organize_imports,   "Organize imports")
    map("<leader>jv", jdtls.extract_variable,   "Extract variable")
    map("<leader>jc", jdtls.extract_constant,   "Extract constant")
    map("<leader>jt", jdtls.test_nearest_method, "Test method")
    map("<leader>jT", jdtls.test_class,          "Test class")
    map("<leader>ju", "<cmd>JdtUpdateConfig<cr>", "Update config")
  end,
}

jdtls.start_or_attach(config)
