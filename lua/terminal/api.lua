local io = require('terminal.io')
local config = require('terminal.config')
local state = require('terminal.state')
local terminal_factory = require('terminal.internal')

local M = {}

function M.execute(args)
  -- Parse the arguments and get the table with parsed values
  local args_table = io.parse_args('execute', args)

  local terminal = nil
  local params_changed = false

  -- If a name is provided find it or create a new one
  if args_table.name ~= '' then
    if state.terminal_exist(args_table.name) then
      terminal = state.get_terminal(args_table.name)

      -- Transfer the new arguments
      for key, value in pairs(args_table) do
        if value ~= '' then
          terminal[key] = value
          params_changed = true
        end
      end
    else
      local reserve_terminal = state.last_terminal() or state.default_terminal()
      for key, value in pairs(args_table) do
        if value == '' then
          args_table[key] = reserve_terminal[key]
        end
      end
      terminal = terminal_factory:new(args_table)
    end
  else
    -- Fetch a copy of the last or default terminal so we don't change its values
    terminal = vim.deepcopy(state.last_terminal() or state.default_terminal())

    for key, value in pairs(args_table) do
      if value ~= '' then
        terminal[key] = value
        params_changed = true
      end
    end
  end

  state.insert_terminal(terminal)

  if terminal.alive then
    vim.api.nvim_set_current_win(terminal.win_id)
    vim.api.nvim_set_current_buf(terminal.bufnr)
  else
    terminal:open_window()
    terminal:open_terminal()
  end

  state.set_last_terminal(terminal.name)
end

function M.open(args)
  local args_table = io.parse_args('open', args)
  print(vim.inspect(args_table))
end

function M.close(args)
  local args_table = io.parse_args('close', args)
  print(vim.inspect(args_table))
end

function M.move(args)
  local args_table = io.parse_args('move', args)
  print(vim.inspect(args_table))
end

function M.echo(args)
  local args_table = io.parse_args('echo', args)
  print(vim.inspect(args_table))
end

function M.list(list_all)
  local format = config.get('list_format')
  local keys = {
    'name',
    'buf_name',
    'cwd',
    'cmd',
    'cmd_init',
    'position',
    'position_init',
    'id',
    'bufnr',
    'win_id',
    'tabpage',
  }

  local default_terminal = state.default_terminal()
  local last_terminal = state.last_terminal() or default_terminal

  local lines = {}
  for _, terminal in pairs(state.get_terminal()) do
    local template = format
    for _, key in ipairs(keys) do
      template = template:gsub('{' .. key .. '}', tostring(terminal[key]))
    end

    template = template:gsub('{default}', default_terminal.name == terminal.name and 'D' or ' ')
    template = template:gsub('{last}', last_terminal.name == terminal.name and '*' or ' ')
    template = template:gsub('{alive}', terminal.alive and 'A' or ' ')

    if terminal.alive or list_all then
      table.insert(lines, template)
    end
  end

  print(table.concat(lines, '\n'))
end

return M
