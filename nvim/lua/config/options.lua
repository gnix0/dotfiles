-- Better colors
vim.opt.termguicolors = true

-- Disable swaps
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false

-- Disable mouse
vim.opt.mouse = ""

-- Line numbers
vim.opt.relativenumber = true
vim.opt.number = true
vim.opt.numberwidth = 4

-- Use real tabs
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.smartindent = true

-- Split Windows
vim.opt.splitright = true
vim.opt.splitbelow = true

-- SCROLLING
vim.opt.scrolloff = 10

-- Cursor Line
vim.opt.cursorline = true
vim.opt.guicursor = "a:block"

-- No unpredictable folding
vim.opt.foldmethod = "manual"
vim.opt.foldenable = true
vim.opt.foldlevelstart = 99

-- For Searching
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.incsearch = true

-- Always show the sign column to avoid text shifting
vim.opt.signcolumn = "yes"

-- Faster updates for LSP, CursorHold, etc.
vim.opt.updatetime = 200

-- No line wrapping
vim.opt.wrap = false

-- Color column for style guides
vim.opt.colorcolumn = "80"

-- Persistent undo
vim.opt.undofile = true
vim.opt.undodir = vim.fn.stdpath("data") .. "/undodir"

-- Copy/paste between vim and system clipboard
vim.opt.clipboard = "unnamedplus"
