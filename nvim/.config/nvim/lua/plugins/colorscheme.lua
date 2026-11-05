return {
	{
		"ficcdaf/ashen.nvim",
		lazy = false,
		priority = 1000,
		opts = {
			transparent = true,
			colors = {
				background = "#000000",
			},
		},
		config = function(_, opts)
			require("ashen").setup(opts)
			vim.cmd.colorscheme("ashen")
		end,
	},
}
