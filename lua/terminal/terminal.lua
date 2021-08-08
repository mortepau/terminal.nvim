local config = require('terminal.config')
local util = require('terminal.util')
local posfuncs = require('terminal.position_commands')

---@alias Position "'current'" | "'float'" | "'tab'" | "'top'" | "'bot'" | "'right'" | "'left'" | "'above'" | "'below'" | "'rhs'" | "'lhs'"

---@class TerminalUserParams @Table of terminal parameters provided by user
---@field public name string @The terminal name
---@field public position Position @The terminal position
---@field public cwd string @The terminal's current working directory
---@field public cmd string @The terminal's initial or last echoed command
---@field public env table<string, string> @Environment variables to include
---@field public clear_env boolean @`env` defines the terminal environment exactly

---@class TerminalParams @Table of terminal parameters
---@field public params TerminalUserParams @The user provided parameters
---@field private win number|nil @The terminal window
---@field private buf number|nil @The terminal buffer
---@field private jobid number|nil @The terminal channel job id
---@field private termid number|nil @The terminal terminal id
---@field private exist boolean @The terminal is not exited
---@field private bufname string|nil @The terminal bufname

---@class Terminal @A container for a Neovim terminal
---@field public params TerminalUserParams @Parameters provided by user
---@field private win number|nil @The terminal window
---@field private buf number|nil @The terminal buffer
---@field private jobid number|nil @The terminal channel job id
---@field private exist boolean @The terminal is not exited
---@field private last boolean @The last used terminal
local Terminal = {}
Terminal.__index = Terminal
setmetatable(Terminal, {
  __type = 'terminal',
})

local __id = 0

---Create an unique id
---@return string
local function id()
  local new_id = __id
  __id = __id + 1
  return tostring(new_id)
end

---Get the default terminal parameters
---@return TerminalParams
local function default()
  return {
    params = {
      name = 'default',
      position = 'current',
      cwd = vim.fn.getcwd(),
      cmd = vim.api.nvim_get_option('shell'),
    },
    win = nil,
    buf = nil,
    bufname = nil,
    jobid = nil,
    termid = nil,
    exist = false,
  }
end

---@class JobError @Error codes returned by jobstart-like function
local JOB_ERROR = {
  [0] = 'Invalid arguments',
  [-1] = '%s is not executable'
}


---Create a new terminal instance
---@param name string|nil @The name of the new terminal
---@param params TerminalUserParams|nil @Parameters for the terminal
---@return Terminal
function Terminal.new(name, params)
  -- Create an identifier if none is provided
  if not name or name == '' then name = id() end

  if params and type(params) ~= 'table' then
    error(debug.traceback(string.format(
      'Invalid type for params: expected "table", received "%s"',
      type(params)
    )))
  end

  local self = setmetatable(default(), Terminal)
  self:update(vim.tbl_extend('keep', { name = name }, params or {}))

  return self
end


---Create the terminal buffer and set additional configurations
function Terminal:create()
  local listed = config.get('list')
  self.buf = vim.api.nvim_create_buf(listed, true)
  local jobid = vim.api.nvim_buf_call(
    self.buf,
    function()
      -- TODO(mortepau): Consider the use case for on_stdout, on_stderr, and on_exit
      local term_params = {
        cwd = self.params.cwd,
        env = self.params.env,
        clear_env = self.params.clear_env,
        detach = false,
        rpc = false,
        on_exit = function() self.exist = false end,
      }
      return vim.fn.termopen(self.params.cmd, term_params)
    end
  )

  if JOB_ERROR[jobid] then
    util.error(JOB_ERROR[jobid], self.params.cmd)
    return
  else
    self.jobid = jobid
  end
  self.exist = true
end


---Open a window with the terminal buffer
function Terminal:open()
  if not self:is_valid() then self:create() end
  if not self:is_open() then
    -- Open a window using the function specified by position
    if not posfuncs[self.params.position] then
      util.error('Invalid position "%s"', self.params.position)
      return
    end
    if vim.api.nvim_buf_is_valid(self.buf) then
      posfuncs[self.params.position](self)
    end
  end

  if config.get('enter_on_open') then
    self:enter()
  end
end


---Close the window with the terminal buffer
function Terminal:close()
  if self:is_valid() and self:is_open() then
    if #vim.api.nvim_list_wins() == 1 then
      vim.cmd('new')
    end
    vim.api.nvim_win_close(self.win, true)
  end
end


---Exit the terminal buffer and delete it
function Terminal:exit()
  if self:is_valid() then
    -- TODO(mortepau): Allow user defined exit commands?
    vim.api.nvim_chan_send(
      self.jobid,
      vim.api.nvim_replace_termcodes('exit<CR>', true, true, true)
    )
  end
end

---Enter the terminal window
function Terminal:enter()
  vim.api.nvim_set_current_win(self.win)

  if config.get('startinsert') then
    vim.cmd [[startinsert]]
  end
end


---Echo a command to the terminal
---@param cmd string @The command to execute
function Terminal:echo(cmd)
  local formatted_cmd = vim.api.nvim_replace_termcodes(cmd, true, true, true)
  vim.api.nvim_chan_send(self.jobid, formatted_cmd)
end


---Update the user parameters
---@param params TerminalUserParams @The new parameters
function Terminal:update(params)
  self.params = vim.tbl_extend('force', default().params, self.params, params)
end


---Check if the terminal is visible in a window
---@return boolean
function Terminal:is_open()
  if not self.buf then return false end

  for _, winnr in ipairs(vim.api.nvim_list_wins()) do
    local winbuf = vim.api.nvim_win_get_buf(winnr)
    if winbuf == self.buf then
      return true
    end
  end
  return false
end


---Check if the terminal exist
---@return boolean
function Terminal:is_valid()
  return self.exist
end

---@type Terminal
return Terminal
