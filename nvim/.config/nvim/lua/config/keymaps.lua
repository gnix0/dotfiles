local function toggle_netrw()
	for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(bufnr) then
			if vim.bo[bufnr].filetype == "netrw" then
				vim.api.nvim_buf_delete(bufnr, { force = true })
				return
			end
		end
	end
	vim.cmd("Explore")
end

vim.keymap.set("n", "<leader>e", toggle_netrw, { silent = true, desc = "Toggle Explorer" })

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
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

vim.keymap.set("v", "<", "<gv", { silent = true })
vim.keymap.set("v", ">", ">gv", { silent = true })
