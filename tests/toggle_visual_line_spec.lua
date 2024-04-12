local sbt = require("simple-boolean-toggle.boolean_toggle")
local h = require("tests.helpers")

sbt.generate_booleans({ { "True", "False" } })
local winid, bufnr

describe("Visual-line mode:", function()
  before_each(function()
    winid = vim.api.nvim_get_current_win()
    bufnr = vim.api.nvim_create_buf(false, true)
    sbt.winid = winid
    sbt.bufnr = bufnr
    vim.api.nvim_win_set_buf(winid, bufnr)
  end)

  after_each(function()
    h.clear_buffer(bufnr)
  end)

  local base_case = [[
    abcdef = 99
    abcdef = -99
    abcdef = true
    abcdef = false
    abcdef = 0, -1
    abcdef = -1, 0
    abcdef = true, true
    abcdef = false, false
  ]]

  it("first three lines (individually)", function()
    local expected = h.clean_text_format([[
      abcdef = 100
      abcdef = -98
      abcdef = false
      abcdef = false
      abcdef = 0, -1
      abcdef = -1, 0
      abcdef = true, true
      abcdef = false, false
    ]])
    h.set_case(bufnr, winid, base_case)

    h.feedkeys("<S-v>")
    sbt.toggle_nvim_visual_line_mode(true)
    h.feedkeys("<ESC>")
    h.feedkeys("j$<S-v>")
    sbt.toggle_nvim_visual_line_mode(true)
    h.feedkeys("<ESC>")
    h.feedkeys("j0w<S-v>")
    sbt.toggle_nvim_visual_line_mode(true)

    local output = h.get_buffer_content(bufnr)
    assert.same(expected, output)
  end)

  it("last line", function()
    local expected = h.clean_text_format([[
    abcdef = 99
    abcdef = -99
    abcdef = true
    abcdef = false
    abcdef = 0, -1
    abcdef = -1, 0
    abcdef = true, true
    abcdef = true, false
    ]])
    h.set_case(bufnr, winid, base_case)

    h.feedkeys("G<S-v>")
    sbt.toggle_nvim_visual_line_mode(true)

    local output = h.get_buffer_content(bufnr)
    assert.same(expected, output)
  end)

  it("first three lines", function()
    local expected = h.clean_text_format([[
      abcdef = 100
      abcdef = -98
      abcdef = false
      abcdef = false
      abcdef = 0, -1
      abcdef = -1, 0
      abcdef = true, true
      abcdef = false, false
    ]])
    h.set_case(bufnr, winid, base_case)

    h.feedkeys("<S-v>jj")
    sbt.toggle_nvim_visual_line_mode(true)

    local output = h.get_buffer_content(bufnr)
    assert.same(expected, output)
  end)

  it("last three lines btm -> top", function()
    local expected = h.clean_text_format([[
      abcdef = 99
      abcdef = -99
      abcdef = true
      abcdef = false
      abcdef = 0, -1
      abcdef = 0, 0
      abcdef = false, true
      abcdef = true, false
    ]])
    h.set_case(bufnr, winid, base_case)

    h.feedkeys("G<S-v>kk")
    sbt.toggle_nvim_visual_line_mode(true)

    local output = h.get_buffer_content(bufnr)
    assert.same(expected, output)
  end)

  it("last three lines top -> btm", function()
    local expected = h.clean_text_format([[
      abcdef = 99
      abcdef = -99
      abcdef = true
      abcdef = false
      abcdef = 0, -1
      abcdef = 0, 0
      abcdef = false, true
      abcdef = true, false
    ]])
    h.set_case(bufnr, winid, base_case, { 6, 0 })

    h.feedkeys("<S-v>jj")
    sbt.toggle_nvim_visual_line_mode(true)

    local output = h.get_buffer_content(bufnr)
    assert.same(expected, output)
  end)
end)
