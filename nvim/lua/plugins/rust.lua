return {
  "mrcjkb/rustaceanvim",
  version = "^5",
  ft = { "rust" },
  config = function()
    vim.g.rustaceanvim = {
      server = {
        capabilities = require("blink.cmp").get_lsp_capabilities(),
        on_attach = function(_, bufnr)
          vim.keymap.set("n", "<leader>ca", function()
            vim.cmd.RustLsp("codeAction")
          end, { desc = "Rust Code Action", buffer = bufnr })
          vim.keymap.set("n", "<leader>ce", function()
            vim.cmd.RustLsp("explainError")
          end, { desc = "Explain Error", buffer = bufnr })
        end,
        default_settings = {
          ["rust-analyzer"] = {
            cargo = {
              allFeatures = true,
              loadOutDirsFromCheck = true,
              buildScripts = { enable = true },
            },
            checkOnSave = { command = "clippy" },
            procMacro = { enable = true },
          },
        },
      },
      dap = {},
    }
  end,
}
