local io = require('terminal.io')
local config = require('terminal.config')

local M = {}

function M.execute(args)
  local args_table = io.parse_args('execute', args)
  print(vim.inspect(args_table))
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

return M
