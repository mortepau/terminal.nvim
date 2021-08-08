local TerminalManager = require('terminal.manager')
local main = require('terminal')

local M = {}

---Get the directories in dir
---@param dir string @The directory to search
---@return table @The sub-directories of dir
local function dirs(dir)
  local directories = {}
  dir = dir ~= '' and dir or '.'
  local dir_expanded = vim.fn.fnamemodify(vim.fn.expand(dir), ':p')
  local dir_lstat = vim.loop.fs_lstat(dir_expanded)

  -- Return early if invalid directory
  if not dir_lstat then return directories end
  if not dir_lstat.type and dir_lstat.type ~= 'directory' then return directories end

  local suffix = dir:sub(-1, -1) == '/' and '' or '/'
  local files = vim.loop.fs_readdir(
    vim.loop.fs_opendir(dir_expanded, nil, 100)
  )
  for _, file in ipairs(files) do
    if file.type == 'directory' then
      table.insert(directories, dir .. suffix .. file.name)
    end
  end
  return directories
end

---Find the table of options based on the current key and lead
---@param key string @The parameter to find completion values for
---@param lead string @The leading characters for the string to complete
---@param options string[] @The valid keys for the command
---@return string[] @The found completion values
local function to_list(key, lead, options)
  if not vim.tbl_contains(options, key) then
    return {}
  end
  if key == 'name' then
    return TerminalManager.available()
  elseif key == 'position' then
    return vim.tbl_keys(require('terminal.position_commands'))
  elseif key == 'cwd' then
    return dirs(lead)
  end
  return {}
end

---Filter the list of completion values based on the lead
---@param lead string @The beginning of the completion target
---@param list string[] @Possible completion values
---@return string[] @The filtered completion values
local function filter(lead, list)
  local regex = vim.regex('^' .. lead)
  return vim.tbl_filter(function(v) return regex:match_str(v) end, list)
end

---Add the key to all the completion values
---@param key string @The key to prepend to all completion values
---@param list string[] @The completion values
---@return string[] @The mapped completion values
local function map(key, list)
  return vim.tbl_map(function(v) return key .. '=' .. v end, list)
end

---Parse the given arguments
---@param args string[] @The user provided arguments to the command
---@return Params @The parsed arguments.
local function parse_args(args)
  local name, position, cwd, cmd
  for _, arg in ipairs(args) do
    local parts = vim.split(arg, '=')
    if #parts == 2 then
      local key, value = unpack(parts)
      if key == 'name' then
        name = value
      elseif key == 'position' then
        position = value
      elseif key == 'cwd' then
        cwd = value
      else
        cmd = type(cmd) == 'nil' and arg or cmd .. ' ' .. arg
      end
    else
      cmd = type(cmd) == 'nil' and arg or cmd .. ' ' .. arg
    end
  end

  return {
    name = name,
    position = position,
    cwd = cwd,
    cmd = cmd,
  }
end

---Command name to allowed completion keys
local choices = {
  Terminal   = { 'name', 'position', 'cwd', 'cmd' },
  TermOpen   = { 'name', 'position', 'cwd', 'cmd' },
  TermToggle = { 'name', 'position', 'cwd', 'cmd' },
  TermMove   = { 'name', 'position' },
  TermEcho   = { 'name', 'cmd' },
  TermClose  = { 'name' },
  TermExit   = { 'name' },
}

---Give completion targets for a command with named arguments
---@vararg string[] @The command line, current lead on argument and cursor position
---@return string[] @Completion targets
function M.named_completion(...)
  local arglead, cmdline, _ = unpack(...)
  local command = vim.split(cmdline, ' ')[1]
  local cmd_regex = vim.regex('^' .. command)
  command = vim.tbl_filter(
    function(v) return cmd_regex:match_str(v) end,
    vim.tbl_keys(choices)
  )[1]
  local parts = vim.split(arglead, '=')
  if #parts ~= 2 then
    return { arglead }
  end
  local key, lead = unpack(parts)
  local options = choices[command]
  return map(key, filter(lead, to_list(key, lead, options)))
end

---Give completion targets for a command with positional arguments
---@vararg string[] @The command line, current lead on argument and cursor position
---@return string[] @Completion targets
function M.positional_completion(...)
  local arglead, cmdline, _ = unpack(...)
  local cmdline_split = vim.split(cmdline, ' ')
  local cmd_regex = vim.regex('^' .. cmdline_split[1])
  local command = vim.tbl_filter(
    function(v) return cmd_regex:match_str(v) end,
    vim.tbl_keys(choices)
  )[1]

  return filter(
    arglead,
    to_list(
      choices[command][#cmdline_split - 1],
      arglead,
      choices[command]
    )
  )
end

---Call a command with named parameters
---@vararg string[] @The provided arguments
function M.named_call(...)
  local command, args  = unpack(...)
  main[command](parse_args(args))
end

---Call a command with positional parameters
---@vararg string[] @The provided arguments
function M.positional_call(...)
  local command, args = unpack(...)
  print(vim.inspect(parse_args(args)))
  main[command](parse_args(args))
end

function M.list_show(show_invalid)
  local terminals = TerminalManager.available()
  if not show_invalid then
    terminals = vim.tbl_filter(
      function(term) return term:is_valid() end,
      terminals
    )
  end
  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = math.floor(0.5 * vim.opt.columns:get()),
    height = #terminals,
    row = 0.5 * vim.opt.lines:get() - #terminals,
    col = 0.25 * vim.opt.columns:get(),
    focusable = true,
    style = 'minimal',
    border = 'single',
  })
  vim.api.nvim_buf_set_lines(buf, 0, #terminals-1, false, terminals)

  vim.cmd(string.format(
    [[autocmd! BufLeave <buffer=%d> lua require('terminal.api').list_close(%d, %d)]],
    buf, buf, win
  ))

  for _, mapping in ipairs({'<Esc>', 'gq' }) do
    vim.api.nvim_buf_set_keymap(
      buf,
      'n',
      mapping,
      string.format(':lua require("terminal.api").list_close(%d, %d)<CR>', buf, win),
      { noremap = true, silent = true }
    )
  end
  vim.api.nvim_buf_set_keymap(
    buf,
    'n',
    '<CR>',
    string.format(':lua require("terminal.api").list_enter(%d, %d)<CR>', buf, win),
    { noremap = true, silent = true }
  )
end

function M.list_close(buf, win)
  if vim.api.nvim_win_is_valid(win) then
    vim.api.nvim_win_close(win, true)
  end
  if vim.api.nvim_buf_is_valid(buf) then
    vim.api.nvim_buf_delete(buf, { force = true })
  end
end

function M.list_enter(buf, win)
  local line = vim.api.nvim_get_current_line()
  require('terminal').open(line, 'current')
  M.list_close(buf, win)
end

return M
