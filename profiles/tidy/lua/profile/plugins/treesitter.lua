local M = {}

M._local_settings = nil

M.config = function(local_settings)
  M._local_settings = local_settings
  return M
end

M.setup = function ()
  require "nvim-treesitter.configs".setup {
    ensure_installed = { "lua", "python"},
    auto_install = true,
    indent = {
      disable = { "python" },
    },
    highlight = {
      enable = true,
    }
  }
  local ft_to_parser = require"nvim-treesitter.parsers".filetype_to_parsername
  ft_to_parser.vimwiki = "markdown" -- vimwiki takes over markdown files which is usually helpful, but here we need to undo that
end


return M
