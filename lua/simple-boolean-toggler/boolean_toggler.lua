local M = {}

M.booleans = {}

---Populates the inner `booleans` table with the upper and lower case variants.
---@param base_booleans table Array-list like table with an array of two oposite string values
function M.generate_booleans(base_booleans, opts)
  for _, tbl in pairs(base_booleans) do
    M.booleans[tbl[1]] = tbl[2]
    M.booleans[tbl[2]] = tbl[1]
    if opts.uppercase then
      M.booleans[tbl[1]:upper()] = tbl[2]:upper()
      M.booleans[tbl[2]:upper()] = tbl[1]:upper()
    end
    if opts.lowercase then
      M.booleans[tbl[1]:lower()] = tbl[2]:lower()
      M.booleans[tbl[2]:lower()] = tbl[1]:lower()
    end
  end
end

---@param increment boolean
function M.toggle(increment)
  -- TODO: Avoid messing with the register, `u` is storing all the movements?
  local cmd_count = vim.v.count > 1 and vim.v.count or ""
  local original_position = vim.api.nvim_win_get_cursor(0)
  local line = vim.api.nvim_get_current_line()
  local line_size = vim.fn.strlen(line)

  local current_line = original_position[1]
  local current_char_pos = original_position[2] -- cursor col is 0 index
  local curstr = ""
  local cword = ""

  local function update_current_words()
    local current_pos = vim.api.nvim_win_get_cursor(0)
    current_line = current_pos[1]
    current_char_pos = current_pos[2]
    curstr = vim.fn.matchstr(line, "\\k*", current_char_pos)
    cword = vim.fn.expand("<cword>")
  end

  local function remaining_chars_to_check_in_line()
    return current_char_pos + 1 <= line_size and current_line == original_position[1]
  end

  local function next_cursor_position()
    vim.cmd("normal! w")
    update_current_words()
  end

  local function number_in_word(str)
    return tonumber(str) or string.match(str, "%d") ~= nil
  end

  local function cword_and_curstr_match()
    return curstr ~= "" and string.find(cword, curstr)
  end

  update_current_words()
  local max_loops_counter = 0
  while remaining_chars_to_check_in_line() do
    if number_in_word(cword) then
      if increment then
        return vim.cmd("normal!" .. cmd_count .. "")
      else
        return vim.cmd("normal!" .. cmd_count .. "")
      end
    end

    if cword_and_curstr_match() then
      local opposite = M.booleans[cword]
      if opposite then
        vim.cmd('normal! "_ciw' .. opposite)
        return
      end
    end

    next_cursor_position()

    max_loops_counter = max_loops_counter + 1
    if max_loops_counter > 300 then
      vim.notify("Toggle boolean: Maximum loops reached", vim.log.levels.WARN)
      break
    end
  end
  vim.api.nvim_win_set_cursor(0, original_position)
end

function M.toggle_inc()
  M.toggle(true)
end

function M.toggle_dec()
  M.toggle(false)
end

local enabled = false

function M.wrap_default_keys()
  enabled = true
  vim.keymap.set({ "n", "v" }, "", M.toggle_inc)
  vim.keymap.set({ "n", "v" }, "", M.toggle_dec)
end

function M.restore_default_keys()
  enabled = false
  -- TODO: How to restore this?
  vim.keymap.del({ "n", "v" }, "")
  vim.keymap.del({ "n", "v" }, "")
end

function M.toggle_toggler()
  if enabled then
    M.restore_default_keys()
  else
    M.wrap_default_keys()
  end
end

return M
