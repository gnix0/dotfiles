-- Select a clangd command per workspace. Never execute a compiler from a database
-- merely because the database names it: query-driver only receives trusted paths.
local M = {}
local function real(path)
  return path and vim.uv.fs_realpath(path) or nil
end
local function inside(path, directory)
  return path and directory and (path == directory or path:sub(1, #directory + 1) == directory .. "/")
end
local function executable(path)
  return vim.fn.executable(path) == 1
end
local function read(path)
  local file = io.open(path, "rb")
  if not file then return nil end
  local data = file:read("*a")
  file:close()
  return data
end
local function database(root)
  for _, suffix in ipairs({ "/compile_commands.json", "/build/compile_commands.json" }) do
    local data = read(root .. suffix)
    if data then
      local ok, entries = pcall(vim.json.decode, data)
      if ok and type(entries) == "table" then return entries end
    end
  end
  return {}
end
local function uses(entries, name)
  for _, entry in ipairs(entries) do
    local command = entry.command or table.concat(entry.arguments or {}, " ")
    -- Token boundaries prevent matching g++ when only a longer name was used.
    for token in command:gmatch("[%w_+%.%-]+") do
      if token == name then return true end
    end
  end
  return false
end
local system_names = {
  "arm-none-eabi-gcc", "arm-none-eabi-g++",
  "riscv64-elf-gcc", "riscv64-elf-g++",
  "riscv64-unknown-elf-gcc", "riscv64-unknown-elf-g++",
  "riscv32-unknown-elf-gcc", "riscv32-unknown-elf-g++",
}
local esp_names = {
  "xtensa-esp-elf-gcc", "xtensa-esp-elf-g++",
  "xtensa-esp32-elf-gcc", "xtensa-esp32-elf-g++",
  "xtensa-esp32s2-elf-gcc", "xtensa-esp32s2-elf-g++",
  "xtensa-esp32s3-elf-gcc", "xtensa-esp32s3-elf-g++",
  "riscv32-esp-elf-gcc", "riscv32-esp-elf-g++",
}
function M.root(buf)
  local path = real(vim.api.nvim_buf_get_name(buf)) or vim.api.nvim_buf_get_name(buf)
  local marker = real(vim.env.DEV_IDF_PROJECT)
  if inside(path, marker) and vim.env.IDF_PATH then return marker end
  for directory in vim.fs.parents(path) do
    for _, marker_name in ipairs({ "compile_commands.json", "build/compile_commands.json", ".git" }) do
      if vim.uv.fs_stat(directory .. "/" .. marker_name) then return directory end
    end
  end
  return vim.fs.root(path, { ".clangd", "compile_flags.txt", "CMakeLists.txt", "Makefile", "meson.build" })
    or vim.fs.dirname(path)
end
function M.command(base, root)
  root = real(root) or root or vim.uv.cwd()
  local tools = real((vim.env.IDF_TOOLS_PATH or (vim.env.HOME .. "/.espressif")) .. "/tools")
  local marker = real(vim.env.DEV_IDF_PROJECT)
  local esp = inside(root, marker) and vim.env.IDF_PATH ~= nil
  local entries, drivers, seen = database(root), {}, {}
  local function allow(path)
    -- query-driver is a comma-separated glob list. Do not expand permission via
    -- a path containing its metacharacters. Spaces are ordinary argv content.
    if executable(path) and not path:find("[,?*%[%]]") and not seen[path] then
      seen[path] = true
      drivers[#drivers + 1] = path
    end
  end
  local cmd = vim.deepcopy(base)
  if esp then
    local clangd
    for _, directory in ipairs(vim.split(vim.env.PATH or "", ":", { plain = true })) do
      local candidate = directory .. "/clangd"
      if inside(real(candidate), tools and tools .. "/esp-clangd") and executable(candidate) then
        clangd = candidate
        break
      end
    end
    assert(clangd, "ESP-IDF: no SDK clangd on PATH. Review/allow .envrc; install the selected SDK's esp-clangd tool if missing, then restart Neovim.")
    cmd[1] = clangd
    for _, name in ipairs(esp_names) do
      local path = vim.fn.exepath(name)
      if path ~= "" and inside(real(path), tools) and uses(entries, name) then allow(path) end
    end
  else
    -- A host workspace opened from an IDF shell must still use host clangd.
    if inside(real(cmd[1]), tools) then
      assert(executable("/usr/bin/clangd"), "Host clangd missing: install clangd or start Neovim outside the ESP-IDF environment.")
      cmd[1] = "/usr/bin/clangd"
    end
    for _, name in ipairs(system_names) do
      if uses(entries, name) then allow("/usr/bin/" .. name) end
    end
  end
  if #drivers > 0 then cmd[#cmd + 1] = "--query-driver=" .. table.concat(drivers, ",") end
  return cmd
end
return M
