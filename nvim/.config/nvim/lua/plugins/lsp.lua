return {
    {
        "mason-org/mason.nvim",
        cmd = "Mason",
        opts = {},
        config = function (_, opts)
            require("mason").setup(opts)

            local registry = require("mason-registry")
            local ensure_installed = { "prettierd" }

            local function install_missing()
                for _, name in ipairs(ensure_installed) do
                    local ok, package = pcall(registry.get_package, name)
                    if ok and not package:is_installed() then
                        package:install()
                    end
                end
            end

            if registry.refresh then
                registry.refresh(install_missing)
            else
                install_missing()
            end
        end
    },
    {
        "mason-org/mason-lspconfig.nvim",
        dependencies = { "mason-org/mason.nvim" },
        opts = {
            ensure_installed = {
                "gopls",
                "elixirls",
                "rust_analyzer",
                "ts_ls",
                "bashls",
                "jsonls",
                "yamlls",
                "html",
                "cssls",
                "emmet_language_server",
                "angularls",
                "vue_ls",
                "dockerls",
                "docker_compose_language_service",
                "eslint",
                "clangd"
            },
            handlers = {
                function (server_name)
                    require("lspconfig")[server_name].setup({})
                end
            }
        }
    },
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPost", "BufNewFile", "VeryLazy" },
        dependencies = {
            "mason-org/mason.nvim",
            "mason-org/mason-lspconfig.nvim",
            "b0o/schemastore.nvim"
        },
        config = function ()
            vim.diagnostic.config({
                virtual_text = false,
                signs = true,
                underline = true,
                update_in_insert = false,
                severity_sort = true,
                float = {
                    border = "rounded",
                    source = true
                }
            })

            vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup("lsp_keymaps", { clear = true }),
                callback = function (ev)
                    local buf = ev.buf
                    local map = function (mode, lhs, rhs, desc)
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
                    map("n", "<leader>cf", function ()
                        vim.lsp.buf.format({ async = true })
                    end, "Format"
                    )
                end
            })

            local capabilities = require("blink.cmp").get_lsp_capabilities()

            vim.lsp.config("*", {
                capabilities = capabilities
            })

            vim.lsp.config("clangd", {
                capabilities = vim.tbl_deep_extend("force", capabilities, {
                    offsetEncoding = { "utf-8" }
                }),
                cmd = {
                    "clangd",
                    "--query-driver=/run/current-system/sw/bin/*",
                    "--background-index",
                    "--clang-tidy",
                    "--header-insertion=iwyu",
                    "--completion-style=detailed",
                    "--function-arg-placeholders",
                    "--fallback-style=none",
                    "-j=4"
                },
                init_options = {
                    usePlaceholders = true,
                    completeUnimported = true,
                    clangdFileStatus = true
                }
            })

            vim.lsp.config("gopls", {
                settings = {
                    gopls = {
                        analyses = {
                            unusedparams = true,
                            shadow = true,
                            nilness = true,
                            unusedwrite = true
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
                            rangeVariableTypes = true
                        }
                    }
                }
            })

            vim.lsp.config("elixirls", {
                cmd = { "elixir-ls" }
            })

            vim.lsp.config("lua_ls", {
                settings = {
                    Lua = {
                        workspace = { checkThirdParty = false },
                        telemetry = { enable = false }
                    }
                }
            })

            vim.lsp.config("eslint", {
                settings = { workingDirectories = { mode = "auto" } }
            })

            vim.lsp.config("jsonls", {
                settings = {
                    json = {
                        schemas = require("schemastore").json.schemas(),
                        validate = { enable = true }
                    }
                }
            })

            vim.lsp.config("yamlls", {
                settings = {
                    yaml = {
                        schemaStore = {
                            enable = false,
                            url = ""
                        },
                        schemas = require("schemastore").yaml.schemas(),
                        validate = true
                    }
                }
            })

            vim.lsp.config("html", {
                filetypes = { "html", "htmlangular" }
            })

            vim.lsp.config("cssls", {
                settings = {
                    css = { validate = true },
                    less = { validate = true },
                    scss = { validate = true }
                }
            })

            -- mason-lspconfig automatically enables installed servers. Avoid
            -- enabling every configured server here, because many of them may
            -- not be installed yet on a fresh machine.
        end
    }
}
