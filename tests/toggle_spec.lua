-- Test

local toggle = require("simple-boolean-toggle")

local function clear_buffer() vim.api.nvim_buf_set_lines(1, 0, -1, false, {}) end

---@return table<string>
local function clean_text(text)
  local lines = vim.split(vim.trim(text), "\n")
  lines = vim.tbl_map(function(line) return vim.trim(line) end, lines)
  return lines
end

local function set_case(text, pos)
  local lines = clean_text(text)
  vim.api.nvim_buf_set_lines(1, 0, -1, false, lines)
  vim.api.nvim_win_set_cursor(0, pos or { 1, 0 })
end

local function apply_to_line_range(fun, init_pos, end_pos)
  for linenr = init_pos, end_pos do
    vim.api.nvim_win_set_cursor(0, { linenr, 0 })
    fun()
  end
end

describe("toggle digits tests:", function()
  before_each(clear_buffer)

  it("Basic numbers increase", function()
    set_case([[
      first_line = 99
      second_line = "-1"
      third_line = 99, 100
      fourth_line = !"#$%&/\`-100
    ]])
    local expected = clean_text([[
      first_line = 100
      second_line = "0"
      third_line = 100, 100
      fourth_line = !"#$%&/\`-99
    ]])

    apply_to_line_range(toggle.toggle_inc, 1, 4)

    local output = vim.api.nvim_buf_get_lines(1, 0, -1, false)
    assert.same(expected, output)
  end)
end)
