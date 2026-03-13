return {
  {
    "quarto-dev/quarto-nvim",
    dependencies = {
      "jmbuhr/otter.nvim",
      "nvim-treesitter/nvim-treesitter",
      "neovim/nvim-lspconfig",
      {
        "jpalardy/vim-slime",
        init = function()
          vim.g.slime_target = "neovim"
          vim.g.slime_python_ipython = 1
          vim.g.slime_bracketed_paste = 1
          vim.g.slime_no_mappings = 1
        end,
      },
    },
    ft = { "quarto", "markdown" },
    opts = {
      lsp_features = {
        enabled = true,
        chunks = "all",
        languages = { "python", "r", "sql" },
        diagnostics = { enabled = true, triggers = { "BufWritePost" } },
        completion = { enabled = true },
      },
      codeRunner = { enabled = true, default_method = "slime" },
    },
    config = function(_, opts)
      vim.filetype.add({ extension = { qmd = "quarto" } })
      local quarto = require("quarto")
      quarto.setup(opts)

      vim.treesitter.language.register("markdown", "quarto")

      local lspconfig = require("lspconfig")
      lspconfig.pyright.setup({})
      lspconfig.r_language_server.setup({ filetypes = { "r", "rmd" } })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "quarto",
        callback = function()
          vim.opt_local.expandtab = true
          vim.opt_local.shiftwidth = 4
          vim.opt_local.tabstop = 4
          vim.opt_local.softtabstop = 4
        end,
      })

      -- Autocommands
      local grp = vim.api.nvim_create_augroup("QuartoTweaks", { clear = true })

      vim.api.nvim_create_autocmd("LspAttach", {
        group = grp,
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          local buffer = args.buf
          if client and client.name == "r_language_server" and vim.bo[buffer].filetype == "quarto" then
            vim.lsp.stop_client(client.id)
          end
          -- Corrige Telescope no GD
          if vim.bo[buffer].filetype == "quarto" then
            vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = buffer, desc = "Go to Definition" })
            vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = buffer, desc = "Hover" })
          end
        end,
      })

      vim.api.nvim_create_autocmd({ "FileType", "BufEnter" }, {
        group = grp,
        pattern = "quarto",
        callback = function(event)
          if vim.b[event.buf].otter_activated then
            return
          end
          vim.b[event.buf].otter_activated = true
          require("otter").activate({ "python", "r", "sql" })
        end,
      })

      -- Binds
      local runner = require("quarto.runner")
      vim.keymap.set("n", "<leader>rc", runner.run_cell, { desc = "Run Cell" })
      vim.keymap.set("n", "<leader>ra", runner.run_above, { desc = "Run Above" })
      vim.keymap.set("n", "<leader>rA", runner.run_all, { desc = "Run All" })
      vim.keymap.set("n", "<leader>rl", runner.run_line, { desc = "Run Line" })
      vim.keymap.set("v", "<leader>r", runner.run_range, { desc = "Run Range" })
      vim.keymap.set("n", "<leader>rp", quarto.quartoPreview, { desc = "Preview" })
    end,
  },
}
