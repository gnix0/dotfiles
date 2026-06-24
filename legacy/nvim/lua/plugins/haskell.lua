return {
    "neovim/nvim-lspconfig",
    ft = { "haskell", "lhaskell" },
    config = function()
        local lspconfig = require("lspconfig")

        lspconfig.hls.setup({
            capabilities = require("blink.cmp").get_lsp_capabilities(),

            on_attach = function(_, bufnr)
                vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, {
                    desc = "Code Action",
                    buffer = bufnr,
                })

                vim.keymap.set("n", "<leader>cr", vim.lsp.buf.rename, {
                    desc = "Rename Symbol",
                    buffer = bufnr,
                })

                vim.keymap.set("n", "<leader>ch", vim.lsp.buf.hover, {
                    desc = "Hover Documentation",
                    buffer = bufnr,
                })
            end,

            settings = {
                haskell = {
                    formattingProvider = "ormolu",
                },
            },
        })
    end,
}
