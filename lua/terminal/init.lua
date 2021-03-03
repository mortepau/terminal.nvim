local config = require('terminal.config')

local M = {}

function M.setup(opts)
  -- Update the configuration
  for key, value in pairs(opts) do
    config.set(key, value)
  end

  if config.get('define_all_commands') then
    vim.cmd([=[command! -nargs=1 TermOpen call luaeval('require("terminal.api").open(_A)', [<f-args>]]=])
    vim.cmd([=[command! -nargs=1 TermClose call luaeval('require("terminal.api").close(_A)', [<f-args>]]=])
    vim.cmd([=[command! -nargs=1 TermMove call luaeval('require("terminal.api").move(_A)', [<f-args>]]=])
    vim.cmd([=[command! -nargs=1 TermEcho call luaeval('require("terminal.api").echo(_A)', [<f-args>]]=])
  end

  vim.cmd([=[command! -nargs=1 Terminal call luaeval('require("terminal.api").execute(_A)', [<f-args>]]=])
end

return M
