return {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },

    opts = {
        format_on_save = function(bufnr)
            return { timeout_ms = 3000, lsp_format = "fallback" }
        end,

        formatters_by_ft = {
            go = { "goimports", "gofumpt" },
            rust = { "rustfmt", lsp_format = "fallback" },
            c = { "clang-format" },
            cpp = { "clang-format" },
            elixir = { "mix" },
            json = { "prettierd" },
            yaml = { "prettierd" },
            lua = { "stylua" },
            sh = { "shfmt" },

            ["_"] = { "trim_whitespace" },
        },

        notify_on_error = true,
        notify_no_formatters = true,

        formatters = {
            ["clang-format"] = {
                prepend_args = {
                    "--style={BasedOnStyle: Google, IndentWidth: 2, TabWidth: 2, ColumnLimit: 100, AllowShortFunctionsOnASingleLine: Inline, AllowShortIfStatementsOnASingleLine: false, UseTab: Never}",
                },
            },

            stylua = {
                prepend_args = { "--indent-type", "Spaces", "--indent-width", "4" },
            },

            shfmt = {
                prepend_args = { "-i", "4", "-s" },
            },
        },
    },
}
