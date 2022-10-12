local M = {}

M._local_settings = nil

M.config = function(local_settings)
  M._local_settings = local_settings
  return M
end

local function setup_nvim_dap()
  local dap = require('dap')
  vim.fn.sign_define('DapBreakpoint', {text='🔴', texthl='', linehl='', numhl=''});
  vim.fn.sign_define('DapStopped', {text='⮕', texthl='', linehl='', numhl=''});
  --TODO(ElPiloto): Make this setup conditional on settings to determine whether we launch or connect to listening server.
  dap.adapters.python = {
     type = 'executable';
     --This will pick up either default python or virtualenv python.
     command = '/Users/lpiloto/.pyenv/shims/python';
     args = { '-m', 'debugpy.adapter' };
  }
  dap.configurations.python = {
    {
      type = 'python'; -- the type here established the link to the adapter definition: `dap.adapters.python`
      request = 'launch';
      name = "Launch file";
      program = '${file}',
      justMyCode = false,
    }
  }
  vim.keymap.set('n', "<Leader><Enter>", function () require'dap'.continue() end, {desc="Launch debugger"})
  vim.keymap.set('n', "<C-n>", function () require'dap'.step_over() end, {desc="Next line (debugger)"})
  vim.keymap.set('n', "<C-s>", function () require'dap'.step_into() end, {desc="Step into (debugger)"})
  vim.keymap.set('n', "<BS>", function () require'dap'.step_out() end, {desc="Step out (debugger)"})
  vim.keymap.set('n', "<C-p>", function () require'dap'.toggle_breakpoint() end, {desc="Breakpoint (debugger)"})
  --nnoremap <silent> <Leader>B <Cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>
  --nnoremap <silent> <Leader>lp <Cmd>lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<CR>
  --nnoremap <silent> <Leader>dr <Cmd>lua require'dap'.repl.open()<CR>
  --nnoremap <silent> <Leader>dl <Cmd>lua require'dap'.run_last()<CR>
end

local function setup_nvim_dap_ui()
  local dap, dapui = require("dap"), require("dapui")
  dapui.setup({
      icons = { expanded = "▾", collapsed = "▸", current_frame = "▸" },
      mappings = {
        -- Use a table to apply multiple mappings
        expand = { "<CR>", "<2-LeftMouse>" },
        open = "o",
        remove = "d",
        edit = "e",
        repl = "r",
        toggle = "t",
      },
      -- Expand lines larger than the window
      -- Requires >= 0.7
      expand_lines = vim.fn.has("nvim-0.7") == 1,
      -- Layouts define sections of the screen to place windows.
      -- The position can be "left", "right", "top" or "bottom".
      -- The size specifies the height/width depending on position. It can be an Int
      -- or a Float. Integer specifies height/width directly (i.e. 20 lines/columns) while
      -- Float value specifies percentage (i.e. 0.3 - 30% of available lines/columns)
      -- Elements are the elements shown in the layout (in order).
      -- Layouts are opened in order so that earlier layouts take priority in window sizing.
      layouts = {
        {
          elements = {
          -- Elements can be strings or table with id and size keys.
            { id = "scopes", size = 0.25 },
            "breakpoints",
            "stacks",
            "watches",
          },
          size = 40, -- 40 columns
          position = "left",
        },
        {
          elements = {
            "repl",
          },
          size = 0.25, -- 25% of total lines
          position = "bottom",
        },
      },
      controls = {
        -- Requires Neovim nightly (or 0.8 when released)
        enabled = true,
        -- Display controls in this element
        element = "repl",
        icons = {
          pause = "",
          play = "",
          step_into = "",
          step_over = "",
          step_out = "",
          step_back = "",
          run_last = "↻",
          terminate = "□",
        },
      },
      floating = {
        max_height = nil, -- These can be integers or a float between 0 and 1.
        max_width = nil, -- Floats will be treated as percentage of your screen.
        border = "single", -- Border style. Can be "single", "double" or "rounded"
        mappings = {
          close = { "q", "<Esc>" },
        },
      },
      windows = { indent = 1 },
      render = {
        max_type_length = nil, -- Can be integer or nil.
        max_value_lines = 100, -- Can be integer or nil.
      }
    })
  dap.listeners.after.event_initialized["dapui_config"] = function()
    dapui.open()
  end
  dap.listeners.before.event_terminated["dapui_config"] = function()
    dapui.close()
  end
  dap.listeners.before.event_exited["dapui_config"] = function()
    dapui.close()
  end
end

M.setup = function (use)

  use {'mfussenegger/nvim-dap', config=setup_nvim_dap}
  use {
    'rcarriga/nvim-dap-ui',
    requires={'mfussenegger/nvim-dap'},
    config=setup_nvim_dap_ui,
  }

end

return M
