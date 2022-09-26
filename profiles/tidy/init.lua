---@diagnostic disable-next-line: undefined-global
--local vim = vim

--BEWARE: Loads things into global namespace.
require 'profile.globals'

local profile_settings = {
  disable_null_ls = true,
  debug_lsp = true,
}


local vim_options = function()
  --Needed so jj works.
  vim.o.timeoutlen = 300
  vim.o.termguicolors = true
  vim.wo.number = true
  vim.o.mouse = 'a'
  vim.opt.undofile = true
  vim.wo.signcolumn = 'yes'
end

--Generic plugins without any special config

local setup_keybindings = function()
  --vim.keymap.del('n', '<Space>')
  vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
  vim.g.mapleader = ' '
  vim.g.maplocalleader = ' '
  vim.keymap.set('i', 'jj', '<Esc>')
  -- smooth scrolling
  vim.keymap.set('n', 'j', "jzz")
  vim.keymap.set('n', "k", "kzz")
  vim.keymap.set('n', "{", "{zz")
  vim.keymap.set('n', "}", "}zz")
  vim.keymap.set('n', "<C-j>", "<PageDown>zz")
  vim.keymap.set('n', "<C-k>", "<PageUp>zz")
  vim.keymap.set('n', "n", "nzz")
  vim.keymap.set('n', "N", "Nzz")
  vim.opt.clipboard = ''

  vim.keymap.set('n', "<F10>", '<cmd>:echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . "> trans<" . synIDattr(synID(line("."),col("."),0),"name") . "> lo<" . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>')

  vim.keymap.set('n',
                 '<leader>pt',
                 '<cmd>lua require("telescope.builtin").find_files({search_dirs = {require("profile_utils").get_profile_root_dir()}})<CR>'
                 )

  -- Commenting
  vim.keymap.set('n', "<leader>c<space>", ":CommentToggle<cr>")
  vim.keymap.set('v', "<leader>c<space>", ":CommentToggle<cr>")
  --Plugins
  --Open NERDTree
  vim.keymap.set('n', "<C-f>", ":silent! Neotree toggle<cr>")
  --Open fig
  vim.keymap.set('n', "<C-g>", ":silent! Neotree fig action=show<cr>")
  --vim.keymap.set('n', "<C-f>", ":NvimTreeToggle<cr>")
  --vim.keymap.set('n', "<C-f>", ":NERDTreeToggle<cr>")
  vim.keymap.set('n', "<F8>", ":AerialToggle<cr>")
  --Vimwiki
  vim.keymap.set('n', "<leader>wh", ":Vimwiki2HTMLBrowse<cr>")
  --LSP Tweaks
  --This makes it so that we can hit tabe to close diagnostic pop-ups.
---@diagnostic disable-next-line: unused-local
  local str_close_popup = '{"CursorMoved", "CursorMovedI", "BufHidden", "InsertCharPre", "WinLeave"}'
  vim.keymap.set('n', "<TAB>", "<cmd>lua vim.diagnostic.open_float()<CR>") --show_line_diagnostics({border=lvim.lsp.popup_border, close_events=" .. str_close_popup .. "})<CR>")
  --vim.keymap.set('n', "<TAB>", ":lua vim.lsp.diagnostic.show_line_diagnostics({border=lvim.lsp.popup_border, close_events=" .. str_close_popup .. "})<CR>")
  --vim.keymap.set('n', "<leader>j", ":silent lua vim.diagnostic.goto_next({popup_opts={border=lvim.lsp.popup_border, close_events=" .. str_close_popup .. "}})<cr>zz")
  --vim.keymap.set('n', "<leader>k", ":silent lua vim.diagnostic.goto_prev({popup_opts={border=lvim.lsp.popup_border, close_events=" .. str_close_popup .. "}})<cr>zz")
  vim.keymap.set('n', "<leader>d", ":silent lua vim.lsp.buf.definition()<cr>")
  vim.keymap.set('n', "<leader>D", ":silent lua vim.lsp.buf.declaration()<cr>")
  --vim.keymap.set('n', "leader':silent lua require"ezbookmarks".OpenBookmark()<cr>') 
end


local setup_null_ls = function ()
  if not is_loaded('null-ls.nvim') then
    print('Aborting setup of null-ls...')
    return
  end

  local null_ls = require("null-ls")
  local h = require("null-ls.helpers")
  local methods = require("null-ls.methods")

  local DIAGNOSTICS = methods.internal.DIAGNOSTICS

  --Here we basically copy the pylint built-in diagnostic source and replace it with some gpylint specific things.
  local gpylint = h.make_builtin({
      name = "gpylint",
      meta = {
          url = "https://github.com/PyCQA/pylint",
          description = "Pylint is a Python static code analysis tool which looks for programming errors, helps enforcing a coding standard, sniffs for code smells and offers simple refactoring suggestions.",
      },
      method = DIAGNOSTICS,
      filetypes = { "python" },
      generator_opts = {
          command = "gpylint",
          to_stdin = false,
          args = { "$FILENAME", "-f", "json" },
          format = "json",
          check_exit_code = function(code)
              return code ~= 32
          end,
          on_output = h.diagnostics.from_json({
              attributes = {
                  row = "line",
                  col = "column",
                  code = "message-id",
                  severity = "type",
                  message = "message",
                  symbol = "symbol",
                  source = "gpylint",
              },
              severities = {
                  convention = h.diagnostics.severities["information"],
                  refactor = h.diagnostics.severities["information"],
              },
              offsets = {
                  col = 1,
              },
          }),
      },
      factory = h.generator_factory,
  })

  local sources = {
    gpylint,
  }
  local root_dir = require('null-ls.utils').root_pattern('BUILD')
  null_ls.setup({debug=false, root_dir=root_dir, default_timeout=0, sources = sources})

end

local validate = vim.validate

local function request(method, params, handler)
  validate({
    method = { method, 's' },
    handler = { handler, 'f', true },
  })
  print('requesting')
  return vim.lsp.buf_request(0, method, params, handler)
end

local function request_with_options(name, params, options)
  local req_handler
  print('Do we think we have a handler:?')
  local client = vim.lsp.get_client_by_id(1)
  print('Client ', client, name)
  VPrint(client.handlers[name])
  VPrint(client.resolved_capabilities)
  client.handlers[name]()
  local function custom_handler(_, result, ctx)
        VPrint("BINGO MOTHERFUCKER IN YOUR FACE.")
        VPrint(result)

  end
  if options then
    --VPrint('We got options baby')
    req_handler = function(err, result, ctx, config)
      local client = vim.lsp.get_client_by_id(1)
      --local client = vim.lsp.get_client_by_id(ctx.client_id)
      local handler = client.handlers[name] or vim.lsp.handlers[name]
      handler(err, result, ctx, vim.tbl_extend('force', config or {}, options))
    end
  --else
    --req_handler = function(err, result, ctx, config)
      --custom_handler(err, result, ctx, {}) --vim.tbl_extend('force', config or {}, {}))
    --end
  end
  request(name, params, req_handler)
end


local misc = function()
  --TODO: Need to check treesitter exists
  --Hide pylint lines
  vim.o.conceallevel=2
  --TODO(piloto): Add diagnostic message or gutter icon.
  --vim.cmd[[autocmd filetype python syntax region PyLint start="# pylint:" end="$" keepend conceal]]
  --vim.cmd('autocmd FileType *.py syntax region PyLint start="# pylint:" end="$" keepend conceal')
  --local group = vim.api.nvim_create_augroup("Concealer", {clear=true})
  --vim.api.nvim_create_autocmd("FileType", {command='syntax region PyLint start="# pylint:" end="$" keepend conceal', group=group, pattern="python"})
  vim.cmd[[autocmd filetype *.py.tmpl set syntax=python]]
  vim.cmd[[autocmd filetype python set colorcolumn=81]]
  vim.g.python_recommended_style = 0

  local set = vim.opt

  -- Set the behavior of tab
  set.tabstop = 2
  set.shiftwidth = 2
  set.softtabstop = 2
  set.expandtab = true
  set.fcs = 'eob: '  -- don't display tilde for end of buffer
  set.signcolumn = 'number'
  --set.signcolumn = 'auto'
  --vim.api.nvim_set_hl(0, 'SignColumn', {})

    --Made to match GruvBox, probably should manually update it if we're using
    --another colorscheme
  vim.cmd[[highlight VirtColumn ctermfg=12 gui=bold guifg=#7c6f64 guibg=#282828]]

  vim.cmd[[autocmd BufRead lsp.log set filetype=lsplog]]
end



local plugins = require('profile.plugins').config(profile_settings).setup()

vim_options()
misc()
setup_keybindings()
--This checks for plugins being loaded
require 'profile.completion'.config(profile_settings).setup()
if not profile_settings.disable_null_ls then
  setup_null_ls()
end
require 'profile.lsp'.config(profile_settings).setup()
vim.api.nvim_set_option('foldlevelstart', 99)
