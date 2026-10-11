-- Copy to a firmware project root. Launch Neovim from that project.
-- Select this project's compiler names here; do not change global options.
local compilers = { "arm-none-eabi-gcc", "arm-none-eabi-g++" }
-- RISC-V example: { "riscv64-unknown-elf-gcc", "riscv64-unknown-elf-g++" }
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
      table.insert(opts.servers.clangd.cmd, "--query-driver=" .. table.concat(drivers, ","))
    end,
  },
}
