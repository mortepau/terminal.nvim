local util = require('terminal.util')
local in_table = require('terminal.util.table').in_table
local error_wrapper = require('terminal.util.error').error_wrapper

local M = {}

-- Table holding the valid keys and their expected type
M._config_tbl = {
  -- How to parse the input given to the commands
  -- true  -> --name <name> --position <position> --cwd <cwd> cmd
  -- false -> name=<name> position=<position> cwd=<cwd> cmd
  use_cli_style_input      = { 
    type  = 'boolean',
    value = false,
  },
  -- Function to provide a new terminal name given a name and the current
  -- working directory
  naming_scheme_handle     = {
    type  = 'function',
    value = function(name, cwd)
      M._counter = (M._counter or 0) + 1
      return 'term://' .. cwd .. '//' .. M._counter .. ':' .. name
    end,
  },
  -- If we should use a custom naming scheme or use the default one
  use_custom_naming_scheme = {
    type  = 'boolean',
    value = false,
  },
  -- If we should define all the commands or only Terminal
  define_all_commands      = {
    type  = 'boolean',
    value = true,
  },
  -- The default terminal if nothing is specified in the call
  default_terminal         = {
    type = 'table', 
    keys = {
      name     = 'string',
      cwd      = 'string',
      position = 'string',
      cmd      = 'string',
    },
    value = {
      name     = 'default',
      cwd      = vim.fn.getcwd(),
      position = 'current',
      cmd      = vim.fn.expand('$SHELL')
    },
  },
}

local function verify_type(new_value, expected)
  if type(new_value) == expected.type and expected.type == 'table' then
    for expected_key, expected_value in pairs(expected.keys) do
      if not util.type_or_nil(new_value[expected_key], expected_value) then
        return false
      end
    end
    return true
  end

  return type(value) == expected.type
end

-- Get a config value or error if using an invalid key
function M.get(key)
  if in_table(key, vim.tbl_keys(M._config_tbl)) then
    return M._config_tbl[key].value
  end
  error_wrapper('Invalid configuration option')
end

-- Set a config value if the config key is valid
function M.set(key, value)
  if in_table(key, vim.tbl_keys(M._config_tbl)) and verify_type(value, M._config_tbl[key]) then
    if type(value) == 'table' then
      for k, v in pairs(M._config_tbl[key].value) do
        M._config_tbl[key].value[k] = value[k] or v
      end
    else
      M._config_tbl[key].value = value
    end
  end
end

return M
