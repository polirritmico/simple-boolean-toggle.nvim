---Helper tests functions
local Helpers = {}

---@param bufnr integer
function Helpers.clear_buffer(bufnr)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {})
end

---@param bufnr integer
function Helpers.get_buffer_content(bufnr)
  return vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
end

---@param text string
---@return table<string>
function Helpers.clean_text_format(text)
  local lines = vim.split(vim.trim(text), "\n")
  lines = vim.tbl_map(function(line)
    return vim.trim(line)
  end, lines)
  return lines
end

---Wrapper for `vim.api.nvim_feedkeys`
---@param keys string to be _pressed_, e.g. "j", "4j", "4j<CR>", etc.
---@param mode string? Note: Defaults to "x". Use "n" to move, "x" to modify content.
function Helpers.feedkeys(keys, mode)
  vim.api.nvim_feedkeys(
    vim.api.nvim_replace_termcodes(keys, true, true, true),
    mode or "x",
    true
  )
end

---Set the text content into the buffer and set the cursor position
---@param bufnr integer
---@param winid integer
---@param text string
---@param position table<integer, integer>? {line (1-idx), col (0-idx)}. Defaults to {1, 0}
function Helpers.set_case(bufnr, winid, text, position)
  position = position or { 1, 0 }
  local lines = Helpers.clean_text_format(text)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  vim.api.nvim_win_set_cursor(winid, position)
end

return Helpers
