local M = {}

M._local_settings = nil

M.config = function(local_settings)
  M._local_settings = local_settings
  return M
end

local setup_hlsearch = function()

  require('hlslens').setup({
    calm_down = true,
    nearest_only = true,
  })

  local kopts = {noremap = true, silent = true}

  vim.api.nvim_set_keymap('n', 'n',
  [[<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>]],
  kopts)
  vim.api.nvim_set_keymap('n', 'N',
  [[<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>]],
  kopts)
  vim.api.nvim_set_keymap('n', '*', [[*<Cmd>lua require('hlslens').start()<CR>]], kopts)
  vim.api.nvim_set_keymap('n', '#', [[#<Cmd>lua require('hlslens').start()<CR>]], kopts)
  vim.api.nvim_set_keymap('n', 'g*', [[g*<Cmd>lua require('hlslens').start()<CR>]], kopts)
  vim.api.nvim_set_keymap('n', 'g#', [[g#<Cmd>lua require('hlslens').start()<CR>]], kopts)

  vim.api.nvim_set_keymap('n', '<Leader>l', ':noh<CR>', kopts)

end

local setup_colorscheme = function()
	vim.cmd[[highlight Todo guibg=NONE]]
	vim.cmd('colorscheme gruvbox')
end

local get_plugins = function()
  return {
    {'AndrewRadev/bufferize.vim'},
    {'tpope/vim-surround'},
    {'tpope/vim-repeat'},
    {'vimwiki/vimwiki'},
    {'pierreglaser/folding-nvim'},
    {'preservim/nerdcommenter'},
    {'preservim/tagbar'},
    {'drewtempelmeyer/palenight.vim'},
    {'ayu-theme/ayu-vim'},
    {'morhetz/gruvbox', config=setup_colorscheme},
    {'arcticicestudio/nord-vim'},
    {'rakr/vim-one'},
    {'lifepillar/vim-solarized8'},
    {'relastle/bluewery.vim'},
    {'ElPiloto/oceanic-next'},
    {'ElPiloto/sidekick.nvim'},
    {'bluz71/vim-nightfly-guicolors'},
    {'challenger-deep-theme/vim'},
    {'farmergreg/vim-lastplace'},
    {'rcarriga/nvim-notify', config=function() vim.notify = require('notify') end },
    {'petertriho/nvim-scrollbar', config=function() require('scrollbar').setup() end},
    {'kevinhwang91/nvim-hlslens', config=setup_hlsearch},
    {'AndrewRadev/splitjoin.vim'},
    {'kevinhwang91/nvim-bqf', ft='qf'},
    { 'jinh0/eyeliner.nvim', config = function() require'eyeliner'.setup { highlight_on_key = true } end },
    {'vim-scripts/ReplaceWithRegister'},
    {'vim-scripts/ReplaceWithSameIndentRegister'},
    {
      'stevearc/overseer.nvim',
      config = function() require('overseer').setup() end
    },
  }
end

M.setup = function()
  local plugins = get_plugins()
  local aerial_profile = require('profile.plugins.aerial').config(M._local_settings)
  local alpha_profile = require('profile.plugins.alpha').config(M._local_settings)
  local dap_profile = require('profile.plugins.dap').config(M._local_settings)
  local lightbulb_profile = require('profile.plugins.lightbulb').config(M._local_settings)
  local lsp_signature_profile = require('profile.plugins.lsp_signature').config(M._local_settings)
  local lualine_profile = require('profile.plugins.lualine').config(M._local_settings)
  local neotree_profile = require('profile.plugins.neotree').config(M._local_settings)
  local tabline_profile = require('profile.plugins.tabline').config(M._local_settings)
  local treesitter_profile = require('profile.plugins.treesitter').config(M._local_settings)
  local whichkey_profile = require('profile.plugins.whichkey').config(M._local_settings)

  local packer = require('packer')

  require'packer.luarocks'.install_commands()

  --packer.use_rocks {'penlight', version = '1.13.1-1'}
  --packer.use_rocks 'lua-xmlreader'

  --packer.reset()
  local use = packer.use
  --return require('packer').startup(function(use) LRP_EDIT_SEPT3
    use 'wbthomason/packer.nvim'

    use(plugins)
    use {"folke/which-key.nvim", config=whichkey_profile.setup}
    use {'kosayoda/nvim-lightbulb', config=lightbulb_profile.setup}

    use {'lukas-reineke/virt-column.nvim',
      config = function()
        require'virt-column'.setup()
      end
    }

    use {"akinsho/toggleterm.nvim", tag = 'v2.*',
      config = function()
        require("toggleterm").setup()
      end
    }

    use {'kyazdani42/nvim-web-devicons',
    config = function()
    require'nvim-web-devicons'.setup{
      override = {
        BUILD = {
          icon = "",
          color = "#70675D",
          cterm_color = "65",
          name = "BUILD"
        },
        OWNERS = {
          icon = "",
          color = "#70675D",
          cterm_color = "65",
          name = "OWNERS"
        },
        ipynb = {
          icon = "ﴬ",
          color = "#D99B0F",
          cterm_color = "65",
          name = "ipynb"
        },
        METADATA = {
          icon = "",
          color = "#70675D",
          cterm_color = "65",
          name = "METADATA"
        },
        OWNERS_METADATA = {
          icon = "",
          color = "#70675D",
          cterm_color = "65",
          name = "OWNERS_METADATA"
        },
        blueprint = {
          icon = "",
          color = "#4C79C2",
          cterm_color = "65",
          name = "blueprint"
        }
      },
    }
    end}

  -- Lua
  use {
    "folke/trouble.nvim",
    requires = "kyazdani42/nvim-web-devicons",
    config = function()
      require("trouble").setup {
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
      }
    end
  }
  use { 'nvim-telescope/telescope.nvim', requires = { 'nvim-lua/plenary.nvim' } }
  use {'nvim-telescope/telescope-project.nvim',
    config=function() require('telescope').load_extension('project') end,
    after='telescope.nvim',
  }
  use {'nvim-telescope/telescope-ui-select.nvim',
    config=function() require('telescope').load_extension('ui-select') end,
    after='telescope.nvim',
  }

  neotree_profile.setup(use)
  dap_profile.setup(use)

  use 'hrsh7th/nvim-cmp'
  use 'hrsh7th/cmp-path'
  use 'hrsh7th/cmp-nvim-lsp'
  --use 'hrsh7th/vim-vsnip'   --  nvim-cmp requires a snippet plugin, see docs
  use 'saadparwaiz1/cmp_luasnip'
  use 'L3MON4D3/LuaSnip' -- Snippets plugin


  use {'nvim-treesitter/nvim-treesitter', config=treesitter_profile.setup}
  use {'nvim-treesitter/nvim-treesitter-textobjects'}
  -- Additional textobjects for treesitter
  use 'neovim/nvim-lspconfig'
  use {
    'williamboman/mason.nvim',
    config = function()
      require("mason").setup()
    end
  }
  use {
    'williamboman/mason-lspconfig.nvim',
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "sumneko_lua", "pyright" }
      })
    end
  }

  use 'jose-elias-alvarez/null-ls.nvim'
  use {'stevearc/aerial.nvim', config=aerial_profile.setup}

  use { "lifer0se/ezbookmarks.nvim", config = function ()
    require('ezbookmarks').setup{
      cwd_on_open = 1,        -- change directory when opening a bookmark
      use_bookmark_dir = 1,   -- if a bookmark is part of a bookmarked directory, cd to that direcrtory (works independently of cwd_on_open)
      open_new_tab = 1,       -- open bookmark in a new tab.
    } end
  }

  use { 'goolord/alpha-nvim',
    requires = {'BlakeJC94/alpha-nvim-fortune'},
    --config = function () require'alpha'.setup(require'alpha.themes.dashboard'.config) end
    config = alpha_profile.setup,
  }

  use({ 'weilbith/nvim-code-action-menu', cmd = 'CodeActionMenu', })
  --could disable these eventually
  vim.g.code_action_menu_show_details = true
  vim.g.code_action_menu_show_diff = true

  use {
    'kdheepak/tabline.nvim', config=tabline_profile.setup
  }
  --lualine
  use {
    'nvim-lualine/lualine.nvim',
    requires = { 'kyazdani42/nvim-web-devicons', opt = true },
    config=lualine_profile.setup,
    after = {'nvim-web-devicons', 'aerial.nvim'}
  }
  use {'marko-cerovac/material.nvim'}
  use {'glepnir/oceanic-material'}
  use { "ray-x/lsp_signature.nvim", config=lsp_signature_profile.setup}
  use {'rafamadriz/friendly-snippets'}
  use {'dstein64/vim-startuptime'}

  --If packer's global isn't loaded, good indication that we've started a fresh config.
  if not packer_plugins then
    print('Auto-syncing packer...')
    require('packer').sync()
  end
  --use {'henriquehbr/nvim-startup.lua'}
  --require('nvim-startup').setup()
end

return M
