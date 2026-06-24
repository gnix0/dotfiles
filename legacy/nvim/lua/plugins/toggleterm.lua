return {
  "akinsho/toggleterm.nvim",
  version = "*",
  keys = {
    { "<leader>ft", desc = "Toggle floating terminal" },
    { "<leader>m",  desc = "Toggle Maven/Gradle terminal" },
  },
  config = function()
    require("toggleterm").setup({
      shade_terminals = false,
      persist_size = true,
      persist_mode = true,
    })

    local Terminal = require("toggleterm.terminal").Terminal

    -- General-purpose floating terminal
    local float_term = Terminal:new({
      direction = "float",
      float_opts = { border = "rounded" },
      hidden = true,
    })

    -- Persistent bottom split for Maven/Gradle builds
    local build_term = Terminal:new({
      direction = "horizontal",
      size = 15,
      hidden = true,
    })

    vim.keymap.set("n", "<leader>ft", function() float_term:toggle() end, { desc = "Toggle floating terminal" })
    vim.keymap.set("n", "<leader>m",  function() build_term:toggle() end, { desc = "Toggle Maven/Gradle terminal" })

    -- Esc exits terminal mode (goes to normal mode inside terminal buffer)
    vim.api.nvim_create_autocmd("TermOpen", {
      pattern = "term://*toggleterm*",
      callback = function()
        local opts = { buffer = true, silent = true }
        vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", opts)
      end,
    })
  end,
}
