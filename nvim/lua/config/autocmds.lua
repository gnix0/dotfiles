vim.api.nvim_create_autocmd("FileType", {
  pattern = { "c", "cpp" },
  callback = function()
    vim.opt_local.expandtab = false
    vim.opt_local.tabstop = 8
    vim.opt_local.softtabstop = 8
    vim.opt_local.shiftwidth = 8
    vim.opt_local.textwidth = 80
    vim.opt_local.colorcolumn = "80"
  end,
})

local large_file_group = vim.api.nvim_create_augroup("large_file", { clear = true })
vim.api.nvim_create_autocmd("BufReadPre", {
  group = large_file_group,
  callback = function(ev)
    local max_size = 1024 * 512
    local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(ev.buf))
    if ok and stats and stats.size > max_size then
      vim.b[ev.buf].large_file = true
      vim.opt_local.foldmethod = "manual"
      vim.opt_local.spell = false
      vim.opt_local.undolevels = 100
    end
  end,
})
vim.api.nvim_create_autocmd("BufReadPost", {
  group = large_file_group,
  callback = function(ev)
    if vim.b[ev.buf].large_file then
      vim.schedule(function()
        pcall(vim.treesitter.stop, ev.buf)
      end)
    end
  end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("highlight_yank", { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})
