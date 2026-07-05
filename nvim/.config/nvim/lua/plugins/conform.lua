return {
	"stevearc/conform.nvim",
	event = { "BufWritePre" },
	cmd = { "ConformInfo" },

	opts = {
		format_on_save = function(bufnr)
			return { timeout_ms = 3000, lsp_format = "fallback" }
		end,

		formatters_by_ft = {
			c = { "clang-format" },
			cpp = { "clang-format" },
			json = { "prettierd" },
			yaml = { "prettierd" },
			lua = { "stylua" },
			sh = { "shfmt" },

			["_"] = { "trim_whitespace" },
		},

		notify_on_error = true,
		notify_no_formatters = true,
	},
}
