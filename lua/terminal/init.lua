local TerminalManager = require('terminal.manager')
local config = require('terminal.config')
local util = require('terminal.util')

---@class TerminalNvim @The entry point for Terminal.nvim
local M = {}


---Initialize the plugin and apply user configurations
---@param opts UserConfig @Configuration provided by the user
function M.setup(opts)
  opts = opts or {}
  -- Update user configurations
  config.update(opts)
  local terminal = TerminalManager.get(config.get('default_params').name, true)
  terminal.last = true
  for _, params in ipairs(config.get('terminals')) do
    terminal = TerminalManager.get(params.name, true)
    terminal:update(params)
  end
end


---Open a terminal using the parameters passed
---@param name string|nil @The terminal instance to open
---@param position string|nil @The terminal position
---@param cwd string|nil @The terminal's current working directory
---@param cmd string|nil @The command to launch
function M.open(name, position, cwd, cmd)
  -- Fetch the terminal given by name, create if not found
  local Terminal = TerminalManager.get(name, true)
  local params = {
    position = position,
    cwd = cwd,
    cmd = cmd
  }
  -- Update the terminal parameters
  Terminal:update(params)
  if not Terminal:is_valid() then
    util.debug('Terminal "%s" does not exist yet. Creating it.', Terminal.params.name)
    util.debug('Using parameters: name: %s, position: %s, cwd: %s, cmd: %s',
      Terminal.params.name,
      Terminal.params.position,
      Terminal.params.cwd,
      Terminal.params.cmd
    )
    -- Create the terminal buffer as it is invalid
    Terminal:create()
  end
  if not Terminal:is_open() then
    -- Open the terminal window
    Terminal:open()
  else
    -- Called when already open, enter terminal instead then
    Terminal:enter()
  end
end


---Close the terminal given by name
---@param name string|nil @The terminal to find, nil closes last terminal
function M.close(name)
  local Terminal = TerminalManager.get(name, false)
  if not Terminal or not util.type(Terminal) == 'terminal' then
    util.error('No terminal with the name "%s"', name)
  end
  if Terminal:is_open() then
    Terminal:close()
  end
end


---Toggle the visibility of the terminal given by name
---@param name string|nil @The terminal to toggle, uses last if nil
---@param position Position|nil @The new position to use
---@param cwd string|nil @The current working directory to use
---@param cmd string|nil @The command to execute
function M.toggle(name, position, cwd, cmd)
  local Terminal = TerminalManager.get(name, true)
  Terminal:update({ position = position, cwd = cwd, cmd = cmd })
  if not util.type(Terminal) == 'terminal' then
    util.error('No terminal with the name "%s"', name)
    return
  end

  if Terminal:is_open() then
    Terminal:close()
  else
    Terminal:open()
  end
end


---Move the terminal given by name to position
---@param name string|nil @The terminal to move, uses last terminal if nil
---@param position Position @The position to move the terminal to
function M.move(name, position)
  local Terminal = TerminalManager.get(name, false)
  if not Terminal or not util.type(Terminal) == 'terminal' then
    util.error('No terminal with the name "%s"', name)
    return
  end

  if not position then
    util.error('Required parameter missing: "position"')
    return
  end

  Terminal:update({ position = position })
  if Terminal:is_open() then
    Terminal:close()
  end
  Terminal:open()
end


---Execute the command cmd in the terminal given by name
---@param name string|nil @The terminal to use, uses last terminal if nil
---@param cmd string @The command to execute
function M.echo(name, cmd)
  local Terminal = TerminalManager.get(name, false)
  if not Terminal or not util.type(Terminal) == 'terminal' then
    util.error('No terminal with the name "%s"', name)
    return
  end

  if not cmd then
    util.error('Required parameter missing: "cmd"')
    return
  end

  if Terminal:is_valid() then
    Terminal:echo(cmd)
  end
end


---Exit the terminal given by name
---@param name string @The terminal to exit
function M.exit(name)
  local Terminal = TerminalManager.get(name, false)
  if not Terminal or not util.type(Terminal) == 'terminal' then
    util.error('No terminal with the name "%s"', name)
    return
  end

  Terminal:exit()
end

return M
