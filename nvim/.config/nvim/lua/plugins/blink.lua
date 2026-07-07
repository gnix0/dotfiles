return {
  'saghen/blink.cmp',
  dependencies = {
    'saghen/blink.lib',
    'rafamadriz/friendly-snippets',
  },
  build = function()
    require('blink.cmp').build():pwait()
  end,

  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    keymap = {
      preset = "none",
      ["<C-n>"] = { "select_next", "fallback" },
      ["<C-p>"] = { "select_prev", "fallback" },
      ["<C-y>"] = { "accept", "fallback" },
      ["<C-e>"] = { "hide", "fallback" },
      ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
      ["<C-f>"] = { "scroll_documentation_down" },
      ["<C-b>"] = { "scroll_documentation_up" },
    },

    completion = {
      documentation = { auto_show = true, window = { border = "rounded" } },
      menu = { border = "rounded" },
    },

    sources = { default = { 'lsp', 'path', 'snippets', 'buffer' } },

    fuzzy = { implementation = "rust" }
  },
}
