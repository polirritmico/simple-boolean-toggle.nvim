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
      bar = 1
    ]]
    local expected = h.clean_text_format([[
      foo = 0
      bar = 0
    ]])
    h.set_case(bufnr, winid, case)

    sbt.toggle_nvim_normal_mode(true)
    h.feedkeys("j0")
    sbt.toggle_nvim_normal_mode(false)

    local output = h.get_buffer_content(bufnr)
    assert.same(expected, output)
  end)
end)
