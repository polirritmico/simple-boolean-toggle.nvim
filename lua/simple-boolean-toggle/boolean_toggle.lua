---@class SimpleBooleanToggle
local M = {}

---A dictionary containing boolean values and their opposites.
---Each `key` is a boolean string, and its corresponding `value` is its opposite.
---For example: `{ "true": "false" }`. Usage: `M.booleans["true"]` -> `"false"`.
---@type { [string]: string }
M.booleans = {}

M.winid = 0
M.bufnr = 0

--- Gets a dict of line segment ("chunk") positions for the region from `pos1` to `pos2`.
---
--- Input and output positions are byte positions, (0,0)-indexed. "End of line" column
--- position (for example, |linewise| visual selection) is returned as |v:maxcol| (big number).
---
---@param bufnr integer Buffer number, or 0 for current buffer
---@param _pos1 integer[]|string Start of region as a (line, column) tuple or |getpos()|-compatible string
---@param _pos2 integer[]|string End of region as a (line, column) tuple or |getpos()|-compatible string
---@param regtype string [setreg()]-style selection type
---@param inclusive boolean Controls whether the ending column is inclusive (see also 'selection').
---@return table region Dict of the form `{linenr = {startcol,endcol}}`. `endcol` is exclusive, and
---whole lines are returned as `{startcol,endcol} = {0,-1}`.
function M.region(bufnr, _pos1, _pos2, regtype, inclusive)
  if not vim.api.nvim_buf_is_loaded(bufnr) then
    vim.fn.bufload(bufnr)
  end

  local pos1 = vim.deepcopy(_pos1)
  local pos2 = vim.deepcopy(_pos2)

  if type(pos1) == "string" then
    local pos = vim.fn.getpos(pos1)
    pos1 = { pos[2] - 1, pos[3] - 1 }
  end
  if type(pos2) == "string" then
    local pos = vim.fn.getpos(pos2)
    pos2 = { pos[2] - 1, pos[3] - 1 }
  end

  if pos1[1] > pos2[1] or (pos1[1] == pos2[1] and pos1[2] > pos2[2]) then
    pos1, pos2 = pos2, pos1
  end

  -- getpos() may return {0,0,0,0}
  if pos1[1] < 0 or pos1[2] < 0 then
    return {}
  end

  -- check that region falls within current buffer
  local buf_line_count = vim.api.nvim_buf_line_count(bufnr)
  pos1[1] = math.min(pos1[1], buf_line_count - 1)
  pos2[1] = math.min(pos2[1], buf_line_count - 1)

  -- in case of block selection, columns need to be adjusted for non-ASCII characters
  -- TODO: handle double-width characters
  if regtype:byte() == 22 then
    local bufline = vim.api.nvim_buf_get_lines(bufnr, pos1[1], pos1[1] + 1, true)[1]
    pos1[2] = vim.str_utfindex(bufline, pos1[2])
  end

  local region = {}
  for l = pos1[1], pos2[1] do
    local c1 --- @type number
    local c2 --- @type number
    if regtype:byte() == 22 then -- block selection: take width from regtype
      c1 = pos1[2]
      c2 = c1 + tonumber(regtype:sub(2))
      -- and adjust for non-ASCII characters
      local bufline = vim.api.nvim_buf_get_lines(bufnr, l, l + 1, true)[1]
      local utflen = vim.str_utfindex(bufline, #bufline)
      if c1 <= utflen then
        c1 = assert(tonumber(vim.str_byteindex(bufline, c1)))
      else
        c1 = #bufline + 1
      end
      if c2 <= utflen then
        c2 = assert(tonumber(vim.str_byteindex(bufline, c2)))
      else
        c2 = #bufline + 1
      end
    elseif regtype == "V" then -- linewise selection, always return whole line
      c1 = 0
      c2 = -1
    else
      c1 = (l == pos1[1]) and pos1[2] or 0
      if inclusive and l == pos2[1] then
        local bufline = vim.api.nvim_buf_get_lines(bufnr, pos2[1], pos2[1] + 1, true)[1]
        pos2[2] = vim.fn.byteidx(bufline, vim.fn.charidx(bufline, pos2[2]) + 1)
      end
      c2 = (l == pos2[1]) and pos2[2] or -1
      -- c2 = pos2[2]
    end
    table.insert(region, l, { c1, c2 })
  end
  return region
end

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
---@param linenr integer 1-index
---@param left integer 0-index
---@param right integer 0-index, values -1 and 0 return the full line
function M.get_line(linenr, left, right)
  if left == 0 and right == -1 then
    return vim.fn.getline(linenr)
  elseif right == -1 then
    return vim.fn.getline(linenr):sub(left + 1)
  else
    return vim.fn.getline(linenr):sub(left + 1, right + 1)
  end
end

---@param direction boolean|nil `true` for inc, `false` for dec, `nil` for only boolean toggle
function M.toggle_nvim_visual_mode(direction)
  -- nvim_win_get_cursor output: [1] line (1-idx), [2] col (0-idx)
  local selected_to = vim.api.nvim_win_get_cursor(M.winid)
  vim.api.nvim_feedkeys("o", "x", true)
  local selected_from = vim.api.nvim_win_get_cursor(M.winid)
  vim.api.nvim_feedkeys("o", "x", true)

  ---@type integer, integer, integer, integer
  local lnum_from, lnum_to, col_from, col_to

  -- Selection could be "normal", same line or inverted (right to left and/or bottom to top)
  if selected_from[1] < selected_to[1] then
    lnum_from, lnum_to = selected_from[1], selected_to[1]
    col_from, col_to = selected_from[2], selected_to[2]
  elseif selected_from[1] > selected_to[1] then
    lnum_from, lnum_to = selected_to[1], selected_from[1]
    col_from, col_to = selected_to[2], selected_from[2]
  elseif selected_from[1] == selected_to[1] then
    lnum_from, lnum_to = selected_from[1], selected_to[1]
    if selected_from[2] < selected_to[2] then
      col_from, col_to = selected_from[2], selected_to[2]
    else
      col_from, col_to = selected_to[2], selected_from[2]
    end
  end

  -- region input/output are 0-idx for lines and cols
  local _pos1, _pos2 = { lnum_from - 1, col_from }, { lnum_to - 1, col_to }
  local region = vim.region(M.bufnr, _pos1, _pos2, "v", false)

  local replacement = {}
  for linenr = lnum_from, lnum_to do
    local line = M.get_line(linenr, region[linenr - 1][1], region[linenr - 1][2])
    line = M.toggle_line(direction, line)
    table.insert(replacement, line)
  end

  local last_line_str = vim.fn.getline(lnum_to)
  local last_select_line_width = vim.api.nvim_strwidth(last_line_str)

  -- when using multi-byte characters the width of the col_to needs to be adjusted
  local offset = M.get_offset(last_line_str, region[lnum_to - 1][1], col_to)
  P(offset)

  -- To avoid errors col_to needs to be adjusted when the cursor is outside the
  -- last line width.
  -- if offset.left == 0 then
  --   col_to = math.min(col_to + 1, last_select_line_width)
  -- else
  --   col_to = col_to + offset.left + offset.right
  -- end

  col_to = math.min(col_to + 1, last_select_line_width)
  col_to = col_to + offset.left

  -- 0-idx. lines are end-inclusive, and cols idx are end-exclusive.
  vim.api.nvim_buf_set_text(
    M.bufnr,
    lnum_from - 1,
    col_from,
    lnum_to - 1,
    col_to,
    replacement
  )
end

---@param line string
---@param col_from integer
---@param col_to integer
---@return { left: integer, right: integer } -- left/right: text to the left/right, outside the selection
function M.get_offset(line, col_from, col_to)
  local line_width = vim.api.nvim_strwidth(line)
  local line_width_lua = string.len(line)
  if line_width_lua - line_width == 0 then
    return { left = 0, right = 0 }
  end

  local function section_offset(left, right)
    local subline = line:sub(left, right)
    local width = vim.api.nvim_strwidth(subline)
    local bytes = string.len(subline)
    return bytes - width
  end

  local before_offset = col_from > 1 and section_offset(1, col_from) or 0
  local inner_offset = section_offset(col_from, col_to)
  -- TODO: Remove after?
  local after_offset = col_to ~= line_width and section_offset(col_to, line_width) or 0

  assert(line_width + before_offset + inner_offset + after_offset == line_width_lua)
  return { left = before_offset, right = inner_offset }
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
  -- col and line are 1-idx
  local select_from = vim.fn.getpos("v")
  local select_to = vim.fn.getpos(".")

  ---@type integer, integer, integer, integer
  local lnum_from, lnum_to, col_from, col_to

  -- Order selection coords from top to btm and left to right
  lnum_from = select_from[2] < select_to[2] and select_from[2] or select_to[2]
  lnum_to = select_from[2] < select_to[2] and select_to[2] or select_from[2]
  col_from = select_from[3] < select_to[3] and select_from[3] or select_to[3]
  col_to = select_from[3] < select_to[3] and select_to[3] or select_from[3]

  for linenr = lnum_from, lnum_to do
    local line = vim.fn.getline(linenr)
    local line_width = vim.api.nvim_strwidth(line)
    local line_col_to = col_to > line_width and line_width or col_to

    local region = line:sub(col_from, line_col_to)
    if region ~= "" then
      local replacement = { M.toggle_line(direction, region) }

      vim.api.nvim_buf_set_text(
        M.bufnr,
        linenr - 1,
        col_from - 1,
        linenr - 1,
        line_col_to,
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
