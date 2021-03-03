local M = {}

function M.in_table(value, table)
  if type(table) ~= 'table' then return false end

  for _, entry in pairs(table) do
    if value == entry then
      return true
    end
  end

  return false
end

function M.table_length(table)
  if type(table) ~= 'table' then return 0 end

  local len = 0
  for _, _ in pairs(table) do
    len = len + 1
  end

  return len
end

function M.table_is_list(table)
  if type(table) ~= 'table' then return false end

  local expected = 1
  for k, _ in pairs(table) do
    if type(k) == 'number' and k == expected then
      expected = expected + 1
    else
      return false
    end
  end

  return true
end

function M.stringify(table)
  if type(table) ~= 'table' then return tostring(table) end

  local is_list = M.table_is_list(table) and M.table_length(table) > 0
  local expected_next = 1

  local result = ''

  for key, value in pairs(table) do
    if is_list and type(key) == 'number' and key == expected_next then
      expected_next = expected_next + 1
    else
      is_list = false
      result = result .. '["' .. key .. '"] = ' 
    end

    if type(value) == 'table' then
      result = result .. M.stringify(value)
    elseif type(value) == 'number' then
      result = result .. value
    elseif type(value) == 'boolean' then
      result = result .. tostring(value)
    else
      result = result .. '"' .. value .. '"'
    end

    result = result .. ', '
  end

  -- Remove trailing comma if list is non-empty
  if result ~= '' then
    result = result:sub(1, result:len() - 2)
  end

  return (is_list and '[' .. result .. ']') or ('{ ' .. result .. ' }')
end

return M
