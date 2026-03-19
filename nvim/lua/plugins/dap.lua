return {
  "mfussenegger/nvim-dap",
  dependencies = {
    {
      "rcarriga/nvim-dap-ui",
      dependencies = { "nvim-neotest/nvim-nio" },
      config = function()
        local dapui = require("dapui")
        local dap = require("dap")

        dapui.setup({
          controls = { enabled = false },
          floating = { border = "rounded" },
          layouts = {
            {
              elements = { { id = "scopes", size = 1.0 } },
              size = 15,
              position = "bottom",
            },
          },
        })

        dap.listeners.after.event_initialized["dapui_config"] = dapui.open
        dap.listeners.before.event_terminated["dapui_config"] = dapui.close
        dap.listeners.before.event_exited["dapui_config"] = dapui.close

        vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DapBreakpoint" })
        vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DapStopped" })
        vim.fn.sign_define("DapBreakpointRejected", { text = "○", texthl = "DapBreakpointRejected" })
      end,
    },
    { "theHamsta/nvim-dap-virtual-text", opts = {} },
    "jay-babu/mason-nvim-dap.nvim",
    "leoluz/nvim-dap-go",
  },
  keys = {
    { "<F5>", function() require("dap").continue() end, desc = "Debug: Continue" },
    { "<F10>", function() require("dap").step_over() end, desc = "Debug: Step Over" },
    { "<F11>", function() require("dap").step_into() end, desc = "Debug: Step Into" },
    { "<F12>", function() require("dap").step_out() end, desc = "Debug: Step Out" },
    { "<leader>b", function() require("dap").toggle_breakpoint() end, desc = "Debug: Toggle Breakpoint" },
    { "<leader>B", function() require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: ")) end, desc = "Debug: Conditional Breakpoint" },
    { "<leader>du", function() require("dapui").toggle() end, desc = "Toggle DAP UI" },
    { "<leader>de", function() require("dapui").eval() end, desc = "Eval", mode = { "n", "v" } },
  },
  config = function()
    local dap = require("dap")

    require("mason-nvim-dap").setup({
      automatic_installation = true,
      ensure_installed = { "codelldb", "delve" },
    })

    require("dap-go").setup()

    dap.configurations.cpp = {
      {
        name = "Launch file",
        type = "codelldb",
        request = "launch",
        program = function()
          return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
        end,
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
      },
    }
    dap.configurations.c = dap.configurations.cpp
  end,
}
