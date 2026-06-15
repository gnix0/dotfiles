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

vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Go to Left Window", silent = true })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Go to Lower Window", silent = true })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Go to Upper Window", silent = true })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Go to Right Window", silent = true })

vim.keymap.set("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move Down", silent = true })
vim.keymap.set("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move Up", silent = true })
vim.keymap.set("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move Down", silent = true })
vim.keymap.set("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move Up", silent = true })
vim.keymap.set("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Move Down", silent = true })
vim.keymap.set("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Move Up", silent = true })

vim.keymap.set("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev Buffer", silent = true })
vim.keymap.set("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next Buffer", silent = true })
vim.keymap.set("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete Buffer", silent = true })
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

vim.keymap.set("v", "<", "<gv", { silent = true })
vim.keymap.set("v", ">", ">gv", { silent = true })

vim.keymap.set("n", "gl", vim.diagnostic.open_float, { desc = "Line Diagnostics", silent = true })
vim.keymap.set("n", "[d", function() vim.diagnostic.jump({ count = -1 }) end, { desc = "Prev Diagnostic", silent = true })
vim.keymap.set("n", "]d", function() vim.diagnostic.jump({ count = 1 }) end, { desc = "Next Diagnostic", silent = true })
vim.keymap.set("n", "[e", function() vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.ERROR }) end,
    { desc = "Prev Error", silent = true })
vim.keymap.set("n", "]e", function() vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.ERROR }) end,
    { desc = "Next Error", silent = true })
vim.keymap.set("n", "[w", function() vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.WARN }) end,
    { desc = "Prev Warning", silent = true })
vim.keymap.set("n", "]w", function() vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.WARN }) end,
    { desc = "Next Warning", silent = true })
vim.keymap.set("n", "[q", "<cmd>cprev<cr>", { desc = "Prev Quickfix", silent = true })
vim.keymap.set("n", "]q", "<cmd>cnext<cr>", { desc = "Next Quickfix", silent = true })

vim.keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split Vertical" })
vim.keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split Horizontal" })
vim.keymap.set("n", "<leader>se", "<C-w>=", { desc = "Equalize Splits" })
vim.keymap.set("n", "<leader>sx", "<cmd>close<cr>", { desc = "Close Split" })
vim.keymap.set("n", "<leader>sj", "<C-w>-", { desc = "Decrease Height" })
vim.keymap.set("n", "<leader>sk", "<C-w>+", { desc = "Increase Height" })
vim.keymap.set("n", "<leader>s>", "<C-w>>10", { desc = "Increase Width" })
vim.keymap.set("n", "<leader>s<", "<C-w><10", { desc = "Decrease Width" })

vim.keymap.set("n", "<leader>ju", function()
    local ok, jdtls = pcall(require, "jdtls")
    if not ok then
        vim.notify("JDTLS not available in this buffer", vim.log.levels.WARN)
        return
    end
    jdtls.update_project_config()
    vim.notify("JDTLS project config updated", vim.log.levels.INFO)
end, { noremap = true, silent = true, desc = "Update JDTLS project config" })

vim.keymap.set("n", "<leader>rj", function()
    local ok, jdtls = pcall(require, "jdtls")
    if not ok then
        vim.notify("JDTLS not available in this buffer", vim.log.levels.WARN)
        return
    end

    local home = vim.env.HOME
    local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
    local workspace_dir = home .. "/jdtls-workspace/" .. project_name

    if vim.fn.isdirectory(workspace_dir) == 1 then
        vim.notify("Removing JDTLS workspace: " .. workspace_dir, vim.log.levels.WARN)
        vim.fn.delete(workspace_dir, "rf")
    else
        vim.notify("JDTLS workspace not found, skipping removal", vim.log.levels.INFO)
    end

    vim.cmd("wall")
    vim.defer_fn(function()
        pcall(function() jdtls.update_project_config() end)
        vim.cmd("JdtRestart")
        vim.notify("JDTLS restarted with clean workspace", vim.log.levels.INFO)
    end, 500)
end, { noremap = true, silent = true, desc = "Hard reset JDTLS" })

vim.keymap.set("n", "<leader>rl", function()
    vim.cmd("LspRestart")
    vim.notify("Reloading LSPs...", vim.log.levels.INFO)
end, { noremap = true, silent = true, desc = "Restart all LSP servers" })

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
vim.keymap.set("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Lazy" })
vim.keymap.set("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit All" })
