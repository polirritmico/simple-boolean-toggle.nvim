local sbt = require("simple-boolean-toggle.boolean_toggle")
local h = require("tests.helpers")
local eq = assert.equal

sbt.generate_booleans({ { "True", "False" } })
local winid, bufnr

describe("Unit Tests", function()
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
    abcdef = 0
    abcdef = 1
    abcdef = 2
    abcdef = 3
    abcdef = 4
    abcdef = 5
    abcdef = 6
    abcdef = 7
    abcdef = 8
    abcdef = 9
  ]]

  it("[get_line]: Full lines", function()
    h.set_case(bufnr, winid, base_case)

    -- left 0 right last
    eq("abcdef = 0", sbt.get_line(1, 0, 9))
    eq("abcdef = 4", sbt.get_line(5, 0, 9))
    eq("abcdef = 9", sbt.get_line(10, 0, 9))

    -- left 0 right after last
    eq("abcdef = 0", sbt.get_line(1, 0, 10))
    eq("abcdef = 4", sbt.get_line(5, 0, 10))
    eq("abcdef = 9", sbt.get_line(10, 0, 10))

    -- left 0 right -1
    eq("abcdef = 0", sbt.get_line(1, 0, -1))
    eq("abcdef = 4", sbt.get_line(5, 0, -1))
    eq("abcdef = 9", sbt.get_line(10, 0, -1))

    -- left 0 right 0
    eq("a", sbt.get_line(1, 0, 0))
    eq("a", sbt.get_line(5, 0, 0))
    eq("a", sbt.get_line(10, 0, 0))
  end)

  it("[get_line]: Middle region", function()
    h.set_case(bufnr, winid, base_case)

    eq("abc", sbt.get_line(1, 0, 2))
    eq("abc", sbt.get_line(5, 0, 2))
    eq("abc", sbt.get_line(10, 0, 2))

    eq("def ", sbt.get_line(1, 3, 6))
    eq("def ", sbt.get_line(5, 3, 6))
    eq("def ", sbt.get_line(10, 3, 6))

    eq("f = 0", sbt.get_line(1, 5, 9))
    eq("f = 4", sbt.get_line(5, 5, 9))
    eq("f = 9", sbt.get_line(10, 5, 9))

    eq("f = 0", sbt.get_line(1, 5, -1))
    eq("f = 4", sbt.get_line(5, 5, -1))
    eq("f = 9", sbt.get_line(10, 5, -1))

    eq("= 0", sbt.get_line(1, 7, 11))
    eq("= 4", sbt.get_line(5, 7, 11))
    eq("= 9", sbt.get_line(10, 7, 11))

    eq("= 0", sbt.get_line(1, 7, 10))
    eq("= 4", sbt.get_line(5, 7, 10))
    eq("= 9", sbt.get_line(10, 7, 10))

    eq("= 0", sbt.get_line(1, 7, 9))
    eq("= 4", sbt.get_line(5, 7, 9))
    eq("= 9", sbt.get_line(10, 7, 9))

    eq("", sbt.get_line(99, -99, 99))
  end)

  it("[get_line]: right outside region", function()
    h.set_case(bufnr, winid, base_case)

    eq("abcdef = 0", sbt.get_line(1, 0, 10))
    eq("abcdef = 4", sbt.get_line(5, 0, 10))
    eq("abcdef = 9", sbt.get_line(10, 0, 10))

    eq("abcdef = 0", sbt.get_line(1, 0, 11))
    eq("abcdef = 4", sbt.get_line(5, 0, 11))
    eq("abcdef = 9", sbt.get_line(10, 0, 11))

    eq("0", sbt.get_line(1, 9, 10))
    eq("4", sbt.get_line(5, 9, 10))
    eq("9", sbt.get_line(10, 9, 10))

    eq("0", sbt.get_line(1, 9, 11))
    eq("4", sbt.get_line(5, 9, 11))
    eq("9", sbt.get_line(10, 9, 11))
  end)

  it("[get_line]: end line", function()
    h.set_case(bufnr, winid, base_case)
    eq("abcdef = 9", sbt.get_line(10, 0, 10))
    eq("", sbt.get_line(0, 0, 10))
    eq("", sbt.get_line(11, 0, 10))
  end)
end)
