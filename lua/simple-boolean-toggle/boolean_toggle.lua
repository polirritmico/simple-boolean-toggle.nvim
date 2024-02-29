local M = {}

---@type table The `key` is a boolean value string, and the `value` its opposite.
M.booleans = {}

---@type boolean Enable/Disable the default `<C-a>`/`<C-x>` builtin behavior.
M.enabled_builtin = true

---Populates the inner `booleans` table with the base strings and the upper and
---lower case variants if they are enabled. The first boolean after the opposite
---string (the third element) means adding the uppercase and the last one adding
---the lowercase variants.
---@param base_booleans table<string, string, boolean?, boolean?>
function M.generate_booleans(base_booleans)
  for _, tbl in pairs(base_booleans) do
    local opts = tbl[3] or {}
    local uppercase = opts.uppercase == nil or opts.uppercase == true
    local lowercase = opts.lowercase == nil or opts.lowercase == true

    M.booleans[tbl[1]] = tbl[2]
    M.booleans[tbl[2]] = tbl[1]
    if uppercase then
      M.booleans[tbl[1]:upper()] = tbl[2]:upper()
      M.booleans[tbl[2]:upper()] = tbl[1]:upper()
    end
    if lowercase then
      M.booleans[tbl[1]:lower()] = tbl[2]:lower()
      M.booleans[tbl[2]:lower()] = tbl[1]:lower()
    end
  end
end

---Explore the current line from the cursor position and replace the first
---matching word from the booleans table with its opposite.
---The function aims to imitate the builtin <C-a>/<C-x> functionality but in
---addition to increment/decrement the first number, it would toggle between
---the first matching booleans.
---@param increment boolean Pass `true` to increment, `false` otherwise.
function M.toggle(increment)
  local cmd_count = vim.v.count > 1 and vim.v.count or ""
  local original_position = vim.api.nvim_win_get_cursor(0)
  local line = vim.api.nvim_get_current_line()
  local line_size = vim.fn.strlen(line)

  local current_line = original_position[1]
  local current_char_pos = original_position[2] -- cursor col is 0 index
  local curstr = ""
  local cword = ""

  -- `cword` is taken from `:h cword`. It should be the word under the cursor,
  -- but if e.g., the cursor is in the space before the word or over some symbol
  -- like " or =, then it would also include the next word. Thats why `curstr`
  -- is needed. `curstr` would actually show what is under the cursor. However,
  -- the problem is that it also includes other symbols surrounding the word.
  -- This is why we need both to be in sync to ensure the cursor is over the
  -- correct word and apply the `"_ciw` command where appropriate.
  local function cword_and_curstr_match()
    return curstr ~= "" and string.find(cword, curstr)
  end

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

  update_current_words()
  local max_loops_counter = 0
  while remaining_chars_to_check_in_line() do
    if M.enabled_builtin and number_in_word(cword) then
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

local enabled = false

---Set `<C-a>`/`<C-x>` keymaps to the `toggle` function
function M.overwrite_default_keys()
  enabled = true
  vim.keymap.set({ "n", "v" }, "", function() M.toggle(true) end)
  vim.keymap.set({ "n", "v" }, "", function() M.toggle(false) end)
end

---Unset `<C-a>`/`<C-x>` keymaps, returning them to the default behaviour
function M.restore_default_keys()
  enabled = false
  vim.keymap.del({ "n", "v" }, "")
  vim.keymap.del({ "n", "v" }, "")
end

---Enable/Disable the custom toggle
function M.toggle_the_toggle()
  if enabled then
    M.restore_default_keys()
  else
    M.overwrite_default_keys()
  end
end

return M
