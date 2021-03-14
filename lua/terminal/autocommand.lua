local state = require('terminal.state')
local config = require('terminal.config')
local terminal_factory = require('terminal.internal')

local M = {}

function M.term_open(buf)
  -- Convert bufnr from a string to a number
  buf = tonumber(buf)

  local terminal = state.get_terminal_from_key('bufnr', buf)

  -- TODO (mortepau): Returns if using the builtin command instead of ours
  if not terminal then
    return
  end

  terminal.alive = true
  terminal.id = vim.api.nvim_buf_get_var(buf, 'terminal_job_pid')

  if config.get('use_custom_naming_scheme') then
    vim.api.nvim_buf_set_name(terminal.bufnr, config.get('naming_scheme_handle')(vim.deepcopy(terminal)))
  end
  terminal.buf_name = vim.api.nvim_buf_get_name(buf)

  -- TODO (mortepau): Set up new autocommands for handling window management
end

function M.term_close(buf)
  buf = tonumber(buf)

  local terminal = state.get_terminal_from_key('bufnr', buf)

  if not terminal then
    return
  end

  terminal.alive = false
end

return M
