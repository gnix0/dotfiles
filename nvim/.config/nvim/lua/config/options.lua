vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.opt.termguicolors = true
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.mouse = ""

vim.opt.relativenumber = true
vim.opt.number = true
vim.opt.numberwidth = 2

vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.smartindent = true

vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.scrolloff = 10
vim.opt.cursorline = ture
vim.opt.guicursor = "a:block"

vim.opt.foldmethod = "manual"
vim.opt.foldenable = true
vim.opt.foldlevelstart = 109

vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.incsearch = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 200
vim.opt.wrap = false
vim.opt.colorcolumn = "110"

vim.opt.undofile = true
vim.opt.undodir = vim.fn.stdpath("data") .. "/undodir"
vim.opt.clipboard = "unnamedplus"
