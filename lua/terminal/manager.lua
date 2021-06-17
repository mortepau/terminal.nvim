local Terminal = require('terminal.terminal')
local util = require('terminal.util')

---@class TerminalManager @Holds existing terminal instances
---@type table<string, Terminal>
__TerminalManager = __TerminalManager or {}

---@class TerminalManagerWrapper @Wrapper for the TerminalManager
local M = {}


---Fetch an existing terminal instance or create a new one
---@param name string|nil @Name of the Terminal to fetch
---@param create boolean @Create a terminal if none is found
---@return Terminal|nil
function M.get(name, create)
  if not name or name == '' then return M.get_last() end
  -- if not create then return __TerminalManager[name] end

  if not __TerminalManager[name] then
    util.debug('Creating terminal "%s"', name)
    local terminal = Terminal.new(name)
    __TerminalManager[terminal.params.name] = terminal
    name = terminal.params.name
  end
  return __TerminalManager[name]
end


---Insert a Terminal instance and manage it
---@param terminal Terminal @The terminal to insert
function M.insert(terminal)
  if util.type(terminal) == 'terminal' then
    __TerminalManager[terminal.params.name] = terminal
  else
    util.error('Invalid value for "terminal": %s', vim.inspect(terminal))
  end
end

---Get the last used terminal if defined, error if undefined
---@return Terminal @The last used terminal
function M.get_last()
  for _, terminal in pairs(__TerminalManager) do
    if terminal.last then
      return terminal
    end
  end
  util.fatal('An error occured, no last used terminal defined')
end


---Set the last used terminal, error if terminal is invalid
---@param name string @The terminal to set as last used
function M.set_last(name)
  if not __TerminalManager[name] then
    util.error('Invalid name: "%s". No Terminal with this name is defined', name)
    return
  end
  for _, terminal in pairs(__TerminalManager) do
    if terminal.last then
      terminal.last = false
    end
  end
  __TerminalManager[name].last = true
end


---Called by the autocmd, update the last used terminal
function M.update_last()
  local buf = vim.api.nvim_buf_get_number(0)
  if vim.api.nvim_buf_get_option(buf, 'buftype') ~= 'terminal' then
    return
  end
  for _, terminal in pairs(__TerminalManager) do
    if terminal.buf == buf then
      util.debug('Setting last terminal to "%s"', terminal.params.name)
      M.set_last(terminal.params.name)
    end
  end
end


---Remove all exited terminals from the managed map
function M.refresh()
  for name, terminal in pairs(__TerminalManager) do
    util.debug('Checking "%s"', name)
    if not terminal:is_valid() then
      util.debug('Removing "%s"', name)
      __TerminalManager[name] = nil
    end
  end
end


---Exit all managed terminals and clear the map of managed terminals
function M.clear()
  for _, terminal in pairs(__TerminalManager) do
    util.debug('Checking %s', terminal.params.name)
    if not terminal:is_valid() then
      util.debug('Exiting %s', terminal.params.name)
      terminal:exit()
    end
  end
  __TerminalManager = {}
end


---Get the names of all existing terminals
function M.available()
  local names = {}
  for _, terminal in pairs(__TerminalManager) do
    table.insert(names, terminal.params.name)
  end
  return names
end

return M
