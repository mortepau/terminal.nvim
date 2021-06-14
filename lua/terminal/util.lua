local config = require('tterminal.config')

---@class Utility @Utility functionality for Terminal.nvim
local M = {}

---Get the type of obj, checks its metatable for `__type` first
---@param obj any @The object to check
---@return string
function M.type(obj)
  local mt = getmetatable(obj)
  if mt and mt.__type then return mt.__type end
  return type(obj)
end

---Convert a log level string to number
---@param level string @The level to convert
---@return number
local function level_to_number(level)
  local levels = {
    trace = 6,
    debug = 5,
    info = 4,
    warn = 3,
    error = 2,
    fatal = 1,
  }
  return levels[level] and levels[level] or levels.info
end

---Print the content if level is less than debug_level
---@param level number @The debug level
---@param template string @A string template for string.format
---@vararg any @The variables to give to template
local function logger(level, template, ...)
  local config_level = level_to_number(config.get('debug_level'))
  if level <= config_level then
    print('[Terminal.nvim]', string.format(template, ...))
  end
end

---Print with log level trace
---@vararg any @The content to print
function M.trace(...) logger(6, ...) end

---Print with log level debug
---@vararg any @The content to print
function M.debug(...) logger(5, ...) end

---Print with log level info
---@vararg any @The content to print
function M.info(...) logger(4, ...) end

---Print with log level warn
---@vararg any @The content to print
function M.warn(...) logger(3, ...) end

---Print with log level error
---@vararg any @The content to print
function M.error(...) logger(2, ...) end

---Print with log level fatal
---@vararg any @The content to print
function M.fatal(...) logger(1, ...) end

return M
