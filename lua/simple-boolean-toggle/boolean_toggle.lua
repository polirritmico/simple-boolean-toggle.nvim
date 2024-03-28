---@class SimpleBooleanToggle
local M = {}
local P = P

---A dictionary containing boolean values and their opposites.
---Each `key` is a boolean string, and its corresponding `value` is its opposite.
---For example: `{ "true": "false" }`. Usage: `M.booleans["true"]` -> `"false"`.
---@type { [string]: string }
M.booleans = {}

---Populates the inner `booleans` table with the base strings and the upper and
---lower case variants if they are enabled. The first boolean after the opposite
---string (the third element) means adding the uppercase and the last one adding
---the lowercase variants.
---@param base_booleans table<string, string, boolean?, boolean?>
function M.generate_booleans(base_booleans)
  for _, tbl in pairs(base_booleans) do
    local opts = tbl[3] or {}
    M.booleans[tbl[1]] = tbl[2]
    M.booleans[tbl[2]] = tbl[1]
    if opts.uppercase == nil or opts.uppercase == true then
      M.booleans[tbl[1]:upper()] = tbl[2]:upper()
      M.booleans[tbl[2]:upper()] = tbl[1]:upper()
    end
    if opts.lowercase == nil or opts.lowercase == true then
      M.booleans[tbl[1]:lower()] = tbl[2]:lower()
      M.booleans[tbl[2]:lower()] = tbl[1]:lower()
    end
  end
end

---Run the base built-in increase/decrease function
function M.builtin_call(direction, cmd_count)
  if direction then
    vim.cmd("normal!" .. cmd_count .. "")
  else
    vim.cmd("normal!" .. cmd_count .. "")
  end
end

function M.toggle_nvim_visual_mode(direction, nvim_mode)
  local lines = {}
  local region = {}
  local init_select_pos = vim.fn.getpos("v")
  local end_select_pos = vim.fn.getpos(".")

  local init_select, end_select
  if nvim_mode == "V" then
    init_select = { init_select_pos[2], 0 }
    end_select = { end_select_pos[2], -1 }
  else
    init_select = { init_select_pos[2], init_select_pos[3] }
    end_select = { end_select_pos[2], end_select_pos[3] }
  end

  if nvim_mode == "" then
    -- BUG: https://github.com/neovim/neovim/issues/18154
    region = vim.region(0, init_select, end_select, "v", false)
    for linenr, _ in pairs(region) do
      local line = M.get_line(linenr, init_select[2], end_select[2])
      -- line = M.toggle_line(direction, line)
      table.insert(lines, linenr, line)
    end
  else
    region = vim.region(0, init_select, end_select, nvim_mode, false)
    for linenr, range in pairs(region) do
      local line = M.get_line(linenr, range[1], range[2])
      -- line = M.toggle_line(direction, line)
      table.insert(lines, linenr, line)
    end
  end
  table.sort(lines)
  P("lines:", lines)
end

---@param increase boolean
---@param line string
---@return string
function M.toggle_line(increase, line)
  -- TODO:
  return ""
end

function M.get_line(linenr, left, right)
  if left == 0 and right == -1 then
    return vim.fn.getline(linenr)
  elseif left == 0 then
    return vim.fn.getline(linenr):sub(1, right)
  else
    return vim.fn.getline(linenr):sub(left, right)
  end
end

function M.toggle_nvim_normal_mode(direction)
  local original_position = vim.api.nvim_win_get_cursor(0)
  local line = vim.api.nvim_get_current_line()
  local line_size = vim.fn.strlen(line)

  local current_line = original_position[1]
  local current_char_pos = original_position[2]
  local cmd_count = vim.v.count > 1 and vim.v.count or ""
  local curstr = ""
  local cword = ""

  local function update_vars_to_cursor_position()
    local current_pos = vim.api.nvim_win_get_cursor(0)
    current_line = current_pos[1]
    current_char_pos = current_pos[2]
    curstr = vim.fn.matchstr(line, "\\k*", current_char_pos)
    cword = vim.fn.expand("<cword>")
  end

  update_vars_to_cursor_position()
  while current_char_pos + 1 <= line_size and current_line == original_position[1] do
    -- check for numbers:
    if direction ~= nil and (tonumber(cword) or string.match(cword, "%d") ~= nil) then
      M.builtin_call(direction, cmd_count)
      return
    end

    if curstr ~= "" and string.find(cword, curstr) then
      local opposite_str = M.booleans[cword]
      if opposite_str then
        vim.cmd('normal! "_ciw' .. opposite_str)
        return
      end
    end

    vim.cmd("normal! w")
    update_vars_to_cursor_position()
  end
  vim.api.nvim_win_set_cursor(0, original_position)
end

function M.toggle(direction)
  local nvim_mode = vim.api.nvim_get_mode().mode:sub(1, 1)

  if nvim_mode == "n" then
    M.toggle_nvim_normal_mode(direction)
    return
  else
    M.toggle_nvim_visual_mode(direction, nvim_mode)
    return
  end
  -- elseif nvim_mode == "v" then
  --   reported_mode = "visual"
  -- elseif nvim_mode == "V" then
  --   reported_mode = "visual_line"
  -- elseif nvim_mode == "" then
  --   reported_mode = "block_mode"
  -- end

  -- local original_position = vim.api.nvim_win_get_cursor(0)
  -- local line = vim.api.nvim_get_current_line()
  -- local line_size = vim.fn.strlen(line)
end

local overwriten_builtins = false

---Set `<C-a>`/`<C-x>` keymaps to the `toggle` function
---@param silent? boolean `true` to avoid notification
function M.overwrite_default_keys(silent)
  if overwriten_builtins then
    return
  end
  overwriten_builtins = true
  vim.keymap.set(
    { "n", "v" },
    "",
    function() M.toggle(true) end,
    { desc = "Boolean Toggle: Increment number/toggle boolean value." }
  )
  vim.keymap.set(
    { "n", "v" },
    "",
    function() M.toggle(false) end,
    { desc = "Boolean Toggle: Decrement number/toggle boolean value." }
  )
  if not silent then
    vim.notify("[Boolean Toggle]: Enabled", vim.log.levels.INFO)
  end
end

---Unset `<C-a>`/`<C-x>` keymaps, returning them to the default behaviour
function M.restore_default_keys()
  if not overwriten_builtins then
    return
  end
  overwriten_builtins = false
  vim.keymap.del({ "n", "v" }, "")
  vim.keymap.del({ "n", "v" }, "")
  vim.notify("[Boolean Toggle]: Disabled", vim.log.levels.INFO)
end

---Enable/Disable the custom toggle
function M.toggle_the_toggle()
  if overwriten_builtins then
    M.restore_default_keys()
  else
    M.overwrite_default_keys()
  end
end

return M
