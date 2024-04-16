---@class Selection
---@field from { line: integer, col: integer }
---@field to { line: integer, col: integer }

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

---Get the line region based from the output of `vim.region`
---@param linenr integer 1-index?
---@param left integer 0-index?
---@param right integer 0-index, values -1 and 0 return the full line?
function M.get_line(linenr, left, right)
  if left == 0 and right == -1 then
    return vim.fn.getline(linenr + 1)
  elseif right == -1 then
    return vim.fn.getline(linenr + 1):sub(left + 1)
  else
    return vim.fn.getline(linenr + 1):sub(left + 1, right + 1)
  end
end

---Returns the cursor position. Lines and cols are 0-index with offset (char
---width and utf-8 byte size)
---@return Selection
function M.get_cursor_position()
  -- nvim_win_get_cursor output: [1] line (1-idx), [2] col (0-idx)
  local to = vim.api.nvim_win_get_cursor(M.winid)
  vim.api.nvim_feedkeys("o", "x", true)
  local from = vim.api.nvim_win_get_cursor(M.winid)
  vim.api.nvim_feedkeys("o", "x", true)

  return {
    from = { line = from[1] - 1, col = from[2] },
    to = { line = to[1] - 1, col = to[2] },
  }
end

---@param coords Selection
---@return Selection
function M.order_cursor_positions(coords)
  -- Selection could be "normal", same line or inverted (right to left and/or bottom to top)
  if coords.from.line > coords.to.line then
    coords.from.line, coords.to.line = coords.to.line, coords.from.line
    coords.from.col, coords.to.col = coords.to.col, coords.from.col
  elseif coords.from.line == coords.to.line and coords.from.col > coords.to.col then
    coords.from.col, coords.to.col = coords.to.col, coords.from.col
  end

  return coords
end

---@param direction boolean|nil `true` for inc, `false` for dec, `nil` for only boolean toggle
function M.toggle_nvim_visual_mode(direction)
  local cur = M.get_cursor_position()
  cur = M.order_cursor_positions(cur)

  -- NOTE: vim.region modifies passed tables!
  local region = vim.region(
    M.bufnr,
    { cur.from.line, cur.from.col },
    { cur.to.line, cur.to.col },
    "v",
    false
  )

  local replacement = {}
  for linenr = cur.from.line, cur.to.line do
    local line = M.get_line(linenr, region[linenr][1], region[linenr][2])
    line = M.toggle_line(direction, line)
    table.insert(replacement, line)
  end

  -- Cursor could be outside the line width
  local last_line_str = vim.fn.getline(cur.to.line + 1)
  -- TODO: Why not vim.api.nvim_strwidth(line)?
  local line_width_lua = string.len(last_line_str)
  local cursor_outside_width_offset = line_width_lua == cur.to.col and 0 or 1
  cur.to.col = cur.to.col + cursor_outside_width_offset

  -- 0-idx. lines are end-inclusive, and cols idx are end-exclusive.
  vim.api.nvim_buf_set_text(
    M.bufnr,
    cur.from.line,
    cur.from.col,
    cur.to.line,
    cur.to.col,
    replacement
  )

  -- TODO: Update cursor position only when the cursor is at the end or end+1
  -- col of the boolean value and the new toggled value is wider
end

---@param direction boolean|nil `true` for inc, `false` for dec, `nil` for only boolean toggle
function M.toggle_nvim_visual_line_mode(direction)
  local lnum_from = vim.fn.getpos("v")[2]
  local lnum_to = vim.fn.getpos(".")[2]
  -- Could be selected from bottom to top
  if lnum_to < lnum_from then
    lnum_from, lnum_to = lnum_to, lnum_from
  end

  local replacement = {}
  for linenr = lnum_from, lnum_to do
    local line = vim.fn.getline(linenr)
    line = M.toggle_line(direction, line)
    table.insert(replacement, line)
  end

  vim.api.nvim_buf_set_lines(M.bufnr, lnum_from - 1, lnum_to, true, replacement)
end

---@param direction boolean|nil `true` for inc, `false` for dec, `nil` for only boolean toggle
function M.toggle_nvim_visual_block_mode(direction)
  local cur = M.get_cursor_position()
  cur = M.order_cursor_positions(cur)

  local region = vim.region(
    M.bufnr,
    { cur.from.line, cur.from.col },
    { cur.to.line, cur.to.col },
    "3", -- TODO: why 3 works?
    true
  )

  for linenr = cur.from.line, cur.to.line do
    local line_coords = { from = region[linenr][1], to = region[linenr][2] }
    local full_line = vim.fn.getline(linenr + 1)
    -- TODO: check if this returns the correct region. bytes offset?
    local line_reg = M.get_line(linenr, line_coords.from, line_coords.to)

    if full_line ~= "" and line_reg ~= "" then
      local line_width = vim.api.nvim_strwidth(full_line) -- or lua width?
      local offset = line_width == line_coords.to and 0 or 1
      line_coords.to = line_coords.to + offset

      local replacement = { M.toggle_line(direction, line_reg) }

      vim.api.nvim_buf_set_text(
        M.bufnr,
        linenr,
        line_coords.from,
        linenr,
        line_coords.to,
        replacement
      )
    end
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
