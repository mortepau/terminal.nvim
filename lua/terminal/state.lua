local config = require('terminal.config')
local error_wrapper = require('terminal.util.error').error_wrapper
local debug_wrapper = require('terminal.util.error').debug_wrapper
local table_util = require('terminal.util.table')

local M = {}

local _state = {
  terminals = {},
  last = nil,
}

local function debug(msg)
  if config.get('debug') then
    debug_wrapper(msg)
  end
end

local function validate_terminal(terminal)
  assert(type(terminal) == 'table', error_wrapper('Terminal is not a table'))
  assert(type(terminal.name) == 'string', error_wrapper('Terminal is missing field: name'))
  assert(type(terminal.cmd) == 'string', error_wrapper('Terminal is missing field: cmd'))
  assert(type(terminal.cmd_init) == 'string', error_wrapper('Terminal is missing field: cmd_init'))
  assert(type(terminal.position) == 'string', error_wrapper('Terminal is missing field: position'))
  assert(type(terminal.position_init) == 'string', error_wrapper('Terminal is missing field: position_init'))
  assert(type(terminal.cwd) == 'string', error_wrapper('Terminal is missing field: cwd'))
  assert(type(terminal.id) == 'number', error_wrapper('Terminal is missing field: id'))
  assert(type(terminal.buf_name) == 'string', error_wrapper('Terminal is missing field: bufname'))
  assert(type(terminal.alive) == 'boolean', error_wrapper('Terminal is missing field: alive'))
  assert(type(terminal.bufnr) == 'number', error_wrapper('Terminal is missing field: bufnr'))
  assert(type(terminal.win_id) == 'number', error_wrapper('Terminal is missing field: win_id'))
  assert(type(terminal.tabpage) == 'number', error_wrapper('Terminal is missing field: tabpage'))

  return true
end

function M.insert_terminal(terminal)
  if validate_terminal(terminal) then
    _state.terminals[terminal.name] = terminal
  end
end

function M.get_terminal(name)
  if not name then return vim.tbl_values(_state.terminals) end

  return _state.terminals[name]
end

function M.get_terminal_from_key(key, value)
  for _, terminal in pairs(_state.terminals) do
    if terminal[key] == value then
      return terminal
    end
  end
end

function M.terminal_exist(name)
  -- Returns false if key not found, otherwise return true
  return not not _state.terminals[name]
end

function M.last_terminal()
  if _state.last then
    debug('Fetching the last used terminal, ' .. _state.last)
    return _state.terminals[_state.last]
  end
end

function M.default_terminal()
  debug('Fetching the default terminal')
  return _state.terminals[config.get('default_terminal').name]
end

function M.set_last_terminal(name)
  if table_util.in_table(name, vim.tbl_keys(_state.terminals)) then
    debug('Setting the last used terminal to ' .. name)
    _state.last = name
  end
end

return M
