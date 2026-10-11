return {
  {
    "nvim-telescope/telescope.nvim",
    keys = function(_, keys)
      local keep = {}
      for _, key in ipairs(keys) do
        if not key[1]:match("^<leader>s") then table.insert(keep, key) end
      end
      vim.list_extend(keep, {
        { "<leader>ff", LazyVim.pick("files"), desc = "Find Files (Root)" },
        { "<leader>fg", LazyVim.pick("live_grep"), desc = "Grep (Root)" },
        { "<leader>fb", "<cmd>Telescope buffers sort_mru=true sort_lastused=true<cr>", desc = "Buffers" },
        { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent Files" },
      })
      return keep
    end,
  },
  {
    "folke/which-key.nvim",
    opts = { spec = { { "<leader>s", group = "splits" } } },
  },
}
