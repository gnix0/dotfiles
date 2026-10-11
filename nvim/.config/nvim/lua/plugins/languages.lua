local policy = require("config.editing")

-- Resolve before Mason prepends its bin directory. A system executable wins;
-- missing general-purpose servers are supplied by the existing Mason setup.
local system = {}
for server, binary in pairs({
  clangd = "clangd",
  bashls = "bash-language-server",
  gopls = "gopls",
  pyright = "pyright-langserver",
  ruff = "ruff",
  jsonls = "vscode-json-language-server",
  yamlls = "yaml-language-server",
  taplo = "taplo",
  marksman = "marksman",
  neocmake = "neocmakelsp",
  lua_ls = "lua-language-server",
  asm_lsp = "asm-lsp",
}) do
  local path = vim.fn.exepath(binary)
  if path ~= "" and not path:find("/mason/", 1, true) then system[server] = path end
end

return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.inlay_hints.enabled = false
      opts.folds.enabled = false
      opts.diagnostics.virtual_text = false
      opts.diagnostics.virtual_lines = false
      opts.diagnostics.underline = true
      opts.diagnostics.update_in_insert = false
      opts.diagnostics.severity_sort = true
      opts.diagnostics.float = { border = "rounded", source = true }
      opts.servers["*"].capabilities = vim.tbl_deep_extend("force", opts.servers["*"].capabilities or {}, policy.capabilities)
      opts.servers["*"].on_init = policy.protect_client
      opts.servers.bashls = {}
      opts.servers.asm_lsp = {
        root_markers = { ".asm-lsp.toml" },
        workspace_required = true,
      }
      opts.servers.clangd.root_markers = {
        "compile_commands.json", ".clangd", "compile_flags.txt", "CMakeLists.txt", "Makefile", "meson.build", ".git",
      }
      local cmd = opts.servers.clangd.cmd
      for index = #cmd, 1, -1 do
        if cmd[index] == "--function-arg-placeholders" then table.remove(cmd, index) end
      end
      table.insert(cmd, "--function-arg-placeholders=0")
      opts.servers.clangd.init_options.usePlaceholders = false
      -- clangd 23 deprecates its offsetEncoding extension; use LSP 3.17.
      opts.servers.clangd.capabilities.offsetEncoding = nil
      opts.servers.clangd.capabilities.general = { positionEncodings = { "utf-16" } }
      opts.servers.gopls.settings.gopls.usePlaceholders = false
      opts.servers.lua_ls.settings.Lua.completion.callSnippet = "Disable"
      for server, path in pairs(system) do
        local config = opts.servers[server]
        if config then
          config.mason = false
          local default_cmd = vim.lsp.config[server].cmd
          local command = config.cmd or default_cmd
          if type(command) ~= "table" then
            command = (server == "jsonls" or server == "yamlls") and { path, "--stdio" } or { path }
          end
          config.cmd = vim.deepcopy(command)
          config.cmd[1] = path
        end
      end
      -- Mason's npm packages require system Node/npm. Do not repeatedly try
      -- impossible installations; restarting after installing them enables these.
      if vim.fn.executable("node") == 0 or vim.fn.executable("npm") == 0 then
        for _, server in ipairs({ "bashls", "pyright", "jsonls", "yamlls" }) do
          if not system[server] and vim.fn.executable(({ bashls = "bash-language-server", pyright = "pyright-langserver", jsonls = "vscode-json-language-server", yamlls = "yaml-language-server" })[server]) == 0 then
            opts.servers[server].enabled = false
          end
        end
      end
    end,
  },
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      local excluded = {
        stylua = true, shfmt = true, goimports = true, gofumpt = true,
        cmakelang = true, codelldb = true, delve = true, debugpy = true, ["golangci-lint"] = true,
        ["java-debug-adapter"] = true, ["java-test"] = true,
        ["markdown-toc"] = true,
      }
      opts.ensure_installed = vim.tbl_filter(function(name) return not excluded[name] end, opts.ensure_installed or {})
      -- ShellCheck is diagnostics-only, not a formatter.
      if vim.fn.executable("shellcheck") == 0 and not vim.tbl_contains(opts.ensure_installed, "shellcheck") then
        table.insert(opts.ensure_installed, "shellcheck")
      end
    end,
  },
  {
    "mfussenegger/nvim-lint",
    opts = function(_, opts)
      -- gopls already provides Go/staticcheck diagnostics; avoid a second
      -- global lint pipeline with incompatible embedded/project assumptions.
      opts.linters_by_ft.go = nil
      opts.linters_by_ft.sh = { "shellcheck" }
      opts.linters.shellcheck = { cmd = vim.fn.exepath("shellcheck") ~= "" and vim.fn.exepath("shellcheck") or "shellcheck" }
    end,
  },
  {
    "mrcjkb/rustaceanvim",
    opts = function(_, opts)
      opts.server.capabilities = vim.deepcopy(policy.capabilities)
      opts.server.on_init = policy.protect_client
      opts.server.on_attach = function(_, buf)
        vim.keymap.set("n", "<leader>ca", function() vim.cmd.RustLsp("codeAction") end, { buffer = buf, desc = "Rust Code Action" })
        vim.keymap.set("n", "<leader>ce", function() vim.cmd.RustLsp("explainError") end, { buffer = buf, desc = "Explain Rust Error" })
      end
      local ra = opts.server.default_settings["rust-analyzer"]
      ra.cargo.allFeatures = false
      ra.check = { command = "check" }
      ra.checkOnSave = true
      ra.completion = { callable = { snippets = "none" }, snippets = { custom = {} } }
      -- The LazyVim Rust extra normally constructs a codelldb adapter even
      -- without DAP enabled. Override that setup while retaining rustaceanvim.
      opts.dap = { autoload_configurations = false, adapter = false }
    end,
    config = function(_, opts)
      vim.g.rustaceanvim = vim.tbl_deep_extend("keep", vim.g.rustaceanvim or {}, opts)
    end,
  },
  {
    "mfussenegger/nvim-jdtls",
    opts = function(_, opts)
      opts.project_name = function(root)
        return root and (vim.fs.basename(root) .. "-" .. vim.fn.sha256(root):sub(1, 10))
      end
      opts.dap = false
      opts.dap_main = false
      opts.test = false
      opts.jdtls = {
        capabilities = vim.deepcopy(policy.capabilities),
        on_init = policy.protect_client,
      }
      opts.settings.java.format = { enabled = false }
      opts.settings.java.saveActions = { organizeImports = false }
      opts.settings.java.completion = { guessMethodArguments = "off" }
    end,
  },
  {
    "Civitasv/cmake-tools.nvim",
    opts = {
      cmake_regenerate_on_save = false,
      cmake_compile_commands_options = { action = "none" },
    },
  },
}
