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

  it("Full first line", function()
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

  it("Full second line", function()
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

  it("Full last line", function()
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

  it("Full first line (rev)", function()
    local case = [[
      local foo, bar = 9, true, -1
      local unchanged = false
    ]]
    local expected = h.clean_text_format([[
      local foo, bar = 10, true, -1
      local unchanged = false
    ]])
    h.set_case(bufnr, winid, case)
    h.feedkeys("$v0")
    sbt.toggle_nvim_visual_mode(true)
    local output = h.get_buffer_content(bufnr)
    assert.same(expected, output)
  end)

  it("Full second line (rev)", function()
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
    h.feedkeys("$v0")
    sbt.toggle_nvim_visual_mode(true)
    local output = h.get_buffer_content(bufnr)
    assert.same(expected, output)
  end)

  it("Full last line (rev)", function()
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
    h.feedkeys("$v0")
    sbt.toggle_nvim_visual_mode(true)
    local output = h.get_buffer_content(bufnr)
    assert.same(expected, output)
  end)

  it("Select partial boolean", function()
    local case = [[
      local foo, bar = 9, true, -1
      local unchanged = false
    ]]
    local expected = h.clean_text_format([[
      local foo, bar = 9, true, -1
      local unchanged = false
    ]])
    h.set_case(bufnr, winid, case, { 1, 21 })
    h.feedkeys("v2l")
    sbt.toggle_nvim_visual_mode(true)
    local output = h.get_buffer_content(bufnr)
    assert.same(expected, output)
  end)

  it("Select partial boolean (rev)", function()
    local case = [[
      local foo, bar = 9, true, -1
      local unchanged = false
    ]]
    local expected = h.clean_text_format([[
      local foo, bar = 9, true, -1
      local unchanged = false
    ]])
    h.set_case(bufnr, winid, case, { 1, 23 })
    h.feedkeys("v2h")
    sbt.toggle_nvim_visual_mode(true)
    local output = h.get_buffer_content(bufnr)
    assert.same(expected, output)
  end)

  it("Select boolean", function()
    local case = [[
      local foo, bar = 9, true, -1
      local unchanged = false
    ]]
    local expected = h.clean_text_format([[
      local foo, bar = 9, false, -1
      local unchanged = false
    ]])
    h.set_case(bufnr, winid, case, { 1, 18 })
    h.feedkeys("vf,")
    sbt.toggle_nvim_visual_mode(true)
    local output = h.get_buffer_content(bufnr)
    assert.same(expected, output)
  end)

  it("Select boolean (rev)", function()
    local case = [[
      local foo, bar = 9, true, -1
      local unchanged = false
    ]]
    local expected = h.clean_text_format([[
      local foo, bar = 9, false, -1
      local unchanged = false
    ]])
    h.set_case(bufnr, winid, case, { 1, 26 })
    h.feedkeys("vbbh")
    sbt.toggle_nvim_visual_mode(true)
    local output = h.get_buffer_content(bufnr)
    assert.same(expected, output)
  end)

  it("Select booleans in two lines", function()
    local case = [[
      line = true, 99
      line = false, 99
      foo = true, -99
      bar = true, 99
    ]]
    local expected = h.clean_text_format([[
      line = false, 99
      line = true, 99
      foo = true, -99
      bar = true, 99
    ]])
    h.set_case(bufnr, winid, case, { 1, 7 })
    h.feedkeys("vjw")
    sbt.toggle_nvim_visual_mode(true)
    local output = h.get_buffer_content(bufnr)
    assert.same(expected, output)
  end)

  it("Select negative with and without minus", function()
    local case = [[
      line = false, 99
      foo = true, -100
      bar = some, -100
      buz = 0
    ]]
    local expected = h.clean_text_format([[
      line = false, 99
      foo = true, -101
      bar = some, -99
      buz = 0
    ]])
    h.set_case(bufnr, winid, case, { 2, 13 })
    h.feedkeys("vj$")
    sbt.toggle_nvim_visual_mode(true)
    local output = h.get_buffer_content(bufnr)
    assert.same(expected, output)
  end)
end)

describe("Visual mode (reverse):", function()
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

  it("Select from last pos to line above", function()
    local case = [[
      a    true
      aa   true
      aaa  true
      aaaa true
    ]]
    local expected = h.clean_text_format([[
      a    true
      aa   true
      aaa  false
      aaaa false
    ]])
    h.set_case(bufnr, winid, case, { 4, 9 })
    h.feedkeys("vbk")
    sbt.toggle_nvim_visual_mode(true)
    local output = h.get_buffer_content(bufnr)
    assert.same(expected, output)
  end)

  it("Select from last pos to smaller line above", function()
    local case = [[
      a    true
      aa   true
      aaa  true
      aaaa false
    ]]
    local expected = h.clean_text_format([[
      a    true
      aa   true
      aaa  false
      aaaa true
    ]])
    h.set_case(bufnr, winid, case, { 4, 9 })
    h.feedkeys("vkk")
    sbt.toggle_nvim_visual_mode(true)
    local output = h.get_buffer_content(bufnr)
    assert.same(expected, output)
  end)
end)
