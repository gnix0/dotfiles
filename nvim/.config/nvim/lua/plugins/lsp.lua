return {
	{
		"mason-org/mason.nvim",
		cmd = "Mason",
		opts = {},
		config = function(_, opts)
			require("mason").setup(opts)
			local registry = require("mason-registry")
		end,
	},
	{
		"mason-org/mason-lspconfig.nvim",
		dependencies = { "mason-org/mason.nvim" },
		opts = {
			ensure_installed = {
				"bashls",
				"jsonls",
				"yamlls",
				"dockerls",
				"docker_compose_language_service",
				"clangd",
			},
			handlers = {
				function(server_name)
					require("lspconfig")[server_name].setup({})
				end,
			},
		},
	},
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPost", "BufNewFile", "VeryLazy" },
		dependencies = {
			"mason-org/mason.nvim",
			"mason-org/mason-lspconfig.nvim",
			"b0o/schemastore.nvim",
		},
		config = function()
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

			vim.lsp.config("lua_ls", {
				settings = {
					Lua = {
						workspace = { checkThirdParty = false },
						telemetry = { enable = false },
					},
				},
			})

			vim.lsp.config("jsonls", {
				settings = {
					json = {
						schemas = require("schemastore").json.schemas(),
						validate = { enable = true },
					},
				},
			})

			vim.lsp.config("yamlls", {
				settings = {
					yaml = {
						schemaStore = {
							enable = false,
							url = "",
						},
						schemas = require("schemastore").yaml.schemas(),
						validate = true,
					},
				},
			})
		end,
	},
}
