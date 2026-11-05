vim.keymap.set("n", "<Up>", "<Nop>", { noremap = true, silent = true })
vim.keymap.set("n", "<Down>", "<Nop>", { noremap = true, silent = true })
vim.keymap.set("n", "<Left>", "<Nop>", { noremap = true, silent = true })
vim.keymap.set("n", "<Right>", "<Nop>", { noremap = true, silent = true })
vim.keymap.set("i", "<Up>", "<Nop>", { noremap = true, silent = true })
vim.keymap.set("i", "<Down>", "<Nop>", { noremap = true, silent = true })
vim.keymap.set("i", "<Left>", "<Nop>", { noremap = true, silent = true })
vim.keymap.set("i", "<Right>", "<Nop>", { noremap = true, silent = true })
vim.keymap.set("v", "<Up>", "<Nop>", { noremap = true, silent = true })
vim.keymap.set("v", "<Down>", "<Nop>", { noremap = true, silent = true })
vim.keymap.set("v", "<Left>", "<Nop>", { noremap = true, silent = true })
vim.keymap.set("v", "<Right>", "<Nop>", { noremap = true, silent = true })

vim.keymap.set("n", "<C-d>", "<C-d>zz", { noremap = true, silent = true })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { noremap = true, silent = true })
vim.keymap.set("n", "n", "nzzzv", { noremap = true, silent = true })
vim.keymap.set("n", "N", "Nzzzv", { noremap = true, silent = true })

vim.keymap.set("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev Buffer", silent = true })
vim.keymap.set("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next Buffer", silent = true })
vim.keymap.set("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete Buffer", silent = true })
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

vim.keymap.set("n", "gl", vim.diagnostic.open_float, { desc = "Line Diagnostics" })

vim.keymap.set("v", "<", "<gv", { silent = true })
vim.keymap.set("v", ">", ">gv", { silent = true })

vim.keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split Vertical" })
vim.keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split Horizontal" })
vim.keymap.set("n", "<leader>se", "<C-w>=", { desc = "Equalize Splits" })
vim.keymap.set("n", "<leader>sx", "<cmd>close<cr>", { desc = "Close Split" })
vim.keymap.set("n", "<leader>sj", "<C-w>-", { desc = "Decrease Height" })
vim.keymap.set("n", "<leader>sk", "<C-w>+", { desc = "Increase Height" })
vim.keymap.set("n", "<leader>s>", "10<C-w>>", { desc = "Increase Width" })
vim.keymap.set("n", "<leader>s<", "10<C-w><", { desc = "Decrease Width" })

vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Go to Left Window", silent = true })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Go to Lower Window", silent = true })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Go to Upper Window", silent = true })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Go to Right Window", silent = true })

local function toggle_netrw()
    if vim.bo.filetype == "netrw" then
        vim.cmd.Rexplore()
    else
        vim.cmd.Explore()
    end
end

vim.keymap.set("n", "<leader>e", toggle_netrw, {
    silent = true,
    desc = "Toggle Netrw",
})
