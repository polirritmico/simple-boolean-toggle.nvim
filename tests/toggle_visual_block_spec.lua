local sbt = require("simple-boolean-toggle.boolean_toggle")
local h = require("tests.helpers")

sbt.generate_booleans({ { "True", "False" } })
local winid, bufnr

describe("Visual-block mode:", function()
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
    abc = { 0, true }
    abc = { 1, true }
    abc = { 2, true }
    abc = { 3, true }
    abc = { 4, true }
  ]]

  it("first_line", function()
    local expected = h.clean_text_format([[
      abc = { 0, false }
      abc = { 1, true }
      abc = { 2, true }
      abc = { 3, true }
      abc = { 4, true }
    ]])
    h.set_case(bufnr, winid, base_case, { 1, 11 })

    h.feedkeys("<C-v>ee")
    sbt.toggle_nvim_visual_block_mode(true)

    local output = h.get_buffer_content(bufnr)
    assert.same(expected, output)
  end)

  it("first line (inverted)", function()
    local expected = h.clean_text_format([[
      abc = { 0, false }
      abc = { 1, true }
      abc = { 2, true }
      abc = { 3, true }
      abc = { 4, true }
    ]])
    h.set_case(bufnr, winid, base_case, { 1, 18 })

    h.feedkeys("<C-v>gege")
    sbt.toggle_nvim_visual_block_mode(true)

    local output = h.get_buffer_content(bufnr)
    assert.same(expected, output)
  end)

  it("Last three block", function()
    local expected = h.clean_text_format([[
      abc = { 0, true }
      abc = { 1, true }
      abc = { 2, false }
      abc = { 3, false }
      abc = { 4, false }
    ]])
    h.set_case(bufnr, winid, base_case, { 3, 11 })

    h.feedkeys("<C-v>jjlll")
    sbt.toggle_nvim_visual_block_mode(true)

    local output = h.get_buffer_content(bufnr)
    assert.same(expected, output)
  end)

  --012345678901234
  local irregular_base = [[
    abc = 111111111
    abc = 11

    abc = 111111
  ]]

  it("irregular selection", function()
    --012345678901234
    local expected = h.clean_text_format([[
      abc = 111111211
      abc = 12

      abc = 111112
    ]])
    h.set_case(bufnr, winid, irregular_base, { 1, 7 })

    h.feedkeys("<C-v>jjjlllll")
    sbt.toggle_nvim_visual_block_mode(true)

    local output = h.get_buffer_content(bufnr)
    assert.same(expected, output)
  end)

  it("irregular selection (inv)", function()
    --012345678901234
    local expected = h.clean_text_format([[
      abc = 111111112
      abc = 12

      abc = 111112
    ]])
    h.set_case(bufnr, winid, irregular_base, { 4, 7 })

    h.feedkeys("<C-v>3k$")
    sbt.toggle_nvim_visual_block_mode(true)

    local output = h.get_buffer_content(bufnr)
    assert.same(expected, output)
  end)
end)
