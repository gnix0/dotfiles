return {
  "craftzdog/solarized-osaka.nvim",
  name = "solarized-osaka",
  lazy = false,
  priority = 1000,
  opts = {},
  config = function()
	  require("solarized-osaka").setup({})
	  vim.cmd.colorscheme("solarized-osaka")
  end
}
