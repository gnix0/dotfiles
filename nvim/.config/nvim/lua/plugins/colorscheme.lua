return {
	"miikanissi/modus-themes.nvim",
	name = "modus",
	lazy = false,
	priority = 1000,
	opts = {},
	config = function()
		require("modus-themes").setup({})
		vim.cmd.colorscheme("modus")
	end,
}
