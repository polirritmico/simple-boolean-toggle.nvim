local sbt = require("simple-boolean-toggle.boolean_toggle")
local h = require("tests.helpers")

sbt.generate_booleans({ { "True", "False" } })
local winid, bufnr

describe("Visual mode:", function()
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

  it("First line", function()
    local case = [[
      local foo, bar = 9, true, -1
      local unchanged = false
    ]]
    local expected = h.clean_text_format([[
      local foo, bar = 10, true, -1
      local unchanged = false
    ]])
    h.set_case(bufnr, winid, case)
    h.feedkeys("v$")
    sbt.toggle_nvim_visual_mode(true)
    local output = h.get_buffer_content(bufnr)
    assert.same(expected, output)
  end)

  it("Second line", function()
    local case = [[
      local foo, bar = 9, true, -1
      local unchanged = false
      endline = true
    ]]
    local expected = h.clean_text_format([[
      local foo, bar = 9, true, -1
      local unchanged = true
      endline = true
    ]])
    h.set_case(bufnr, winid, case, { 2, 0 })
    h.feedkeys("v$")
    sbt.toggle_nvim_visual_mode(true)
    local output = h.get_buffer_content(bufnr)
    assert.same(expected, output)
  end)

  it("End line", function()
    local case = [[
      local foo, bar = 9, true, -1
      local unchanged = false
      endline = true
    ]]
    local expected = h.clean_text_format([[
      local foo, bar = 9, true, -1
      local unchanged = false
      endline = false
    ]])
    h.set_case(bufnr, winid, case, { 3, 0 })
    h.feedkeys("v$")
    sbt.toggle_nvim_visual_mode(true)
    local output = h.get_buffer_content(bufnr)
    assert.same(expected, output)
  end)
end)
