---@class SimpleBooleanToggle
local M = {}

---A dictionary containing boolean values and their opposites.
---Each `key` is a boolean string, and its corresponding `value` is its opposite.
---For example: `{ "true": "false" }`. Usage: `M.booleans["true"]` -> `"false"`.
---@type { [string]: string }
M.booleans = {}

M.winid = 0
M.bufnr = 0

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

function M.get_line(linenr, left, right)
  if left == 0 and right == -1 then
    return vim.fn.getline(linenr)
  elseif left == 0 then
    return vim.fn.getline(linenr):sub(1, right)
  else
    return vim.fn.getline(linenr):sub(left, right)
  end
end

---@param direction boolean|nil `true` for inc, `false` for dec, `nil` for only boolean toggle
function M.toggle_nvim_visual_mode(direction)
  local init_select_pos = vim.fn.getpos("v")
  local end_select_pos = vim.fn.getpos(".")
  if end_select_pos[2] < init_select_pos[2] then
    init_select_pos, end_select_pos = end_select_pos, init_select_pos
  end

  local init_select = { init_select_pos[2], init_select_pos[3] }
  local end_select = { end_select_pos[2], end_select_pos[3] }
  local init_col_pos = init_select[2] - 1
  local end_col_pos = end_select_pos[3]

  local last_line_len = vim.api.nvim_strwidth(vim.fn.getline(end_select[1]))
  if end_col_pos > last_line_len then
    end_col_pos = last_line_len
  end

  local region = vim.region(M.bufnr, init_select, end_select, "v", false)
  local replacement = {}
  for linenr = init_select[1], end_select[1] do
    local line = M.get_line(linenr, region[linenr][1], region[linenr][2])
    line = M.toggle_line(direction, line)
    table.insert(replacement, line)
  end

  vim.api.nvim_buf_set_text(
    M.bufnr,
    init_select[1] - 1,
    init_col_pos,
    end_select[1] - 1,
    end_col_pos,
    replacement
  )
end

---@param direction boolean|nil `true` for inc, `false` for dec, `nil` for only boolean toggle
function M.toggle_nvim_visual_line_mode(direction)
  local first_line = vim.fn.getpos("v")[2]
  local last_line = vim.fn.getpos(".")[2]
  if last_line < first_line then
    first_line, last_line = last_line, first_line
  end

  local init_select = { first_line, 0 }
  local end_select = { last_line, -1 }
  -- NOTE: vim.region modifies the passed position tables!
  local region = vim.region(M.bufnr, init_select, end_select, "V", false)

  local replacement = {}
  for linenr = first_line, last_line do
    local line = M.get_line(linenr, region[linenr][1], region[linenr][2])
    line = M.toggle_line(direction, line)
    table.insert(replacement, line)
  end

  vim.api.nvim_buf_set_lines(M.bufnr, first_line - 1, last_line, true, replacement)
end

---@param direction boolean|nil `true` for inc, `false` for dec, `nil` for only boolean toggle
function M.toggle_nvim_visual_block_mode(direction)
  local init_select = vim.fn.getpos("v")
  local end_select = vim.fn.getpos(".")
  if end_select[2] < init_select[2] then
    init_select, end_select = end_select, init_select
  end
  local init_col = init_select[3]
  local end_col = end_select[3]

  for linenr = init_select[2], end_select[2] do
    local original_region = M.get_line(linenr, init_col, end_col)
    local replacement = M.toggle_line(direction, original_region)

    local line_width = vim.api.nvim_strwidth(vim.fn.getline(linenr))
    local end_col_line = line_width < end_col and line_width or end_col
    vim.api.nvim_buf_set_text(
      M.bufnr,
      linenr - 1,
      init_col - 1,
      linenr - 1,
      end_col_line,
      { replacement }
    )
  end
end

---@param increase boolean|nil If nil it does not change digits.
---@param line string
---@return string
function M.toggle_line(increase, line)
  for capture_group in line:gmatch("%S+") do
    if increase ~= nil then
      local left, value, right = capture_group:match("(.-)(%-?%d+)(.*)")
      value = tonumber(value)
      if value then
        local cmd_count = vim.v.count == 0 and 1 or vim.v.count
        local new_value = value + (cmd_count * (increase and 1 or -1))
        local replacement = string.format("%s%d%s", left or "", new_value, right or "")

        if value < 0 then -- gsub pattern needs the "-" char to be escaped
          capture_group = string.format("%s-%d%s", left or "", value, right or "")
        end
        return (string.gsub(line, capture_group, replacement, 1))
      end
    end

    local left, value, right = capture_group:match("(%p-)(%a+)(%p*)")
    local opposite_str = M.booleans[value]
    if opposite_str then
      local replacement = string.format("%s%s%s", left or "", opposite_str, right or "")
      return (string.gsub(line, capture_group, replacement, 1))
    end
  end
  return line
end

---Run the base built-in increase/decrease function
function M.builtin_call(direction, cmd_count)
  if direction then
    vim.cmd("normal!" .. cmd_count .. "")
  else
    vim.cmd("normal!" .. cmd_count .. "")
  end
end

---@param direction boolean|nil `true` for inc, `false` for dec, `nil` for only boolean toggle
function M.toggle_nvim_normal_mode(direction)
  local original_position = vim.api.nvim_win_get_cursor(M.winid)
  local line = vim.api.nvim_get_current_line()
  local line_size = vim.fn.strlen(line)

  local current_line = original_position[1]
  local current_char_pos = original_position[2]
  local cmd_count = vim.v.count > 1 and vim.v.count or ""
  local curstr = ""
  local cword = ""

  local function update_vars_to_cursor_position()
    local current_pos = vim.api.nvim_win_get_cursor(M.winid)
    current_line = current_pos[1]
    current_char_pos = current_pos[2]
    curstr = vim.fn.matchstr(line, "\\k*", current_char_pos)
    cword = vim.fn.expand("<cword>")
  end

  update_vars_to_cursor_position()
  local failsafe = 0
  while current_char_pos + 1 <= line_size and current_line == original_position[1] do
    failsafe = failsafe + 1
    if failsafe == 512 then
      return
    end
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
  vim.api.nvim_win_set_cursor(M.winid, original_position)
end

---@param direction boolean|nil `true` for inc, `false` for dec, `nil` for only boolean toggle
function M.toggle_dispatcher(direction)
  local nvim_mode = vim.api.nvim_get_mode().mode:sub(1, 1)

  if nvim_mode == "n" then
    M.toggle_nvim_normal_mode(direction)
  elseif nvim_mode == "v" then
    M.toggle_nvim_visual_mode(direction)
  elseif nvim_mode == "V" then
    M.toggle_nvim_visual_line_mode(direction)
  elseif nvim_mode == "" then
    M.toggle_nvim_visual_block_mode(direction)
  end
end

local overwriten_builtins = false

---Set `<C-a>`/`<C-x>` keymaps to the `toggle` function
---@param silent? boolean `true` to avoid notification
function M.overwrite_default_keys(silent)
  if overwriten_builtins then
    return
  end
  overwriten_builtins = true
  -- stylua: ignore start
  vim.keymap.set(
    { "n", "v" },
    "",
    function() M.toggle_dispatcher(true) end,
    { desc = "Boolean Toggle: Increment number/toggle boolean value." }
  )
  vim.keymap.set(
    { "n", "v" },
    "",
    function() M.toggle_dispatcher(false) end,
    { desc = "Boolean Toggle: Decrement number/toggle boolean value." }
  )
  -- stylua: ignore end
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
