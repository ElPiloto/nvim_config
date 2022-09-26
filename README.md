The neovim configuration of Luis Piloto.

# Overview

This setup is centered around the ideas of "profiles" to allow safe tinkering
with neovim config.  Our standard config `~/.config/nvim/init.lua` contains
code that will set the appropriate paths to load a config in
`~/.config/nvim/profiles/$PROFILE_NAME/init.lua`.


## Setup

Clone this into `~/.config/nvim/`. This setup relies on packer and modifies
some of packer's paths in order to allow switching between profiles.  If you
decide to use this config, then you _must_ ensure that everything is cleared
out of the default locations for packer plugins and packer's compiled file
`packer_compiled.lua`.  The reason is that packer's default behavior is to
place things where neovim can find them without any configuration.  That's
great if you have a single config.  However, if you try to switch "profiles"
but they're all located in places that get picked up by neovim anyways then
you'll just end up with an amalgamation of all your profiles which will be
chaos.  So make sure you clear out packer's directory and `packer_compiled.lua`
file before trying to setup this config.


## Profiles

Our "global" config has logic for switching around profiles to load profile-specific configs. In `~/.config/nvim/init.lua` you'll see the code below. To change to a new profile, all you have to do is change `profile_name`.

```
-- Setup profile
local profile_utils = require('profile_utils')
local profile_name = "messy"

profile_utils.load_profile(profile_name)
```

**NOTE:** Feel free to peek into `~/.config/nvim/lua/profile_utils.lua` and/or use it.


### File locations

When you call `profile_utils.load_profile(profile_name)`, the config will try to source an `init.lua` at: `~/.config/nvim/profiles/$PROFILE_NAME/`

This also sets information about:
* where to install packer plugins
* where to locate `packed_compiled.lua` a.k.a. the output of packer's `PackerCompile` command
* where neovim should look for plugins
* where neovim should source packer's `packer_compiled.lua` file from.

You can find where packer plugins get installed to via: `require('profile_utils').get_packer_paths['package_root']`.  At the time of writing this document, our strategy is to install packer plugins to a directory `.../site_profiles/$PROFILE_NAME/pack` as opposed to packer's default of `.../site/pack`.  The latter will always get sourced by neovim, whereas the former only gets sourced by neovim when we specifically add the profile's path to neovim's `packpath`.

### Commands

`:ProfileInit` - Vim command for editing the `init.lua` for the current profile.
