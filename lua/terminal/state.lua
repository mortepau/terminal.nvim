local error_func = require('terminal.error')
local util = require('terminal.util')
local State = {}

local _prototype = {}

_prototype.template = {
    name = '',
    cwd = '',
    id = -1,
    bufname = '',
    cmd = {
      initial = '',
      current = '',
    },
    position = {
      initial = '',
      current = '',
    },
    location = {
      buf = -1,
      win = -1,
      tab = -1,
    },
    alive = false,
}

POSITIONS = { 'top', 'bot', 'left', 'right' }

function State.new(name, cwd, position, cmd)
  assert(type(name) == 'string' and #name > 0, error_func.error_wrapper('Invalid terminal name, expected a non-zero length string not a ' .. type(cwd)))
  assert(util.type_or_nil(cwd, 'string'), error_func.error_wrapper('Invalid current working directory, expected a string not a ' .. type(cwd)))
  assert(util.type_or_nil(cmd, 'string'), error_func.error_wrapper('Invalid cmd, expected a string not a ' .. type(cmd)))
  assert(util.type_or_nil(position, 'string'), error_func.error_wrapper('Invalid position, expected a string not a ' .. type(position)))
  if type(position) == 'string' then
    assert(util.in_list(position, POSITIONS), error_func.error_wrapper('Invalid position name, expected one of ' .. util.stringify(POSITIONS) .. ' not ' .. tostring(position)))
  end

  local state = _prototype.template

  state.name = name
  state.cwd = cwd
  state.position.initial = position
  state.cmd.initial = cmd


  return state
end

return State
