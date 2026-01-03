return {
  "mfussenegger/nvim-jdtls",
  ft = { "java" },
  dependencies = { "mfussenegger/nvim-dap" },

  config = function()
    local jdtls = require("jdtls")
    local dap = require("dap")

    local root_markers = { "mvnw", "gradlew", "pom.xml", "build.gradle", ".git" }
    local root_dir = vim.fs.root(0, root_markers)
    if not root_dir then
      return
    end

    local project_name = vim.fn.fnamemodify(root_dir, ":p:h:t")
    local workspace_dir = vim.fs.joinpath(vim.fn.stdpath("data"), "jdtls", project_name)
    vim.fn.mkdir(workspace_dir, "p")

    local capabilities = require("cmp_nvim_lsp").default_capabilities()

    local bundles = {}
    local mason_base = vim.fs.joinpath(vim.fn.stdpath("data"), "mason", "packages")

    local java_debug = vim.fn.glob(
      vim.fs.joinpath(mason_base, "java-debug-adapter", "extension", "server", "com.microsoft.java.debug.plugin-*.jar")
    )
    if java_debug ~= "" then
      table.insert(bundles, java_debug)
    end

    local function collect_java_test(dir)
      local globbed = vim.fn.glob(vim.fs.joinpath(mason_base, dir, "extension", "server", "*.jar"))
      if globbed ~= "" then
        for _, jar in ipairs(vim.split(globbed, "\n", { trimempty = true })) do
          table.insert(bundles, jar)
        end
      end
    end

    collect_java_test("java-test")
    collect_java_test("vscode-java-test") -- legacy folder name if already installed

    local function find_lombok()
      local candidates = {
        os.getenv("LOMBOK_JAR"),
        "/opt/homebrew/opt/lombok/libexec/lombok.jar",
        "/usr/local/opt/lombok/libexec/lombok.jar",
        vim.fs.joinpath(vim.fn.stdpath("data"), "lombok", "lombok.jar"),
        vim.fs.joinpath(root_dir, "lombok.jar"),
      }
      for _, path in ipairs(candidates) do
        if path and path ~= "" and vim.uv.fs_stat(path) then
          return path
        end
      end
      return nil
    end

    local lombok = find_lombok()

    local cmd = { "jdtls" }
    if lombok then
      table.insert(cmd, "-javaagent:" .. lombok)
    end
    table.insert(cmd, "-data")
    table.insert(cmd, workspace_dir)

    local config = {
      cmd = cmd,
      root_dir = root_dir,
      capabilities = capabilities,
      settings = {
        java = {
          signatureHelp = { enabled = true },
          completion = {
            favoriteStaticMembers = {
              "org.hamcrest.MatcherAssert.*",
              "org.hamcrest.Matchers.*",
              "org.junit.jupiter.api.Assertions.*",
              "org.mockito.Mockito.*",
            },
          },
        },
      },
      init_options = {
        bundles = bundles,
      },
    }

    jdtls.start_or_attach(config)
    jdtls.setup_dap({ hotcodereplace = "auto" })
    local jdtls_dap = require("jdtls.dap")
    jdtls_dap.setup_dap_main_class_configs()
    jdtls.setup.add_commands()

    dap.configurations.java = dap.configurations.java or {}
    local has_remote_attach = false
    for _, cfg in ipairs(dap.configurations.java) do
      if cfg.name == "Attach to 5005 (Spring/Jetty/Tomcat)" then
        has_remote_attach = true
        break
      end
    end
    if not has_remote_attach then
      table.insert(dap.configurations.java, {
        type = "java",
        request = "attach",
        name = "Attach to 5005 (Spring/Jetty/Tomcat)",
        hostName = "127.0.0.1",
        port = 5005,
      })
    end
  end,
}
