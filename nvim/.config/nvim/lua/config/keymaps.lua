-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local function delete(mode, lhs)
  pcall(vim.keymap.del, mode, lhs)
end
for _, mode in ipairs({ "n", "x" }) do
  for _, lhs in ipairs({ "<leader>cf", "<leader>cF" }) do delete(mode, lhs) end
end
for _, lhs in ipairs({ "<leader>uf", "<leader>uF", "<leader>up" }) do delete("n", lhs) end
-- Remove LazyVim's native-snippet handling on Escape as well.
delete("i", "<Esc>")
delete("s", "<Esc>")
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear Search Highlight" })
for _, mode in ipairs({ "n", "i", "x" }) do
  for _, key in ipairs({ "<Up>", "<Down>", "<Left>", "<Right>" }) do
    vim.keymap.set(mode, key, "<Nop>", { silent = true })
  end
end

-- Clear the search menu, including mappings installed by LazyVim utilities.
for _, mode in ipairs({ "n", "x" }) do
  for _, map in ipairs(vim.api.nvim_get_keymap(mode)) do
    if map.lhs:sub(1, 2) == " s" then delete(mode, map.lhs) end
  end
end
vim.keymap.set("n", "<C-d>", "<C-d>zz", { silent = true })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { silent = true })
vim.keymap.set("n", "n", "nzzzv", { silent = true })
vim.keymap.set("n", "N", "Nzzzv", { silent = true })
vim.keymap.set("n", "gl", vim.diagnostic.open_float, { desc = "Line Diagnostics" })
vim.keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split Vertical" })
vim.keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split Horizontal" })
vim.keymap.set("n", "<leader>se", "<C-w>=", { desc = "Equalize Splits" })
vim.keymap.set("n", "<leader>sx", "<cmd>close<cr>", { desc = "Close Split" })
vim.keymap.set("n", "<leader>sj", "<C-w>-", { desc = "Decrease Height" })
vim.keymap.set("n", "<leader>sk", "<C-w>+", { desc = "Increase Height" })
vim.keymap.set("n", "<leader>s>", "10<C-w>>", { desc = "Increase Width" })
vim.keymap.set("n", "<leader>s<", "10<C-w><", { desc = "Decrease Width" })
