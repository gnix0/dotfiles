return {
  { "stevearc/conform.nvim", enabled = false },
  { "nvim-mini/mini.pairs", enabled = false },
  { "rafamadriz/friendly-snippets", enabled = false },
  { "L3MON4D3/LuaSnip", enabled = false },
  { "nvim-mini/mini.snippets", enabled = false },
  { "windwp/nvim-ts-autotag", enabled = false },
  { "mfussenegger/nvim-dap", enabled = false },
  {
    "saghen/blink.cmp",
    opts = function(_, opts)
      opts.keymap = {
        preset = "none",
        ["<C-n>"] = { "select_next", "fallback" },
        ["<C-p>"] = { "select_prev", "fallback" },
        ["<C-y>"] = { "accept", "fallback" },
        ["<C-e>"] = { "hide", "fallback" },
        ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<C-f>"] = { "scroll_documentation_down", "fallback" },
        ["<C-b>"] = { "scroll_documentation_up", "fallback" },
        -- Prevent LazyVim from injecting snippet jumps on Tab.
        ["<Tab>"] = { "fallback" },
        ["<S-Tab>"] = { "fallback" },
      }
      opts.completion.menu.auto_show = false
      opts.completion.accept.auto_brackets.enabled = false
      opts.completion.ghost_text = { enabled = false }
      opts.completion.list = { selection = { preselect = false, auto_insert = false } }
      opts.sources.default = { "lsp", "path", "buffer" }
      opts.sources.providers = opts.sources.providers or {}
      opts.sources.providers.snippets = nil
      opts.sources.transform_items = function(_, items)
        return vim.tbl_filter(function(item)
          return item.insertTextFormat ~= 2 and item.kind ~= vim.lsp.protocol.CompletionItemKind.Snippet
        end, items)
      end
      opts.snippets = {
        expand = function() end,
        active = function() return false end,
        jump = function() return false end,
      }
      opts.cmdline = {
        enabled = true,
        keymap = vim.deepcopy(opts.keymap),
        completion = {
          menu = { auto_show = false },
          list = { selection = { preselect = false, auto_insert = false } },
          ghost_text = { enabled = false },
        },
      }
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.indent = { enable = false }
      opts.folds = { enable = false }
      for _, lang in ipairs({ "asm", "nasm", "linkerscript", "make", "devicetree" }) do
        if not vim.tbl_contains(opts.ensure_installed, lang) then table.insert(opts.ensure_installed, lang) end
      end
    end,
  },
}
