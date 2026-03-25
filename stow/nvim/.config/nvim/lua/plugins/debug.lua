return {
  -- ── nvim-dap: core debug adapter protocol ────────────────────────────────
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "theHamsta/nvim-dap-virtual-text",
      "nvim-neotest/nvim-nio",
      "jay-babu/mason-nvim-dap.nvim",
      "mfussenegger/nvim-dap-python",
    },
    keys = {
      { "<leader>db", function() require("dap").toggle_breakpoint() end,                              desc = "Toggle breakpoint" },
      { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input("Condition: ")) end,      desc = "Conditional breakpoint" },
      { "<leader>dc", function() require("dap").continue() end,                                       desc = "Continue" },
      { "<leader>di", function() require("dap").step_into() end,                                      desc = "Step into" },
      { "<leader>do", function() require("dap").step_over() end,                                      desc = "Step over" },
      { "<leader>dO", function() require("dap").step_out() end,                                       desc = "Step out" },
      { "<leader>dr", function() require("dap").repl.open() end,                                      desc = "REPL" },
      { "<leader>dl", function() require("dap").run_last() end,                                       desc = "Run last" },
      { "<leader>dt", function() require("dap").terminate() end,                                      desc = "Terminate" },
      { "<leader>du", function() require("dapui").toggle() end,                                       desc = "DAP UI" },
      { "<leader>de", function() require("dapui").eval() end,            mode = { "n", "v" },         desc = "Evaluate expression" },
    },
    config = function()
      local dap    = require("dap")
      local dapui  = require("dapui")

      -- ── DAP UI layout ────────────────────────────────────────────────────
      dapui.setup({
        icons = { expanded = "▾", collapsed = "▸", current_frame = "▸" },
        layouts = {
          {
            elements = {
              { id = "scopes",      size = 0.33 },
              { id = "breakpoints", size = 0.17 },
              { id = "stacks",      size = 0.25 },
              { id = "watches",     size = 0.25 },
            },
            size     = 0.33,
            position = "right",
          },
          {
            elements = {
              { id = "repl",    size = 0.45 },
              { id = "console", size = 0.55 },
            },
            size     = 0.27,
            position = "bottom",
          },
        },
        floating = { border = "rounded" },
      })

      -- Auto open/close UI with session lifecycle
      dap.listeners.before.attach.dapui_config          = function() dapui.open() end
      dap.listeners.before.launch.dapui_config          = function() dapui.open() end
      dap.listeners.before.event_terminated.dapui_config = function() dapui.close() end
      dap.listeners.before.event_exited.dapui_config    = function() dapui.close() end

      -- Virtual text alongside code
      require("nvim-dap-virtual-text").setup({ commented = true })

      -- ── JS / TS / Node adapter ───────────────────────────────────────────
      local js_debug_path = vim.fn.stdpath("data")
        .. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js"

      dap.adapters["pwa-node"] = {
        type = "server",
        host = "localhost",
        port = "${port}",
        executable = {
          command = "node",
          args    = { js_debug_path, "${port}" },
        },
      }

      for _, lang in ipairs({ "javascript", "typescript", "javascriptreact", "typescriptreact" }) do
        dap.configurations[lang] = {
          {
            type    = "pwa-node",
            request = "launch",
            name    = "Launch file",
            program = "${file}",
            cwd     = "${workspaceFolder}",
          },
          {
            type      = "pwa-node",
            request   = "attach",
            name      = "Attach to process",
            processId = require("dap.utils").pick_process,
            cwd       = "${workspaceFolder}",
          },
          {
            type            = "pwa-node",
            request         = "launch",
            name            = "Debug Jest tests",
            runtimeExecutable = "node",
            runtimeArgs     = { "./node_modules/jest/bin/jest.js", "--runInBand" },
            rootPath        = "${workspaceFolder}",
            cwd             = "${workspaceFolder}",
            console         = "integratedTerminal",
            internalConsoleOptions = "neverOpen",
          },
        }
      end

      -- ── Python adapter ───────────────────────────────────────────────────
      local debugpy_path = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"
      pcall(require("dap-python").setup, debugpy_path)
    end,
  },

  -- ── mason-nvim-dap: auto-install debug adapters ───────────────────────────
  {
    "jay-babu/mason-nvim-dap.nvim",
    dependencies = "williamboman/mason.nvim",
    cmd = { "DapInstall", "DapUninstall" },
    opts = {
      automatic_installation = true,
      handlers              = {},
      ensure_installed      = {
        "js",      -- JavaScript / TypeScript
        "python",  -- Python (debugpy)
        "javadbg", -- Java debug adapter
        "javatest",-- Java test runner
      },
    },
  },
}
