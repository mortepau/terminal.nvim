local Terminal = require('tterminal.terminal')
local util = require('tterminal.util')

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
  if not create then return __TerminalManager[name] end

  if not __TerminalManager[name] then
    util.debug('Creating terminal "%s"', name)
    local terminal = Terminal.new(name)
    __TerminalManager[terminal.params.name] = terminal
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

return M
