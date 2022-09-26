local M = {}

M._local_settings = nil

M.config = function(local_settings)
  M._local_settings = local_settings
  return M
end

M.setup = function ()

  require('which-key').setup {
    plugins = {
      marks = false, -- shows a list of your marks on ' and `
      registers = false, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
      spelling = {
        enabled = false, -- enabling this will show WhichKey when pressing z= to select spelling suggestions
        suggestions = 20, -- how many suggestions should be shown in the list?
      },
      -- the presets plugin, adds help for a bunch of default keybindings in Neovim
      -- No actual key bindings are created
      presets = {
        operators = true, -- adds help for operators like d, y, ... and registers them for motion / text object completion
        motions = true, -- adds help for motions
        text_objects = true, -- help for text objects triggered after entering an operator
        windows = true, -- default bindings on <c-w>
        nav = true, -- misc bindings to work with windows
        z = true, -- bindings for folds, spelling and others prefixed with z
        g = true, -- bindings for prefixed with g
      },
    },
    -- add operators that will trigger motion and text object completion
    -- to enable all native operators, set the preset / operators plugin above
    operators = { gc = "Comments" },
    key_labels = {
      -- override the label used to display some keys. It doesn't effect WK in any other way.
      -- For example:
      -- ["<space>"] = "SPC",
      -- ["<cr>"] = "RET",
      -- ["<tab>"] = "TAB",
    },
    icons = {
      breadcrumb = "»", -- symbol used in the command line area that shows your active key combo
      separator = "➜", -- symbol used between a key and it's label
      group = "+", -- symbol prepended to a group
    },
    popup_mappings = {
      scroll_down = '<c-d>', -- binding to scroll down inside the popup
      scroll_up = '<c-u>', -- binding to scroll up inside the popup
    },
    window = {
      border = "single", -- none, single, double, shadow
      position = "bottom", -- bottom, top
      margin = { 1, 0, 1, 0 }, -- extra window margin [top, right, bottom, left]
      padding = { 2, 2, 2, 2 }, -- extra window padding [top, right, bottom, left]
      winblend = 0
    },
    layout = {
      height = { min = 4, max = 25 }, -- min and max height of the columns
      width = { min = 20, max = 50 }, -- min and max width of the columns
      spacing = 3, -- spacing between columns
      align = "left", -- align columns left, center or right
    },
    ignore_missing = false, -- enable this to hide mappings for which you didn't specify a label
    hidden = { "<silent>", "<cmd>", "<Cmd>", "<CR>", "call", "lua", "^:", "^ "}, -- hide mapping boilerplate
    show_help = true, -- show help message on the command line when the popup is visible
    triggers = "auto", -- automatically setup triggers
    -- triggers = {"<leader>"} -- or specify a list manually
    triggers_blacklist = {
      -- list of mode / prefixes that should never be hooked by WhichKey
      -- this is mostly relevant for key maps that start with a native binding
      -- most people should not need to change this
      i = { "j", "k" },
      v = { "j", "k" },
    },
  }
  local wk = require('which-key')
  local mappings = {}
  --Telescope
  mappings["t"] = {
    name = "Telescope",
     t = { "<cmd>Telescope<cr>", "telescope" },
     m = {
       ':lua require("telescope.builtin").find_files { find_command={"hg", "status", "--rev=p4base", "-n"}, shorten_path=true}<CR>',
       'Modified Files'
     },
     g = { "<cmd>Telescope live_grep<cr>", "live grep" },
     f = { "<cmd>Telescope find_files shorten_path=true<cr>", "find files" },
  }
  --LSP
  mappings["l"] = {
    name="LSP",
    R = { ":lua vim.lsp.buf.references()<cr>", "References"},
    k = { ":lua vim.lsp.buf.hover()<cr>", "Hover"}
  }
  mappings["v"] = {
    name="vimrc",
    e = {":e ~/.config/nvim/init.lua<cr>", "Edit"},
    v = {":vsp ~/.config/nvim/init.lua<cr>", "Vertical Split"},
    t = {":tabnew ~/.config/nvim/init.lua<cr>", "Edit Tab"}
  }
  mappings["{"] = {"<cmd>AerialPrev<cr>", "Prev Aerial"}
  mappings["}"] = {"<cmd>AerialNext<cr>", "Next Aerial"}
  mappings["<space>"] = {"<C-^>", "Prev Buffer"}
  mappings["k"] = {"<cmd>lua vim.diagnostic.goto_prev()<cr>", "Prev Diagnostic"}
  mappings["j"] = {"<cmd>lua vim.diagnostic.goto_next()<cr>", "Next Diagnostic"}
  mappings["a"] = {"<cmd>CodeActionMenu<cr>", "Code Action"}
  mappings[";"] = {"<cmd>Alpha<CR>", "Dashboard"}
  mappings["f"] = { "<cmd>Telescope find_files<cr>", "find files" }
  mappings["B"] = {
    name = "EZBookmarks",
    o = {":lua require'ezbookmarks'.OpenBookmark()<cr>", "Open Bookmarks"},
    a = {":lua require'ezbookmarks'.AddBookmarkDirectory()<cr>", "Add Directory"},
    d = {":lua require'ezbookmarks'.AddBookmark()<cr>", "Add File"},
  }
  wk.register(mappings, {prefix = "<leader>"})
end

return M
