return {
  "leoluz/nvim-dap-go",
  ft = "go",
  dependencies = {
    "mfussenegger/nvim-dap",
  },
  config = function(_, opts)
    require("dap-go").setup(opts)
    vim.keymap.set("n", "<leader>td", function()
      require("dap-go").debug_test()
    end, { desc = "Debug Nearest Test" })
  end,
}
