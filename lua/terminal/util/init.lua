local M = {}

function M.type_or_nil(value, value_type)
  local t = type(value)
  return t == value_type or t == 'nil'
end

return M
