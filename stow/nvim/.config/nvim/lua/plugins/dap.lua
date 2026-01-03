return {
  "mfussenegger/nvim-dap",
  event = "VeryLazy",

  dependencies = {
    {
      "rcarriga/nvim-dap-ui",
      dependencies = { "nvim-neotest/nvim-nio" },
    },
    "theHamsta/nvim-dap-virtual-text",
  },

  config = function()
    local dap = require("dap")
    local dapui = require("dapui")

    dapui.setup()
    require("nvim-dap-virtual-text").setup()

    -- Åpne/lukk UI automatisk rundt økter
    dap.listeners.after.event_initialized["dapui_config"] = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated["dapui_config"] = function()
      dapui.close()
    end
    dap.listeners.before.event_exited["dapui_config"] = function()
      dapui.close()
    end

    local map = vim.keymap.set
    local opts = { silent = true }

    map("n", "<leader>dc", dap.continue, vim.tbl_extend("force", opts, { desc = "DAP continue" }))
    map("n", "<leader>db", dap.toggle_breakpoint, vim.tbl_extend("force", opts, { desc = "DAP toggle breakpoint" }))
    map("n", "<leader>do", dap.step_over, vim.tbl_extend("force", opts, { desc = "DAP step over" }))
    map("n", "<leader>di", dap.step_into, vim.tbl_extend("force", opts, { desc = "DAP step into" }))
    map("n", "<leader>du", dap.step_out, vim.tbl_extend("force", opts, { desc = "DAP step out" }))
    map("n", "<leader>dr", dap.repl.open, vim.tbl_extend("force", opts, { desc = "DAP REPL" }))
    map("n", "<leader>dl", dap.run_last, vim.tbl_extend("force", opts, { desc = "DAP run last" }))
    map("n", "<leader>dU", dapui.toggle, vim.tbl_extend("force", opts, { desc = "DAP UI toggle" }))
  end,
}
