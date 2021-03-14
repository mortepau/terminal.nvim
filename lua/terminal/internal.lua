local util = require('terminal.util')
local table_util = require('terminal.util.table')
local error_wrapper = require('terminal.util.error').error_wrapper
local state = require('terminal.state')

local Terminal = {}

local template = {
  name = '',
  cwd = '',
  cmd = '',
  cmd_init = '',
  position = '',
  position_init = '',
  id = -1,
  buf_name = '',
  bufnr = -1,
  win_id = -1,
  tabpage = -1,
  alive = false,
}

local positions = {
  current = 'enew',
  tab     = 'tabnew',
  float   = 'custom',
  top     = 'topleft new',
  bot     = 'botright new',
  left    = 'topleft vnew',
  right   = 'botright vnew',
  above   = 'aboveleft new',
  below   = 'belowright new',
  rhs     = 'belowright vnew',
  lhs     = 'aboveleft vnew',
}

local function position_to_command(position)
  local command = positions[position]
  if not command then
    error(error_wrapper('Invalid position: ' .. position .. ', has to be one of ' .. table_util.stringify(vim.tbl_keys(positions))))
  end
  return command
end

local function open_window(self)
  local command = position_to_command(self.position)

  -- TODO (mortepau): Not all types create a new window
  local windows_pre = vim.api.nvim_list_wins()
  vim.cmd(command)
  local windows_post = vim.api.nvim_list_wins()

  -- Is there a better way of getting the window id
  local win_id = vim.tbl_filter(function(t) return not table_util.in_table(t, windows_pre) end, windows_post)[1]

  if self.position == 'current' then
    win_id = vim.api.nvim_get_current_win()
  end

  local bufnr = vim.api.nvim_create_buf(true, false)

  self.bufnr = bufnr
  self.win_id = win_id
  self.tabpage = vim.api.nvim_win_get_tabpage(win_id)
end

local function open_terminal(self)
  vim.api.nvim_win_set_buf(self.win_id, self.bufnr)
  vim.api.nvim_buf_call(self.bufnr, function()
    vim.fn.termopen(self.cmd, { cwd = vim.fn.expand(self.cwd) })
  end)
end

function Terminal:new(opts)
  assert(
    type(opts.name) == 'string' and #opts.name > 0,
    error_wrapper('Invalid terminal name, expected a non-zero length string not a ' .. type(opts.name))
  )
  assert(
    util.type_or_nil(opts.cwd, 'string'),
    error_wrapper('Invalid current working directory, expected a string not a ' .. type(opts.cwd))
  )
  assert(
    util.type_or_nil(opts.cmd, 'string'),
    error_wrapper('Invalid cmd, expected a string not a ' .. type(opts.cmd))
  )
  assert(
    util.type_or_nil(opts.position, 'string'),
    error_wrapper('Invalid position, expected a string not a ' .. type(opts.position))
  )
  if type(opts.position) == 'string' then
    assert(
      table_util.in_table(opts.position, vim.tbl_keys(positions)),
      error_wrapper('Invalid position name, expected one of ' .. table_util.stringify(vim.tbl_keys(positions)) .. ' not ' .. tostring(opts.position))
    )
  end

  local o = vim.deepcopy(template)

  o.name = opts.name
  o.position = opts.position
  o.position_init = opts.position
  o.cmd = opts.cmd
  o.cmd_init = opts.cmd
  o.cwd = opts.cwd

  -- Attach the local functions to the new terminal
  o.open_window = open_window
  o.open_terminal = open_terminal

  return o
end

return Terminal
