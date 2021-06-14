---@class ConfigWrapper @Wrapper for accessing the terminal.nvim configuration
local M = {}

---@alias LogLevel "'fatal'" | "'error'" | "'warn'" | "'info'" | "'debug'" | "'trace'"

---@class UserConfig @Terminal.nvim configuration
---@field public startinsert boolean @Enter terminal-mode when entering terminal window
---@field public enter_on_open boolean @Move cursor to terminal on open
---@field public list boolean @List the terminal buffer
---@field public debug_level LogLevel @Log level
local default = {
  startinsert = true,
  enter_on_open = true,
  list = false,
  debug_level = 'trace',
}

local config = {}

---Get a value from the config
---@param key string @The value to find
---@return any
function M.get(key)
  if config[key] ~= nil then
    return config[key]
  end
end

---Update the config with new values
---@param new_config UserConfig @The new config values
function M.update(new_config)
  config = vim.tbl_deep_extend(
    'force',
    vim.deepcopy(default),
    config,
    new_config
  )
end

M.update({})

return M
