local config = require('terminal.config')
local state = require('terminal.state')
local terminal_factory = require('terminal.internal')

local M = {}

local function create_autocommands()
  vim.cmd([[augroup Terminal.nvim]])
  vim.cmd([[  autocmd!]])
  vim.cmd([[  autocmd TermOpen * call luaeval("require('terminal.autocommand').term_open(_A)", expand('<abuf>'))]])
  vim.cmd([[  autocmd TermClose * call luaeval("require('terminal.autocommand').term_close(_A)", expand('<abuf>'))]])
  vim.cmd([[augroup END]])
end

function M.setup(opts)
  opts = opts or {}
  -- Update the configuration
  for key, value in pairs(opts) do
    config.set(key, value)
  end

  state.insert_terminal(terminal_factory:new(config.get('default_terminal')))
  -- TODO (mortepau): Fix so that all the terminals have all keys
  for _, terminal_config in ipairs(opts.terminals or {}) do
    state.insert_terminal(terminal_factory:new(terminal_config))
  end

  if config.get('define_all_commands') then
    vim.cmd([=[command! -nargs=? TermOpen call luaeval('require("terminal.api").open(_A)', <f-args>)]=])
    vim.cmd([=[command! -nargs=? TermClose call luaeval('require("terminal.api").close(_A)', <f-args>)]=])
    vim.cmd([=[command! -nargs=? TermMove call luaeval('require("terminal.api").move(_A)', <f-args>)]=])
    vim.cmd([=[command! -nargs=? TermEcho call luaeval('require("terminal.api").echo(_A)', <f-args>)]=])
  end

  -- TODO (mortepau): Add completelist for external commands
  vim.cmd([=[command! -nargs=? Terminal call luaeval('require("terminal.api").execute(_A)', <f-args>)]=])
  vim.cmd([=[command! -nargs=0 -bang TermList call luaeval('require("terminal.api").list(_A == 1)', <bang>0)]=])

  create_autocommands()
end

return M
