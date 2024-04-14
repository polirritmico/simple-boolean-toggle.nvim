local sbt = require("simple-boolean-toggle.boolean_toggle")
local h = require("tests.helpers")

-- sbt.generate_booleans({ { "True", "False" } })
local winid, bufnr

describe("Extended chars", function()
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

  it("nvim_set_buf_text args", function()
    local col_from = 5
    local col_to = 8
    local expected_col_from = 7
    local expected_col_to = 11
    local line = [[ññ   true]]

    local offset = sbt.get_offset(line, col_from, col_to)

    assert.equal(expected_col_from, col_from + offset.left)
    assert.equal(expected_col_to, col_to + offset.left + offset.right)
  end)

  it("1 byte char", function()
    -- ASCII, 1 byte
    local col_from = 5 + 1
    local col_to = 8 + 1

    local line1 = [[a    true]]
    local line2 = [[aa   true]]
    local line3 = [[aaa  true]]
    local line4 = [[aaaa true]]
    local output1 = sbt.get_offset(line1, col_from, col_to)
    local output2 = sbt.get_offset(line2, col_from, col_to)
    local output3 = sbt.get_offset(line3, col_from, col_to)
    local output4 = sbt.get_offset(line4, col_from, col_to)
    assert.equal(0, output1.left)
    assert.equal(0, output2.left)
    assert.equal(0, output3.left)
    assert.equal(0, output4.left)
  end)

  it("2 byte char", function()
    -- Latin-1, 2 bytes
    local col_from = 5 + 1
    local col_to = 8 + 1

    local line1 = [[ñ    true]]
    local line2 = [[ññ   true]]
    local line3 = [[ñññ  true]]
    local line4 = [[ññññ true]]
    local output1 = sbt.get_offset(line1, col_from, col_to)
    local output2 = sbt.get_offset(line2, col_from, col_to)
    local output3 = sbt.get_offset(line3, col_from, col_to)
    local output4 = sbt.get_offset(line4, col_from, col_to)
    assert.equal(1, output1.left)
    assert.equal(2, output2.left)
    assert.equal(3, output3.left)
    assert.equal(4, output4.left)
  end)

  it("3 byte char", function()
    -- Basic Multilingual, 3 bytes
    local col_from = 5 + 1
    local col_to = 8 + 1

    local line1 = [[⛗    true]]
    local line2 = [[⛗⛗   true]]
    local line3 = [[⛗⛗⛗  true]]
    local line4 = [[⛗⛗⛗⛗ true]]
    local output1 = sbt.get_offset(line1, col_from, col_to)
    local output2 = sbt.get_offset(line2, col_from, col_to)
    local output3 = sbt.get_offset(line3, col_from, col_to)
    local output4 = sbt.get_offset(line4, col_from, col_to)
    assert.equal(1, output1.left)
    assert.equal(2, output2.left)
    assert.equal(3, output3.left)
    -- FIX: This should be working:
    -- assert.equal(4, output4.left)
  end)

  it("4 byte char", function()
    -- Supplementary, 4 bytes
    local col_from = 5 + 1
    local col_to = 8 + 1

    local line1 = [[🌗    true]]
    local line2 = [[🌗🌗   true]]
    local line3 = [[🌗🌗🌗  true]]
    local line4 = [[🌗🌗🌗🌗 true]]

    local output1 = sbt.get_offset(line1, col_from, col_to)
    local output2 = sbt.get_offset(line2, col_from, col_to)
    local output3 = sbt.get_offset(line3, col_from, col_to)
    local output4 = sbt.get_offset(line4, col_from, col_to)
    assert.equal(1, output1.left)
    assert.equal(2, output2.left)
    assert.equal(3, output3.left)
    assert.equal(4, output4.left)
  end)
end)

-- describe("Extended chars", function()
--   before_each(function()
--     winid = vim.api.nvim_get_current_win()
--     bufnr = vim.api.nvim_create_buf(false, true)
--     sbt.winid = winid
--     sbt.bufnr = bufnr
--     vim.api.nvim_win_set_buf(winid, bufnr)
--   end)
--
--   after_each(function()
--     h.clear_buffer(bufnr)
--   end)
--
--   local base_case = [[
--     foo = "🛠️  true"
--     foo = "🛠️ false"
--     foo = 🛠️ 99
--     foo = 🛠️ -1
--     foo = 🛠️ true, -1
--     foo = { false, 🛠️, true, 0 }
--     foo = { false, 🛠️, true, 0 }
--   ]]
--
--   it("toggle normal", function()
--     local expected = h.clean_text_format([[
--       foo = "🛠️  false"
--       foo = "🛠️ true"
--       foo = 🛠️ 100
--       foo = 🛠️ 0
--       foo = 🛠️ false, -1
--       foo = { true, 🛠️, false, -1 }
--       foo = { false, 🛠️, true, 0 }
--     ]])
--     h.set_case(bufnr, winid, base_case)
--
--     sbt.toggle_nvim_normal_mode(true)
--     h.feedkeys("j0")
--     sbt.toggle_nvim_normal_mode(true)
--     h.feedkeys("j0")
--     sbt.toggle_nvim_normal_mode(true)
--     h.feedkeys("j0")
--     sbt.toggle_nvim_normal_mode(true)
--     h.feedkeys("j0")
--     sbt.toggle_nvim_normal_mode(true)
--     h.feedkeys("j0")
--
--     sbt.toggle_nvim_normal_mode(false)
--     h.feedkeys("w")
--     sbt.toggle_nvim_normal_mode(false)
--     h.feedkeys("w")
--     sbt.toggle_nvim_normal_mode(false)
--
--     local output = h.get_buffer_content(bufnr)
--     assert.same(expected, output)
--   end)
--
--   local visual_mode_base_case = [[
--     foo = { false, 🛠️, true, 0 }
--     foo = { false, 🛠️, true, 0 }
--     foo = { true, 🛠️, true, 0 }
--     foo = { false, 🛠️, true, 0 }
--   ]]
--
--   it("toggle visual-line mode", function()
--     local expected = h.clean_text_format([[
--       foo = { true, 🛠️, true, 0 }
--       foo = { true, 🛠️, true, 0 }
--       foo = { false, 🛠️, true, 0 }
--       foo = { true, 🛠️, true, 0 }
--     ]])
--     h.set_case(bufnr, winid, visual_mode_base_case)
--
--     sbt.toggle_nvim_visual_line_mode(false)
--     h.feedkeys("<ESC>j")
--     sbt.toggle_nvim_visual_line_mode(false)
--     h.feedkeys("<ESC>j")
--     sbt.toggle_nvim_visual_line_mode(false)
--     h.feedkeys("<ESC>j")
--     sbt.toggle_nvim_visual_line_mode(false)
--
--     local output = h.get_buffer_content(bufnr)
--     assert.same(expected, output)
--   end)
--
--   it("toggle visual mode (same line)", function()
--     --012345678901234567890123456
--     local expected = h.clean_text_format([[
--       foo = { true, 🛠️, false, 0 }
--       foo = { true, 🛠️, true, 0 }
--       foo = { false, 🛠️, true, 0 }
--       foo = { true, 🛠️, true, 0 }
--     ]])
--     h.set_case(bufnr, winid, visual_mode_base_case, { 1, 18 })
--
--     h.feedkeys("vww")
--     sbt.toggle_nvim_normal_mode(true)
--
--     local output = h.get_buffer_content(bufnr)
--     assert.same(expected, output)
--   end)
--
--   -- it("toggle visual mode (two lines)", function()
--   --   --012345678901234567890123456
--   --   local expected = h.clean_text_format([[
--   --     foo = { true, 🛠️, false, 0 }
--   --     foo = { false, 🛠️, true, 0 }
--   --     foo = { false, 🛠️, true, 0 }
--   --     foo = { true, 🛠️, true, 0 }
--   --   ]])
--   --   h.set_case(bufnr, winid, visual_mode_base_case, { 1, 18 })
--   --
--   --   h.feedkeys("vj")
--   --   sbt.toggle_nvim_normal_mode(true)
--   --
--   --   local output = h.get_buffer_content(bufnr)
--   --   assert.same(expected, output)
--   -- end)
-- end)
