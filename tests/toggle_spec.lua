-- Test
-- NOTE: local functions use lines 1-index and cols 0-indexed

local toggle = require("simple-boolean-toggle")

local function clear_buffer() vim.api.nvim_buf_set_lines(1, 0, -1, false, {}) end
local function get_buffer_content() return vim.api.nvim_buf_get_lines(1, 0, -1, false) end

---@param text string
---@return table<string>
local function clean_text_format(text)
  local lines = vim.split(vim.trim(text), "\n")
  lines = vim.tbl_map(function(line) return vim.trim(line) end, lines)
  return lines
end

---Set the a clean buffer with the text content at the cursor position
---@param text string
---@param position table<integer, integer>? {line (1-idx), col (0-idx)}. Defaults to { 1, 0 }
local function set_case(text, position)
  position = position and { position[1], position[2] } or { 1, 0 }
  local lines = clean_text_format(text)
  vim.api.nvim_buf_set_lines(1, 0, -1, false, lines)
  vim.api.nvim_win_set_cursor(0, position)
end

---@param keys string keys to be _pressed_, e.g. "j", "4j", "4j<CR>", etc.
---@param mode string? Note: Defaults to "x". Use "n" to move, "x" to modify content.
local function feedkeys(keys, mode)
  vim.api.nvim_feedkeys(
    vim.api.nvim_replace_termcodes(keys, true, true, true),
    mode or "x",
    true
  )
end

describe("[N] Digit inline inc:", function()
  before_each(function()
    clear_buffer()
    toggle.overwrite_builtins()
  end)

  it("At col 0", function()
    set_case([[local foo, bar = 9, -1]])
    local expected = { [[local foo, bar = 10, -1]] }
    feedkeys("<C-a>")
    local output = get_buffer_content()
    assert.same(expected, output)
  end)

  it("At first digit position", function()
    set_case([[local foo, bar = 9, -1]], { 1, 18 })
    local expected = { [[local foo, bar = 9, 0]] }
    feedkeys("<C-a>")
    local output = get_buffer_content()
    assert.same(expected, output)
  end)

  it("After first digit", function()
    set_case([[local foo, bar = 9, -1, 1]], { 1, 18 })
    local expected = { [[local foo, bar = 9, 0, 1]] }
    feedkeys("<C-a>")
    local output = get_buffer_content()
    assert.same(expected, output)
  end)

  it("At last col", function()
    set_case([[local foo, bar = 9, -1, 1]], { 1, 24 })
    local expected = { [[local foo, bar = 9, -1, 2]] }
    feedkeys("<C-a>")
    local output = get_buffer_content()
    assert.same(expected, output)
  end)

  it("In lines", function()
    set_case([[
      first_line = 99
      second_line = "-1"
      third_line = 99, 100
      fourth_line = true
      fifth_line = !"#$%&/\`-100
    ]])
    local expected = clean_text_format([[
      first_line = 100
      second_line = "0"
      third_line = 100, 100
      fourth_line = true
      fifth_line = !"#$%&/\`-99
    ]])
    feedkeys("<C-a>j<C-a>j0<C-a>j0<C-a>j0<C-a>", "x")

    local output = get_buffer_content()
    assert.same(expected, output)
  end)
end)

describe("Visual mode:", function()
  before_each(function()
    clear_buffer()
    toggle.overwrite_builtins()
  end)

  local test_case = [[
      first_line = 99
      second_line = "-1"
      third_line = 99, 100
      fourth_line = true
      fifth_line = !"#$%&/\`-100
    ]]

  it("[visual-mode] Basic numbers increase. One line", function()
    set_case(test_case, { 2, 0 })
    local expected = clean_text_format([[
      first_line = 99
      second_line = "0"
      third_line = 99, 100
      fourth_line = true
      fifth_line = !"#$%&/\`-100
    ]])

    toggle.overwrite_builtins()
    feedkeys("v$", "n")
    feedkeys("<C-a>", "x")

    local output = get_buffer_content()
    assert.same(expected, output)
  end)

  -- it("[visual-mode] Basic numbers increase. Three line", function()
  --   set_case(test_case, { 3, 0 })
  --   local expected = clean_text_format([[
  --     first_line = 99
  --     second_line = "0"
  --     third_line = 100, 100
  --     fourth_line = !"#$%&/\`-99
  --     fifth_line = true
  --   ]])
  --
  --   toggle.overwrite_builtins()
  --   feedkeys("jj$", "v")
  --   feedkeys("<C-a>", "x")
  --
  --   local output = get_buffer_content()
  --   assert.same(expected, output)
  -- end)
  --
  it("[visual-mode] Basic numbers increase. Last line", function()
    set_case(test_case, { 5, 0 })
    local expected = clean_text_format([[
      first_line = 99
      second_line = "-1"
      third_line = 99, 100
      fourth_line = true
      fifth_line = !"#$%&/\`-99
    ]])

    toggle.overwrite_builtins()
    feedkeys("v$", "n")
    feedkeys("<C-a>", "x")

    local output = get_buffer_content()
    assert.same(expected, output)
  end)
end)
