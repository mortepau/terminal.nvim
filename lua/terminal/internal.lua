local state = require('terminal.state')
local table_util = require('terminal.util.table')
local M = {}

M._positions = {
  'current',
  'tab',
  'float',
  'above',
  'below',
  'top',
  'bot',
  'right',
  'left',
  'rhs',
  'lhs',
}

M._terminals = {}

function M.find_terminal(name)
  for _, terminal in ipairs(M._terminals) do
    if terminal.name == name then
      return terminal
    end
  end
  return
end

function M.insert_terminal(terminal)
  local valid = state.validate_terminal(terminal)

  if valid then
    table.insert(M._terminals, terminal)
  end
end

function M.is_position(position)
  return table_util.in_table(position, M._positions)
end

return M
