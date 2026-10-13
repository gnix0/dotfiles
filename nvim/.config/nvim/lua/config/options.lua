-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.g.autoformat = false
vim.g.ai_cmp = false
vim.g.snacks_animate = false
vim.g.lazyvim_picker = "telescope"

local opt = vim.opt
opt.mouse = ""
opt.guicursor = "a:block"
opt.number = true
opt.relativenumber = true
opt.numberwidth = 2
opt.expandtab = true
opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.splitright = true
opt.splitbelow = true
opt.scrolloff = 10
opt.wrap = false
opt.foldmethod = "manual"
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.autowrite = false
opt.fixendofline = false
opt.formatexpr = ""
opt.formatprg = ""
opt.equalprg = ""
-- No text wrapping while typing. Native indentation and explicit = remain.
opt.formatoptions:remove({ "t", "a" })
-- Shared clipboard
opt.clipboard = "unnamedplus"

require("config.editing").setup()
