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
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.smartindent = true

vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.scrolloff = 10
vim.opt.cursorline = true
vim.opt.guicursor = "a:block"

vim.opt.foldmethod = "manual"
vim.opt.foldenable = true
vim.opt.foldlevelstart = 99

vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.incsearch = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 200
vim.opt.wrap = false
vim.opt.colorcolumn = "80"

vim.opt.undofile = true
vim.opt.undodir = vim.fn.stdpath("data") .. "/undodir"
vim.opt.clipboard = "unnamedplus"

local function start_treesitter(buf)
    if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == "" and vim.bo[buf].filetype ~= "" then
        pcall(vim.treesitter.start, buf)
    end
end

vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("treesitter_start", { clear = true }),
    callback = function(ev)
        start_treesitter(ev.buf)
    end,
})
