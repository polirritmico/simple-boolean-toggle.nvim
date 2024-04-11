local sbt = require("simple-boolean-toggle.boolean_toggle")
local h = require("tests.helpers")

sbt.generate_booleans({ { "True", "False" } })
local winid, bufnr

describe("Normal mode:", function()
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

  it("At col 0 inc digit", function()
    local case = [[local foo, bar = 9, -1]]
    local expected = { [[local foo, bar = 10, -1]] }
    h.set_case(bufnr, winid, case)
    sbt.toggle_nvim_normal_mode(true)
    local output = h.get_buffer_content(bufnr)
    assert.same(expected, output)
  end)

  it("At col 0 dec digit", function()
    local case = [[local foo, bar = 10, -1]]
    local expected = { [[local foo, bar = 9, -1]] }
    h.set_case(bufnr, winid, case)
    sbt.toggle_nvim_normal_mode(false)
    local output = h.get_buffer_content(bufnr)
    assert.same(expected, output)
  end)

  it("At col 0 toggle boolean", function()
    local case = [[local foo = false]]
    local expected = { [[local foo = true]] }
    h.set_case(bufnr, winid, case)

    sbt.toggle_nvim_normal_mode()

    local output = h.get_buffer_content(bufnr)
    assert.same(expected, output)
  end)

  it("At col 0 inc/dec negative numbers", function()
    local case = [[
      foo = -1
      bar = -10
      foo = 0
      bar = -9
    ]]
    local expected = h.clean_text_format([[
      foo = 0
      bar = -9
      foo = -1
      bar = -10
    ]])
    h.set_case(bufnr, winid, case)

    sbt.toggle_nvim_normal_mode(true)
    h.feedkeys("j0")
    sbt.toggle_nvim_normal_mode(true)
    h.feedkeys("j0")
    sbt.toggle_nvim_normal_mode(false)
    h.feedkeys("j0")
    sbt.toggle_nvim_normal_mode(false)

    local output = h.get_buffer_content(bufnr)
    assert.same(expected, output)
  end)

  it("Last line boolean", function()
    local case = [[
      foo = 1
      bar = 2
      buz = true
    ]]
    local expected = h.clean_text_format([[
      foo = 1
      bar = 2
      buz = false
    ]])
    h.set_case(bufnr, winid, case, { 3, 0 })

    sbt.toggle_nvim_normal_mode()

    local output = h.get_buffer_content(bufnr)
    assert.same(expected, output)
  end)

  it("At first digit", function()
    local case = [[local foo, bar = 10, -1]]
    local expected = h.clean_text_format([[local foo, bar = 9, -1]])
    h.set_case(bufnr, winid, case, { 1, 18 })

    sbt.toggle_nvim_normal_mode(false)

    local output = h.get_buffer_content(bufnr)
    assert.same(expected, output)
  end)

  it("After first digit", function()
    local case = [[local foo, bar = 10, -1]]
    local expected = h.clean_text_format([[local foo, bar = 10, 0]])
    h.set_case(bufnr, winid, case, { 1, 19 })

    sbt.toggle_nvim_normal_mode(true)

    local output = h.get_buffer_content(bufnr)
    assert.same(expected, output)
  end)

  it("At last col", function()
    local case = [[local foo, bar = 9, -1, 1]]
    local expected = h.clean_text_format([[local foo, bar = 9, -1, 2]])
    h.set_case(bufnr, winid, case, { 1, 24 })
    sbt.toggle_nvim_normal_mode(true)
    local output = h.get_buffer_content(bufnr)
    assert.same(expected, output)
  end)

  it("At the middle of a boolean", function()
    local case = [[local foo, bar = 9, False, 1]]
    local expected = h.clean_text_format([[local foo, bar = 9, True, 1]])
    h.set_case(bufnr, winid, case, { 1, 23 })
    sbt.toggle_nvim_normal_mode(true)
    local output = h.get_buffer_content(bufnr)
    assert.same(expected, output)
  end)

  it("Lot of cases", function()
    local case = [[
      99
      -1
      101, 100
      true
      99
      !"#$%&/\`-99"
      asdfkl599asdjfklasdf
    ]]
    local expected = h.clean_text_format([[
      100
      0
      100, 100
      false
      99
      !"#$%&/\`-100"
      asdfkl600asdjfklasdf
    ]])
    h.set_case(bufnr, winid, case)

    sbt.toggle_nvim_normal_mode(true)
    h.feedkeys("j0")
    sbt.toggle_nvim_normal_mode(true)
    h.feedkeys("j0")
    sbt.toggle_nvim_normal_mode(false)
    h.feedkeys("j0")
    sbt.toggle_nvim_normal_mode(true)
    h.feedkeys("j0")
    sbt.toggle_nvim_normal_mode()
    h.feedkeys("j0")
    sbt.toggle_nvim_normal_mode(false)
    h.feedkeys("j0")
    sbt.toggle_nvim_normal_mode(true)

    local output = h.get_buffer_content(bufnr)
    assert.same(expected, output)
  end)

  it("Cursor position after toggle", function()
    local case = [[local foo, bar = 100, -1]]
    local expected_pos = { 1, 18 }
    h.set_case(bufnr, winid, case)
    sbt.toggle_nvim_normal_mode(false)
    local output_pos = vim.api.nvim_win_get_cursor(winid)
    assert.same(expected_pos, output_pos)
  end)
end)
