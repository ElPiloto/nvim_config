local M = {}

M._local_settings = nil

M.config = function(local_settings)
  M._local_settings = local_settings
  return M
end

local setup_sumneko = function()
  local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())

  local runtime_path = vim.split(package.path, ';')
  local lsp_flags = {
    -- Allow using incremental sync for buffer edits
    allow_incremental_sync = true,
    -- Debounce didChange notifications to the server in milliseconds (default=150 in Nvim 0.7+)
    debounce_text_changes = 150,
  }
  table.insert(runtime_path, 'lua/?.lua')
  table.insert(runtime_path, 'lua/?/init.lua')

  -- Key Mappings
  local opts = { noremap = true, silent = true }
  local keymap = vim.api.nvim_buf_set_keymap

  local function lsp_keymaps(bufnr)
    keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
    keymap(bufnr, 'n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
    -- Other keymaps...
  end

  local on_attach = function(client, bufnr)
      lsp_keymaps(bufnr)
  end

  local lspconfig = require('lspconfig')
  lspconfig.sumneko_lua.setup({
    flags = lsp_flags,
    capabilities = capabilities,
    on_attach = on_attach, settings = { Lua = { runtime = {
        -- Tell the language server which version of Lua you're using (most
        -- likely LuaJIT in the case of Neovim)
        version = "LuaJIT",
        -- Setup your lua path
        path = runtime_path, }, diagnostics = {
        -- Get the language server to recognize the `vim` global
        globals = { "vim" }, },
        workspace = {
        -- Make the server aware of Neovim runtime files
        --library = api.nvim_get_runtime_file("", true),
        [vim.fn.expand('$VIMRUNTIME/lua')] = true,
        [vim.fn.stdpath('config') .. '/lua'] = true,
      },
    -- Do not send telemetry data containing a randomized but unique identifier
    telemetry = { enable = false, }, }, }, })

end

M.setup = function()
  local can_setup = is_loaded('nvim-lspconfig') and is_loaded('cmp-nvim-lsp')

  if not can_setup then
    print('Aborting setup of lsp...')
    return
  end

  local border = {
      {"🭽", "FloatBorder"},
      {"▔", "FloatBorder"},
      {"🭾", "FloatBorder"},
      {"▕", "FloatBorder"},
      {"🭿", "FloatBorder"},
      {"▁", "FloatBorder"},
      {"🭼", "FloatBorder"},
      {"▏", "FloatBorder"},
  }

  vim.diagnostic.config({
    virtual_text = false
  })

  local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
  function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
    opts = opts or {}
    opts.border = opts.border or border
    return orig_util_open_floating_preview(contents, syntax, opts, ...)
  end

  local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
  for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
  end
  local protocol = require'vim.lsp.protocol'
  protocol.CompletionItemKind = {
    '', -- Text
    '', -- Method
    '', -- Function
    '', -- Constructor
    '', -- Field
    '', -- Variable
    '', -- Class
    'ﰮ', -- Interface
    '', -- Module
    '', -- Property
    '', -- Unit
    '', -- Value
    '', -- Enum
    '', -- Keyword
    '﬌', -- Snippet
    '', -- Color
    '', -- File
    '', -- Reference
    '', -- Folder
    '', -- EnumMember
    '', -- Constant
    '', -- Struct
    '', -- Event
    'ﬦ', -- Operator
    '', -- TypeParameter
  }

  vim.diagnostic.config({
    virtual_text = false,
    signs = true,
    underline = true,
    update_in_insert = false,
    severity_sort = false,
  })

  setup_sumneko()

end

return M
