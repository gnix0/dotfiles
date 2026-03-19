return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  opts = {
    format_on_save = function(bufnr)
      local ft = vim.bo[bufnr].filetype
      if ft == "c" or ft == "cpp" then
        require("config.cpp_format").format(bufnr)
        return
      end
      return { timeout_ms = 3000, lsp_format = "fallback" }
    end,
    formatters_by_ft = {
      go = { "goimports", "gofumpt" },
      rust = { "rustfmt", lsp_format = "fallback" },
      c = { "clang-format" },
      cpp = { "clang-format" },
      java = { "google-java-format" },
      ruby = { "rubocop" },
      elixir = { "mix" },
      json = { "prettierd" },
      yaml = { "prettierd" },
      markdown = { "prettierd" },
      lua = { "stylua" },
      sh = { "shfmt" },
      ["_"] = { "trim_whitespace" },
    },
    notify_on_error = true,
    notify_no_formatters = true,
    formatters = {
      prettierd = { prepend_args = { "--tab-width=4" } },
      ["clang-format"] = {
        prepend_args = function()
          return require("config.cpp_format").clang_format_prepend_args()
        end,
      },
      stylua = { prepend_args = { "--indent-type", "Spaces", "--indent-width", "4" } },
      shfmt = { prepend_args = { "-i", "4", "-s" } },
      ["google-java-format"] = { prepend_args = { "--aosp" } },
    },
  },
}
