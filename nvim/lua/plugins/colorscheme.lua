return {
  "rebelot/kanagawa.nvim",
  priority = 1000,
  config = function()
    require("kanagawa").setup({
      theme = "wave",
      transparent = true,
      overrides = function(colors)
        local theme = colors.theme
        return {
          -- General backgrounds
          Normal = { bg = "NONE" },
          NormalFloat = { bg = "NONE" },
          NormalNC = { bg = "NONE" },

          -- Line numbers and sign column
          LineNr = { bg = "NONE" },
          CursorLineNr = { bg = "NONE" },
          SignColumn = { bg = "NONE" },
          FoldColumn = { bg = "NONE" },

          -- Status and tab lines
          StatusLine = { bg = "NONE" },
          StatusLineNC = { bg = "NONE" },
          TabLine = { bg = "NONE" },
          TabLineFill = { bg = "NONE" },

          -- Floating windows and borders
          FloatBorder = { bg = "NONE" },
          FloatTitle = { bg = "NONE" },

          -- Telescope
          TelescopeNormal = { bg = "NONE" },
          TelescopeBorder = { bg = "NONE" },
          TelescopePromptNormal = { bg = "NONE" },
          TelescopePromptBorder = { bg = "NONE" },
          TelescopeResultsNormal = { bg = "NONE" },
          TelescopeResultsBorder = { bg = "NONE" },
          TelescopePreviewNormal = { bg = "NONE" },
          TelescopePreviewBorder = { bg = "NONE" },

          -- Completion menu
          Pmenu = { bg = "NONE" },
          PmenuSbar = { bg = "NONE" },

          -- Diagnostic signs
          DiagnosticSignError = { bg = "NONE" },
          DiagnosticSignWarn = { bg = "NONE" },
          DiagnosticSignInfo = { bg = "NONE" },
          DiagnosticSignHint = { bg = "NONE" },

          -- Git signs
          GitSignsAdd = { bg = "NONE" },
          GitSignsChange = { bg = "NONE" },
          GitSignsDelete = { bg = "NONE" },

          -- Cursor line (keep subtle highlight but transparent)
          CursorLine = { bg = theme.ui.bg_p1 },

          -- Color column
          ColorColumn = { bg = theme.ui.bg_p1 },

          -- Vertical split
          VertSplit = { bg = "NONE" },
          WinSeparator = { bg = "NONE" },
        }
      end,
    })
    vim.cmd.colorscheme("kanagawa-wave")
  end,
}
