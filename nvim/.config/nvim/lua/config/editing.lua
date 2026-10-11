-- Editing policy shared by ordinary LSP clients, rustaceanvim, and jdtls.
local M = {}

M.capabilities = {
  experimental = { snippetTextEdit = false },
  textDocument = {
    completion = { completionItem = { snippetSupport = false } },
    synchronization = { willSave = false, willSaveWaitUntil = false },
    formatting = { dynamicRegistration = false },
    rangeFormatting = { dynamicRegistration = false },
    onTypeFormatting = { dynamicRegistration = false },
  },
}

function M.protect_client(client)
  for _, capability in ipairs({
    "documentFormattingProvider",
    "documentRangeFormattingProvider",
    "documentOnTypeFormattingProvider",
    "willSaveWaitUntil",
  }) do
    client.server_capabilities[capability] = false
  end
end

function M.buffer_policy(buf)
  if not vim.api.nvim_buf_is_valid(buf) then
    return
  end
  local bo = vim.bo[buf]
  bo.formatexpr = ""
  bo.formatprg = ""
  bo.equalprg = ""
  bo.fixendofline = false
  bo.formatoptions = bo.formatoptions:gsub("[ta]", "")
  bo.shiftwidth = 4
  bo.tabstop = 4
  bo.softtabstop = 4
  bo.expandtab = bo.filetype ~= "make"
  -- Apply repository indentation *after* filetype defaults, without save edits.
  if vim.g.editorconfig ~= false and vim.b[buf].editorconfig ~= false then
    require("editorconfig").config(buf)
  end
  if bo.filetype == "make" then bo.expandtab = false end
end

function M.setup()
  vim.lsp.config("*", { capabilities = M.capabilities })

  -- LazyVim 16 creates its format hooks after user autocmds/keymaps load.
  -- Disable the integration at its entrypoints instead of racing that setup.
  local format = require("lazyvim.util.format")
  format.setup = function() end
  format.register = function() end
  format.format = function() end
  format.enable = function() vim.g.autoformat = false end
  format.enabled = function() return false end

  -- Native EditorConfig also supports source-modifying save hooks. Ignore
  -- those properties while continuing to respect indentation and other settings.
  local properties = require("editorconfig").properties
  properties.trim_trailing_whitespace = function() end
  properties.insert_final_newline = function() end
  -- Preserve existing encoding and line endings on write as well.
  properties.charset = function() end
  properties.end_of_line = function() end

  local group = vim.api.nvim_create_augroup("user_editing_policy", { clear = true })
  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    callback = function(event)
      M.buffer_policy(event.buf)
      vim.schedule(function() M.buffer_policy(event.buf) end)
    end,
  })
  vim.api.nvim_create_autocmd("LspAttach", {
    group = group,
    callback = function(event)
      local client = vim.lsp.get_client_by_id(event.data.client_id)
      if client then M.protect_client(client) end
      vim.bo[event.buf].formatexpr = ""
      vim.schedule(function()
        if vim.api.nvim_buf_is_valid(event.buf) then vim.bo[event.buf].formatexpr = "" end
      end)
    end,
  })

  vim.filetype.add({
    extension = { ld = "ld", lds = "ld", dtsi = "dts", overlay = "dts", S = "asm" },
  })
end

return M
