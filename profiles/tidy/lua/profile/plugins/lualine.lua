local M = {}

M._local_settings = nil

M.config = function(local_settings)
  M._local_settings = local_settings
  return M
end

M.setup = function ()
  local split = function (inputstr, sep)
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
      table.insert(t, str)
    end
    return t
  end
  local function getWords()
    return tostring(vim.fn.wordcount().words)
  end
  local function getLightbulb()
    return require('nvim-lightbulb').get_status_text()
  end
  require('lualine').setup {
    options = {
      icons_enabled = true,
      theme = 'auto',
      component_separators = { left = '', right = ''},
      section_separators = { left = '', right = ''},
      disabled_filetypes = {'neo-tree', 'aerial'},
      always_divide_middle = true,
      globalstatus = true,
    },
    sections = {
      lualine_a = {'mode'},
      lualine_b = {'branch', 'diff', 'diagnostics'},
      --lualine_c = {'filename'},
      lualine_c = {'filename', {"aerial", depth=-1}, getLightbulb},
      lualine_x = {'filetype'},
      --lualine_x = {'fileformat', 'filetype'},
      --lualine_x = {'encoding', 'fileformat', 'filetype'},
      lualine_y = {},
      --lualine_y = {'progress'},
      lualine_z = {'location'}
      --lualine_z = {'location', getWords}
    },
    inactive_sections = {
      lualine_a = {},
      lualine_b = {},
      --lualine_c = {'filename', 'aerial'},
      lualine_x = {'location'},
      lualine_y = {},
      lualine_z = {}
    },
    extensions = {}
  }
end

return M
