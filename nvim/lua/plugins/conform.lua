return {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    init = function()
        local function register_cpp_formatter()
            local cpp_format = require("config.cpp_format")
            LazyVim.format.register({
                name = "clang-format-ranges",
                primary = true,
                priority = 200,
                format = cpp_format.format,
                sources = cpp_format.sources,
            })
        end

        if vim.g.did_very_lazy then
            register_cpp_formatter()
        else
            LazyVim.on_very_lazy(register_cpp_formatter)
        end
    end,
    opts = {
        formatters_by_ft = {
            cs = { "csharpier" },
            go = { "goimports", "gofumpt" },
            rust = { "rustfmt", lsp_format = "fallback" },
            c = { "clang-format" },
            cpp = { "clang-format" },
            java = { "google-java-format" },
            ruby = { "rubocop" },
            python = { "ruff_format" },
            json = { "prettierd" },
            yaml = { "prettierd" },
            markdown = { "prettierd" },
            lua = { "stylua" },
            sh = { "shfmt" },
            ["_"] = { "trim_whitespace" },
        },
        notify_on_error = true,
        notify_no_formatters = true,
        formatters = {
            prettierd = { prepend_args = { "--tab-width=4" } },
            ["clang-format"] = {
                prepend_args = function()
                    return require("config.cpp_format").clang_format_prepend_args()
                end,
            },
            stylua = { prepend_args = { "--indent-type", "Spaces", "--indent-width", "4" } },
            shfmt = { prepend_args = { "-i", "4", "-s" } },
            ["google-java-format"] = { prepend_args = { "--aosp" } },
        },
    },
}
