return {
  "nvim-telescope/telescope.nvim",
  cmd = "Telescope",
  version = false,
  dependencies = {
    { "nvim-lua/plenary.nvim" },
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
      config = function()
        require("telescope").load_extension("fzf")
      end,
    },
    {
      "nvim-telescope/telescope-ui-select.nvim",
      config = function()
        require("telescope").setup({
          extensions = {
            ["ui-select"] = require("telescope.themes").get_dropdown({}),
          },
        })
        require("telescope").load_extension("ui-select")
      end,
    },
  },
  keys = {
    { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files (Root)" },
    { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Grep (Root)" },
    { "<leader>fb", "<cmd>Telescope buffers sort_mru=true sort_lastused=true<cr>", desc = "Switch Buffer" },
    { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent" },
  },
  opts = {
    defaults = {
      prompt_prefix = " ",
      path_display = { "smart" },
      sorting_strategy = "ascending",
      file_ignore_patterns = {
        "node_modules",
        ".git/",
        "bin/",
        "obj/",
        "%.lock",
      },
      layout_config = {
        horizontal = { prompt_position = "top", preview_width = 0.55 },
        vertical = { mirror = false },
        preview_cutoff = 120,
      },
      preview = {
        filesize_limit = 2,
        timeout = 1000,
      },
    },
    pickers = {
      find_files = {
        find_command = { "fd", "--type", "f", "--strip-cwd-prefix", "--hidden", "--follow", "--exclude", ".git" },
      },
      buffers = {
        theme = "dropdown",
        previewer = false,
      },
    },
    extensions = {
      ["ui-select"] = {},
      fzf = {
        fuzzy = true,
        override_generic_sorter = true,
        override_file_sorter = true,
        case_mode = "smart_case",
      },
    },
  },
}
