local config = require('terminal.config')
local error_wrapper = require('terminal.util.error').error_wrapper
local in_table = require('terminal.util.table').in_table

local M = {}

local method_params = {
  execute = { 'name', 'position', 'cwd', 'cmd' },
  open    = { 'name',                    'cmd' },
  close   = { 'name'                           },
  move    = { 'name', 'position'               },
  echo    = { 'name',                    'cmd' },
}

local cli_switch_to_keyword = {
  ['-n']         = 'name',
  ['--name']     = 'name',
  ['-p']         = 'position',
  ['--position'] = 'position',
  ['-c']         = 'cwd',
  ['--cwd']      = 'cwd',
}
local equal_switch_to_keyword = {
  -- Equal style
  ['n']        = 'name',
  ['name']     = 'name',
  ['p']        = 'position',
  ['position'] = 'position',
  ['c']        = 'cwd',
  ['cwd']      = 'cwd',
}

local function insert(table, key, value)
  if key == 'cmd' then
    table[key] = (table[key] or '') .. value .. ' '
  else
    assert(table[key] == nil, error_wrapper('Expected only one argument for keyword ' .. key))
    table[key] = value
  end
end

local function parse_cli_style(token_generator)
  local switch_pattern_long = '^%-%-%w+$'
  local switch_pattern_short = '^%-%w$'

  local kwargs = {}

  while true do
    local token = token_generator()
    if token == nil then break end

    local switch = token:match(switch_pattern_long) or token:match(switch_pattern_short)
    local keyword = cli_switch_to_keyword[switch] or 'cmd'

    if keyword ~= 'cmd' then
      insert(kwargs, keyword, token_generator())
    else
      insert(kwargs, 'cmd', token)
      for word in token_generator do
        insert(kwargs, 'cmd', word)
      end
      -- Remove trailing whitespace
      kwargs['cmd'] = string.sub(kwargs['cmd'], 1, #kwargs['cmd'] - 1)
    end
  end

  return kwargs
end

local function parse_equal_style(token_generator)
  local switch_pattern_long = '^(%w+)=.+$'
  local switch_pattern_short = '^(%w)=.+$'

  local kwargs = {}

  while true do
    local token = token_generator()
    if token == nil then break end

    local switch = token:match(switch_pattern_long) or token:match(switch_pattern_short)
    local keyword = equal_switch_to_keyword[switch] or 'cmd'

    if keyword ~= 'cmd' then
      insert(kwargs, keyword, token:match('^[^=]+=(.*)$'))
    else
      insert(kwargs, 'cmd', token)
      for word in token_generator do
        insert(kwargs, 'cmd', word)
      end
      -- Remove trailing whitespace
      kwargs['cmd'] = string.sub(kwargs['cmd'], 1, #kwargs['cmd'] - 1)
    end
  end

  return kwargs
end

function M.parse_args(method, argv)
  local parsed_args = {}

  argv = argv or ''

  -- Split the string into words
  local producer = argv:gmatch('%S+')

  if config.get('use_cli_style_input') then
    parsed_args = parse_cli_style(producer)
  else
    parsed_args = parse_equal_style(producer)
  end

  -- Insert empty strings in the unused params
  for _, valid_param in pairs(method_params[method]) do
    parsed_args[valid_param] = parsed_args[valid_param] or ''
  end

  -- Check that only valid keywords are present
  for keyword, _ in pairs(parsed_args) do
    assert(in_table(keyword, method_params[method]), error_wrapper('Unexpected keyword: ' .. keyword))
  end

  return parsed_args
end

return M
