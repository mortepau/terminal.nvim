local M = {}

---Find the new window between call and call of callback
---@param old number[] @The old window id's
---@return fun():number
local function find_window(old)
  return function()
    local new_wins = vim.tbl_filter(
      function(v) return not vim.tbl_contains(old, v) end,
      vim.api.nvim_list_wins()
    )
    return #new_wins > 0 and new_wins[1] or vim.api.nvim_get_current_win()
  end
end

---Store the current cursor position and return to it with callback
---@return fun()
local function store_cursor()
  local window = vim.api.nvim_get_current_win()
  local cursor = vim.api.nvim_win_get_cursor(0)

  return function()
    vim.api.nvim_set_current_win(window)
    vim.api.nvim_win_set_cursor(window, cursor)
  end
end

---Use the window generated through template to place terminal
---@param template string @Template for the window creating command
---@param terminal Terminal @The terminal to place
local function generic_move(template, terminal)
  local winfn = find_window(vim.api.nvim_list_wins())
  local restore_cursor = store_cursor()
  vim.cmd(string.format(template, terminal.buf))
  terminal.win = winfn()
  restore_cursor()
end

---Insert the terminal's buffer in the currently active window
---@param terminal Terminal @The terminal to place
function M.current(terminal)
  vim.cmd(string.format('b%d', terminal.buf))
  terminal.win = vim.api.nvim_get_current_win()
end

---Insert the terminal's buffer in a floating window
---@param terminal Terminal @The terminal to place
function M.float(terminal)
  local win_params = {
    relative = 'editor',
    width = math.floor(0.9 * vim.opt.columns:get()),
    height = math.floor(0.9 * vim.opt.lines:get()),
    row = 0.05 * vim.opt.lines:get(),
    col = 0.05 * vim.opt.columns:get(),
    style = 'minimal',
    border = 'single'
  }
  terminal.win = vim.api.nvim_open_win(terminal.buf, false, win_params)
end

---Insert the terminal's buffer in a window in a new tab
---@param terminal Terminal @The terminal to place
function M.tab(terminal) generic_move('tab split | b%d', terminal) end

---Insert the terminal's buffer in a window at the top of the view
---@param terminal Terminal @The terminal to place
function M.top(terminal) generic_move('topleft split | b%d', terminal) end

---Insert the terminal's buffer in a window at the bottom of the view
---@param terminal Terminal @The terminal to place
function M.bot(terminal) generic_move('botright split | b%d', terminal) end

---Insert the terminal's buffer in a window at the left side of the view
---@param terminal Terminal @The terminal to place
function M.left(terminal) generic_move('topleft vsplit | b%d', terminal) end

---Insert the terminal's buffer in a window at the right side of the view
---@param terminal Terminal @The terminal to place
function M.right(terminal) generic_move('botright vsplit | b%d', terminal) end

---Insert the terminal's buffer in a window above the currently active window
---@param terminal Terminal @The terminal to place
function M.above(terminal) generic_move('aboveleft split | b%d', terminal) end

---Insert the terminal's buffer in a window below the currently active window
---@param terminal Terminal @The terminal to place
function M.below(terminal) generic_move('belowright split | b%d', terminal) end

---Insert the terminal's buffer in a window left of the currently active window
---@param terminal Terminal @The terminal to place
function M.lhs(terminal) generic_move('aboveleft vsplit | b%d', terminal) end

---Insert the terminal's buffer in a window right of the currently active window
---@param terminal Terminal @The terminal to place
function M.rhs(terminal) generic_move('belowright vsplit | b%d', terminal) end

return M
