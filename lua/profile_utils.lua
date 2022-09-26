--[[Useful utilities for adding profiles to our neovim setup.
-- TODO:
--   * Add fn to copy a profile into a new name - will be very useful for testing.
--]]
local M = {}


local execute_cmd_sync = function(cmd, should_print)
  --Executes a command and tells you if there was an error.
  if should_print then
    print('Executing: ' .. cmd)
  end
  local result = vim.fn.systemlist(cmd)

  -- An empty result is ok
  if vim.v.shell_error ~= 0 or (#result > 0 and vim.startswith(result[1], "fatal:")) then
    return false, {}
  else
    return true, result
  end
end

M.get_profile_root_dir = function(profile_name)
  profile_name = profile_name or M.get_profile()
  return vim.fn.stdpath('config') .. '/profiles/' .. profile_name .. '/'
end

M.get_init_lua_fname = function(profile_name)
  return M.get_profile_root_dir(profile_name) .. 'init.lua'
end

M.get_profile_packpath = function(profile_name)
  return vim.fn.stdpath('data') .. '/site_profiles/' .. profile_name .. '/'
end

M.get_packer_paths = function(profile_name)
  return {
    snapshot_path = vim.fn.stdpath('cache') .. '/packer.nvim/profiles/' .. profile_name .. '/',
    package_root = M.get_profile_packpath(profile_name) .. 'pack/',
    compile_path = M.get_profile_root_dir(profile_name) .. '/plugin/packer_compiled.lua',
    display = { open_fn = require('packer.util').float, }
  }
end

M._set_profile = function(profile_name)
  M._profile = profile_name
  M._profile_set = true
end

M.get_profile = function()
  return M._profile or '__UNSPECIFIED__'
end



--Declaring this ahead of time to give access to maybe_delete.
--TODO(piloto): Figure out if there's a better way to do this besides moving to
--another file.
local run_delete_confirm_sequence


local pseudo_safe_delete = function(path)
  if path == '/' then
    print('Not deleting, path = "' .. path .. '"')
    return
  end
  vim.fn.delete(path)
end

--Returns a function that will delete the given path when it receives a yes
--input.
local maybe_delete = function(path, callback, callback_args)
  return function(choice)
    if choice == 'yes' then
      print('\nDeleting ' .. path  .. '...')
      pseudo_safe_delete(path)
      --TODO(piloto): Actually delete things.
    elseif choice == 'no' then
    else
      return
    end
    callback(callback_args)
  end

end

--This is a local function, but we just define it above.
run_delete_confirm_sequence = function(delete_calls) 
  if vim.tbl_isempty(delete_calls) then
    return
  end
  local delete_call_params = delete_calls[1]
  table.remove(delete_calls, 1)
  vim.ui.select(delete_call_params[1], delete_call_params[2], 
    maybe_delete(delete_call_params[3], run_delete_confirm_sequence, delete_calls)
    )
end

--Will remove everything from packer paths for a given profile:
-- * removes `packer_compiled.lua`
-- * removes installed packer plugins
M.clear_packer = function(profile_name)
  --TODO(piloto): Add dry run.
  local packer_paths = M.get_packer_paths(profile_name)
  local packer_compiled = packer_paths['compile_path']
  local packer_package_root = packer_paths['package_root']

  local delete_calls = nil
  --Check if they exist before deleting to warn user.
  if vim.loop.fs_stat(packer_compiled) then
    local msg = 'Found: ' .. packer_compiled .. 'Are you sure you want to delete?'
    local choices = {'yes', 'no', 'abort'}
    delete_calls = {{choices, {prompt = msg}, packer_compiled}}
  end

  if vim.loop.fs_stat(packer_package_root) then
    local msg = 'Found: ' .. packer_package_root .. 'Are you sure you want to delete?'
    local choices = {'yes', 'no', 'abort'}
    table.insert(delete_calls, {choices, {prompt = msg}, packer_package_root})
  end
  if delete_calls then
    run_delete_confirm_sequence(delete_calls)
  end
end


--Copies ~/.config/nvim/profiles/OLD to ...profiles/NEW using a naive system
--`cp -r`.  Not robust, but convenient for cloning configs.
M.copy_profile = function(old_profile_name, new_profile_name)
  --Simple naive copy for convenience.
  if not old_profile_name then
    old_profile_name = M.get_profile()
  end
  --TODO(piloto): Check if old profile exists?
  local old_init_path = M.get_profile_root_dir(old_profile_name)
  local new_init_path = M.get_profile_root_dir(new_profile_name)
  local cp_cmd = {'cp', '-r', old_init_path, new_init_path}
  local okay, _ = execute_cmd_sync(table.concat(cp_cmd, ' '), true)
  if not okay then
    print('Encounted unexpected error...you should probably clean that up.')
  end

end


M.add_vim_commands = function()
  local profile = M.get_profile()
  local init_lua = M.get_init_lua_fname(profile)
  local root_dir = M.get_profile_root_dir(profile)
  local plugin_dir = M.get_packer_paths(profile)['package_root']
  local edit_cmd_cmd = ':command! ProfileInit edit ' .. init_lua
  vim.cmd(edit_cmd_cmd)

  local root_cmd_cmd = ':command! ProfileRoot edit ' .. root_dir
  vim.cmd(root_cmd_cmd)

  local plugin_cmd_cmd = ':command! ProfilePlugins edit ' .. plugin_dir
  vim.cmd(plugin_cmd_cmd)

  local clear_packer_call = 'lua require("profile_utils").clear_packer("' .. profile .. '")'
  local clear_packer_cmd = ':command! ProfileClearPacker ' .. clear_packer_call
  vim.cmd(clear_packer_cmd)

  --TODO(piloto): Convert other commands to nvim_create_user_command
  vim.api.nvim_create_user_command(
      'ProfileCopy',
      function(args)
        if args.fargs and #args.fargs == 2 then
          M.copy_profile(args.fargs[1], args.fargs[2])
        else
          --TODO(piloto): Figure out why we can't use `nargs=2` below without getting an error.
          print('Invalid number of arguments to ProfileCopy')
        end
      end,
      {nargs = "*", desc="Copy OLD_PROFILE to NEW_PROFILE.", bang=true}
  )
end


---Split string into a table of strings using a separator.
---@param inputString string The string to split.
---@param sep string The separator to use.
---@return table table A table of strings.
M.split = function(inputString, sep)
  local fields = {}

  local pattern = string.format("([^%s]+)", sep)
  local _ = string.gsub(inputString, pattern, function(c)
    fields[#fields + 1] = c
  end)

  return fields
end

M.load_profile = function(profile_name)
  M._set_profile(profile_name)
  local init_lua = M.get_init_lua_fname(profile_name)
  local packer_paths = M.get_packer_paths(profile_name)
  --We need to tell vim we are putting packages somewhere else.  Normally
  --packer puts things in a place where vim already looks.
  vim.o.packpath = vim.o.packpath .. ',' .. M.get_profile_packpath(profile_name)
  if vim.fn.empty(vim.fn.glob(packer_paths['compile_path'])) == 0 then
    vim.cmd('luafile ' .. packer_paths['compile_path'])
  end

  --Redefine our commands to use current profile.
  M.add_vim_commands()

  --Set packer path before loading anything.
  --This means we cannot use packer.startup().
  local packer = require('packer')
  packer_paths.luarocks = {python_cmd='python3'}
  packer.init(packer_paths)
  packer.config.compile_path = packer_paths['compile_path']
  packer.reset()

  vim.o.rtp = M.get_profile_root_dir(profile_name) .. ',' .. vim.o.rtp

  --TODO(piloto): Add logging function that tells us what was sourced.
  vim.cmd(':source ' .. init_lua)

end

return M
