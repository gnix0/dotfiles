return {
    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                ruby_lsp = {
                    capabilities = require("blink.cmp").get_lsp_capabilities(),
                },
            },
        },
    },

    {
        "mason-org/mason.nvim",
        opts = {
            ensure_installed = {
                "ruby-lsp",
                "rubocop",
            },
        },
    },

    {
        "stevearc/conform.nvim",
        optional = true,
        opts = {
            formatters_by_ft = {
                ruby = { "rubocop" },
            },
        },
    },
}
