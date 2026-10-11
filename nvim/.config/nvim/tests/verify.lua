-- Run from the config root:
-- nvim --headless -i NONE '+lua dofile("tests/verify.lua")'
-- Temporary fixtures only; no source formatter or hardware task is invoked.
local failures, passed, errors = {}, {}, {}
local notify = vim.notify
vim.notify = function(message, level, opts)
  if level == vim.log.levels.ERROR then table.insert(errors, tostring(message)) end
  return notify(message, level, opts)
end
local function check(name, condition)
  table.insert(condition and passed or failures, name)
end
local function same_file(path, before)
  return vim.deep_equal(vim.fn.readfile(path, 'b'), before)
end
vim.api.nvim_exec_autocmds('UIEnter', {})
vim.defer_fn(function()
  local ok, err = pcall(function()
    require('lazy').load({ plugins = { 'nvim-lspconfig', 'blink.cmp', 'nvim-treesitter', 'nvim-lint', 'telescope.nvim' } })
    local plugins = require('lazy.core.config').plugins
    for _, plugin in ipairs({ 'conform.nvim', 'mini.pairs', 'friendly-snippets', 'LuaSnip', 'mini.snippets', 'nvim-ts-autotag', 'nvim-dap' }) do
      check('Excluded plugin: ' .. plugin, plugins[plugin] == nil)
    end
    check('Nightfox loads', vim.g.colors_name == 'nightfox')
    check('No autoformat', vim.g.autoformat == false)
    check('No formatting commands', vim.fn.exists(':LazyFormat') == 0 and vim.fn.exists(':ConformInfo') == 0)
    check('No formatting maps', vim.fn.maparg('<leader>cf','n') == '' and vim.fn.maparg('<leader>uf','n') == '')
    for _, mode in ipairs({'n','i','x'}) do
      check('Arrow keys disabled: '..mode, vim.fn.maparg('<Up>',mode)=='<Nop>')
    end
    check('Native =', vim.fn.maparg('=','n') == '' and vim.o.equalprg == '')
    check('No search menu', vim.fn.maparg('<leader>sg','n') == '' and vim.fn.maparg('<leader>ss','n') == '')
    check('Split maps', vim.fn.maparg('<leader>sv','n') ~= '')
    check('Diagnostic float map', vim.fn.maparg('gl','n') ~= '')
    check('Telescope grep map', vim.fn.maparg('<leader>fg','n') ~= '')
    check('Native search untouched', vim.fn.maparg('/','n') == '' and vim.fn.maparg('?','n') == '')
    local diagnostics = vim.diagnostic.config()
    check('Diagnostic display', diagnostics.virtual_text == false and diagnostics.underline and diagnostics.update_in_insert == false)
    local blink = require('blink.cmp.config')
    local function auto_show(value)
      if type(value) == 'function' then return value({}, {}) end
      return value
    end
    check('Manual completion menu', auto_show(blink.completion.menu.auto_show) == false)
    check('Manual cmdline completion', auto_show(blink.cmdline.completion.menu.auto_show) == false)
    check('No completion pairs', blink.completion.accept.auto_brackets.enabled == false)
    check('No completion ghost text', auto_show(blink.completion.ghost_text.enabled) == false)
    check('No snippet source', not vim.tbl_contains(blink.sources.default, 'snippets'))
    check('Filter LSP snippets', #blink.sources.transform_items({}, { { insertTextFormat = 2 }, { kind = 15 }, { label = 'plain', insertTextFormat = 1 } }) == 1)
    check('No Tab snippet jump', vim.deep_equal(blink.keymap['<Tab>'], {'fallback'}))
    check('Enter is not completion', blink.keymap['<CR>'] == nil)
    local root = vim.fn.tempname()
    vim.fn.mkdir(root, 'p')
    vim.fn.writefile({
      'root = true', '[*]', 'indent_style = space', 'indent_size = 2',
      'trim_trailing_whitespace = true', 'insert_final_newline = true',
      'end_of_line = lf', 'charset = utf-8-bom',
    }, root .. '/.editorconfig')
    local cases = {
      ['main.c'] = {'int main(){return 0;}  '},
      ['main.cpp'] = {'int main(){return 0;}  '},
      ['main.go'] = {'package main', 'func main(){ }  '},
      ['main.py'] = {'value=1  '},
      ['main.rs'] = {'fn main(){let _value=1;}  '},
      ['Main.java'] = {'class Main{public static void main(String[] a){}}  '},
      ['main.sh'] = {'#!/bin/sh', 'echo hello  '},
      ['main.json'] = {'{"value":1}  '},
      ['main.yaml'] = {'value: 1  '},
      ['main.toml'] = {'value=1  '},
      ['main.md'] = {'# Heading  '},
      ['CMakeLists.txt'] = {'cmake_minimum_required(VERSION 3.20)  '},
      ['firmware.ld'] = {'SECTIONS { .text : { *(.text*) } }  '},
      ['board.dts'] = {'/dts-v1/;', '/ { };  '},
      ['startup.S'] = {'.text', 'nop  '},
      ['Makefile'] = {'all:', '\t@echo hello  '},
    }
    local clients = {}
    for file, content in pairs(cases) do
      local path = root .. '/' .. file
      vim.fn.writefile(content, path, 'b') -- Deliberately no final newline.
      local before = vim.fn.readfile(path, 'b')
      vim.cmd.edit(vim.fn.fnameescape(path))
      vim.wait(150)
      check(file .. ': EditorConfig indentation', vim.bo.shiftwidth == 2)
      check(file .. ': no formatter expression', vim.bo.formatexpr == '' and vim.bo.formatprg == '' and vim.bo.equalprg == '')
      check(file .. ': manual folding', vim.wo.foldmethod == 'manual')
      if file == 'Makefile' then check('Make uses tabs', not vim.bo.expandtab) end
      vim.cmd.write()
      check(file .. ': exact save preserves whitespace/no final newline', same_file(path, before))
      for _, client in ipairs(vim.lsp.get_clients({bufnr=0})) do
        clients[client.id] = client
        if client.initialized then
          check(client.name .. ': formatting disabled', not client:supports_method('textDocument/formatting'))
          check(client.name .. ': no snippets', vim.tbl_get(client.config, 'capabilities', 'textDocument', 'completion', 'completionItem', 'snippetSupport') == false)
        end
      end
    end
    local crlf = root .. '/crlf.c'
    local binary = assert(io.open(crlf,'wb'))
    binary:write('int value;  \r\n')
    binary:close()
    vim.cmd.edit(vim.fn.fnameescape(crlf))
    vim.wait(100)
    vim.cmd.write()
    binary = assert(io.open(crlf,'rb'))
    check('Save preserves CRLF and encoding despite EditorConfig', binary:read('*a')=='int value;  \r\n')
    binary:close()
    -- A repository without EditorConfig uses four spaces even for Go.
    local plain = vim.fn.tempname()
    vim.fn.mkdir(plain, 'p')
    for _, file in ipairs({'main.c','main.go','main.py','main.rs','Main.java'}) do
      vim.fn.writefile({' '}, plain .. '/' .. file)
      vim.cmd.edit(vim.fn.fnameescape(plain .. '/' .. file))
      vim.wait(100)
      check(file .. ': four-space fallback', vim.bo.shiftwidth == 4 and vim.bo.tabstop == 4 and vim.bo.softtabstop == 4 and vim.bo.expandtab)
    end
    vim.fn.writefile({'int main() {', 'return 0;', '}'}, plain .. '/indent.c')
    vim.cmd.edit(vim.fn.fnameescape(plain .. '/indent.c'))
    vim.api.nvim_buf_set_lines(0, 0, -1, false, {'int main() {', 'return 0;', '}'})
    vim.cmd('normal! gg=G')
    check('Native = actually indents', vim.api.nvim_buf_get_lines(0,1,2,false)[1] == '    return 0;')
    for _, pair in ipairs({'(', '[', '{', '<', '"', "'"}) do
      vim.api.nvim_buf_set_lines(0,0,-1,false,{''})
      vim.api.nvim_win_set_cursor(0,{1,0})
      vim.api.nvim_feedkeys('i' .. pair .. vim.api.nvim_replace_termcodes('<Esc>',true,false,true), 'xt', false)
      check('No automatic pair: ' .. pair, vim.api.nvim_get_current_line() == pair)
    end
    for _, lang in ipairs({'asm','nasm','linkerscript','make','devicetree'}) do
      check('Parser loads: ' .. lang, pcall(vim.treesitter.language.add, lang))
    end
    for _, client in pairs(clients) do client:stop(true) end
    local cmake = LazyVim.opts('cmake-tools.nvim')
    check('No CMake save regeneration', cmake.cmake_regenerate_on_save == false)
    check('No database copying', cmake.cmake_compile_commands_options.action == 'none')
    check('Inlay hints disabled by default', LazyVim.opts('nvim-lspconfig').inlay_hints.enabled == false)
    local commands = vim.api.nvim_get_autocmds({event='BufWritePre'})
    check('No LazyFormat save hook', not vim.tbl_contains(vim.tbl_map(function(c) return c.group_name or '' end, commands), 'LazyFormat'))
    local messages = vim.api.nvim_exec2('messages', {output=true}).output
    vim.fn.writefile(vim.split(messages,'\n'), '/tmp/nvim-verification-messages.txt')
  end)
  if not ok then table.insert(failures, tostring(err)) end
  for _, error in ipairs(errors) do table.insert(failures, error) end
  vim.fn.writefile(vim.split(vim.inspect({passed=passed, failures=failures}), '\n'), '/tmp/nvim-verification.txt')
  print(('Verification: %d passed, %d failed'):format(#passed,#failures))
  vim.cmd(#failures == 0 and 'qa!' or 'cquit 1')
end, 1000)
