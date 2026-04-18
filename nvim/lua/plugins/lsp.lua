return {
    {
        "mason-org/mason.nvim",
        cmd = "Mason",
        opts = {},
    },
    {
        "mason-org/mason-lspconfig.nvim",
        enabled = false,
        dependencies = { "mason-org/mason.nvim" },
        opts = {
            ensure_installed = {
                "clangd",
                "gopls",
                "ruby_lsp",
                "elixirls",
                "lua_ls",
                "jdtls",
                "rust_analyzer",
                "ts_ls",
                "bashls",
                "jsonls",
                "yamlls",
                "dockerls",
                "docker_compose_language_service",
                "eslint",
            },
        },
    },
    {
        "saghen/blink.cmp",
        lazy = true,
    },
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPost", "BufNewFile", "VeryLazy" },
        dependencies = {
            "mason-org/mason.nvim",
            "mason-org/mason-lspconfig.nvim",
            "saghen/blink.cmp",
        },
        config = function()
            vim.diagnostic.config({
                virtual_text = false,
                signs = true,
                underline = true,
                update_in_insert = false,
                severity_sort = true,
                float = {
                    border = "rounded",
                    source = true,
                },
            })

            vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup("lsp_keymaps", { clear = true }),
                callback = function(ev)
                    local buf = ev.buf
                    local map = function(mode, lhs, rhs, desc)
                        vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = desc, silent = true })
                    end

                    map("n", "gd", vim.lsp.buf.definition, "Goto Definition")
                    map("n", "gr", vim.lsp.buf.references, "References")
                    map("n", "gD", vim.lsp.buf.declaration, "Goto Declaration")
                    map("n", "gI", vim.lsp.buf.implementation, "Goto Implementation")
                    map("n", "gy", vim.lsp.buf.type_definition, "Goto Type Definition")
                    map("n", "K", vim.lsp.buf.hover, "Hover")
                    map("n", "gK", vim.lsp.buf.signature_help, "Signature Help")
                    map("i", "<C-k>", vim.lsp.buf.signature_help, "Signature Help")
                    map("n", "<leader>ca", vim.lsp.buf.code_action, "Code Action")
                    map("n", "<leader>cr", vim.lsp.buf.rename, "Rename")
                    map("n", "<leader>cf", function()
                        vim.lsp.buf.format({ async = true })
                    end, "Format")
                end,
            })

            local capabilities = require("blink.cmp").get_lsp_capabilities()

            vim.lsp.config("*", {
                capabilities = capabilities,
            })

            vim.lsp.config("clangd", {
                capabilities = vim.tbl_deep_extend("force", capabilities, {
                    offsetEncoding = { "utf-8" },
                }),
                cmd = {
                    "clangd",
                    "--background-index",
                    "--clang-tidy",
                    "--header-insertion=iwyu",
                    "--completion-style=detailed",
                    "--function-arg-placeholders",
                    "--fallback-style=none",
                    "-j=4",
                },
                init_options = {
                    usePlaceholders = true,
                    completeUnimported = true,
                    clangdFileStatus = true,
                },
            })

            vim.lsp.config("gopls", {
                settings = {
                    gopls = {
                        analyses = {
                            unusedparams = true,
                            shadow = true,
                            nilness = true,
                            unusedwrite = true,
                        },
                        staticcheck = true,
                        gofumpt = true,
                        usePlaceholders = true,
                        completeUnimported = true,
                        hints = {
                            assignVariableTypes = true,
                            compositeLiteralFields = true,
                            compositeLiteralTypes = true,
                            constantValues = true,
                            functionTypeParameters = true,
                            parameterNames = true,
                            rangeVariableTypes = true,
                        },
                    },
                },
            })

            vim.lsp.config("elixirls", {
                cmd = { "elixir-ls" },
            })

            vim.lsp.config("lua_ls", {
                settings = {
                    Lua = {
                        workspace = { checkThirdParty = false },
                        telemetry = { enable = false },
                    },
                },
            })

            vim.lsp.config("eslint", {
                settings = { workingDirectories = { mode = "auto" } },
            })

            vim.lsp.enable({
                "clangd",
                "gopls",
                "ruby_lsp",
                "elixirls",
                "lua_ls",
                "ts_ls",
                "bashls",
                "jsonls",
                "yamlls",
                "dockerls",
                "docker_compose_language_service",
                "eslint",
            })
        end,
    },
}
