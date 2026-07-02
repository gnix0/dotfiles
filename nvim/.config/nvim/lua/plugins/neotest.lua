return {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-neotest/nvim-nio",
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "antoinemadec/FixCursorHold.nvim",
    "nvim-neotest/neotest-go",
    {
      "rcasia/neotest-java",
      ft = "java",
      dependencies = {
        "mfussenegger/nvim-jdtls",
        "mfussenegger/nvim-dap",
        "rcarriga/nvim-dap-ui",
        "theHamsta/nvim-dap-virtual-text",
      },
    },
  },
  keys = {
    { "<leader>tt", function() require("neotest").run.run() end, desc = "Run Nearest Test" },
    { "<leader>tf", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Run File" },
    { "<leader>to", function() require("neotest").output.open({ enter = true }) end, desc = "Test Output" },
    { "<leader>ts", function() require("neotest").summary.toggle() end, desc = "Test Summary" },
  },
  config = function()
    ---@diagnostic disable: missing-fields
    require("neotest").setup({
      adapters = {
        require("neotest-go")({
          experimental = { test_table = true },
        }),
        require("neotest-java")({
          ignore_wrapper = false, -- use mvnw/gradlew wrappers when present
        }),
      },
      output = { open_on_run = true },
      icons = {
        passed = " ",
        running = " ",
        failed = " ",
        unknown = " ",
      },
      status = { virtual_text = true },
      quickfix = { enabled = true, open = false },
    })
  end,
}
