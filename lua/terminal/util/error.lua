local M = {}

local MODULE_NAME = 'Terminal.nvim'

local function msg_wrapper(kind, msg)
  return '[' .. kind .. '] ' .. MODULE_NAME .. ' - ' .. msg
end

-- Use when any configuration is wrong or input is wrong
function M.error_wrapper(msg)
  return msg_wrapper('ERROR', msg)
end

-- Use when a breaking change is to be introduced or configuration will change
-- in a later version
function M.info_wrapper(msg)
  return msg_wrapper('INFO', msg)
end

-- Used when the debug flag is set. Should be used to get additional information
-- while working with developing the plugin
function M.debug_wrapper(msg)
  return msg_wrapper('DEBUG', msg)
end

return M
