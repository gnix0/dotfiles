return {
  "saghen/blink.cmp",
  version = "v0.*",
  event = "InsertEnter",
  dependencies = {
    "rafamadriz/friendly-snippets",
  },
  opts = {
    cmdline = { enabled = false },

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

    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
    },

    completion = {
      documentation = { auto_show = true, window = { border = "rounded" } },
      menu = { border = "rounded" },
    },
  },
}
