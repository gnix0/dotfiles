return {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
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
            javascript = { "prettierd", "prettier", stop_after_first = true },
            typescript = { "prettierd", "prettier", stop_after_first = true },
            javascriptreact = { "prettierd", "prettier", stop_after_first = true },
            typescriptreact = { "prettierd", "prettier", stop_after_first = true },
            css = { "prettierd", "prettier", stop_after_first = true },
            html = { "prettierd", "prettier", stop_after_first = true },
            json = { "prettierd", "prettier", stop_after_first = true },
            yaml = { "prettierd", "prettier", stop_after_first = true },
            markdown = { "prettierd", "prettier", stop_after_first = true },
            lua = { "stylua" },
            sh = { "shfmt" },
            ["_"] = { "trim_whitespace" },
        },
        notify_on_error = true,
        notify_no_formatters = true,
        formatters = {
            prettier = { prepend_args = { "--tab-width", "4", "--use-tabs", "false" } },
            prettierd = { prepend_args = { "--tab-width", "4", "--use-tabs", "false" } },
            ["clang-format"] = {
                -- Use -style=file so clang-format searches for .clang-format
                -- going up the directory tree. For the Linux kernel source,
                -- it finds the kernel's own .clang-format at the repo root.
                -- For any other project under ~/, it finds ~/.clang-format
                -- (which mirrors the kernel's exact style). The fallback
                -- applies only for files outside ~ with no .clang-format.
                prepend_args = { "--style=file", "--fallback-style=Linux" },
            },
            stylua = { prepend_args = { "--indent-type", "Spaces", "--indent-width", "4" } },
            shfmt = { prepend_args = { "-i", "4", "-s" } },
            ["google-java-format"] = { prepend_args = { "--aosp" } },
        },
    },
}
