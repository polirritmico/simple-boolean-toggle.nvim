---@class SimpleBooleanToggle
local M = {}

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

---Explore the current line from the cursor position and replace the first
---matching word from the booleans table with its opposite.
---The function aims to imitate the builtin <C-a>/<C-x> functionality but in
---addition to increment/decrement the first number, it would toggle between
---the first matching booleans.
---@param mode boolean|nil `true` to increment, `false` to decrement and `nil` to don't modify numbers .
function M.toggle(mode)
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
    if mode ~= nil and (tonumber(cword) or string.match(cword, "%d") ~= nil) then
      if mode then
        return vim.cmd("normal!" .. cmd_count .. "")
      else
        return vim.cmd("normal!" .. cmd_count .. "")
      end
    end

    -- check if cword and curstr are in sync
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

local overwriten_builtins = false

---Set `<C-a>`/`<C-x>` keymaps to the `toggle` function
---@param silent? boolean `true` to avoid notification
function M.overwrite_default_keys(silent)
  if overwriten_builtins then
    return
  end
  overwriten_builtins = true
  vim.keymap.set({ "n", "v" }, "", function() M.toggle(true) end)
  vim.keymap.set({ "n", "v" }, "", function() M.toggle(false) end)
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
