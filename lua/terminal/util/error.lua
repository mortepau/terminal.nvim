local M = {}

local MODULE_NAME = 'Terminal.nvim'

function M.error_wrapper(msg)
  return '[' .. MODULE_NAME .. '] - ' .. msg
end

return M
