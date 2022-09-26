--[[ This is a configuration that loads diffrent config profiles:
--  init.lua: Loads based on ~/.nvim/config/profiles/$PROFILE_NAME/init.lua
--  packer.nvim: Changes all locations for packer.
--]]

-- Bootstrap packer to shared location.
local fn = vim.fn
local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  packer_bootstrap = fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
  vim.cmd [[packadd packer.nvim]]
end


-- Setup profile
local profile_utils = require('profile_utils')
local profile_name = "tidy"

profile_utils.load_profile(profile_name)


