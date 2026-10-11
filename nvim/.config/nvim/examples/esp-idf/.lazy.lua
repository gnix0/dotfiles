-- Use only in an ESP-IDF project, after sourcing that SDK's export.sh.
-- Set ESP_CLANGD to the SDK's clangd path in this project's shell.
local clangd = vim.env.ESP_CLANGD
assert(clangd and vim.fn.executable(clangd) == 1, "Set ESP_CLANGD to this SDK's clangd executable")
-- Match the project's selected IDF target. ESP32 example below; ESP32-C3/C6
-- use riscv32-esp-elf-gcc/g++, and ESP32-S3 uses xtensa-esp32s3-elf-gcc/g++.
local compilers = { "xtensa-esp32-elf-gcc", "xtensa-esp32-elf-g++" }
local drivers = {}
for _, name in ipairs(compilers) do
  local path = vim.fn.exepath(name)
  assert(path ~= "", "Project compiler not on PATH: " .. name)
  table.insert(drivers, path)
end
return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers.clangd.mason = false
      opts.servers.clangd.cmd[1] = clangd
      table.insert(opts.servers.clangd.cmd, "--query-driver=" .. table.concat(drivers, ","))
    end,
  },
}
