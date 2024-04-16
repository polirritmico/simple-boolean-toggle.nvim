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

  -- it("4 byte char double width", function()
  --   -- Supplementary, 4 bytes
  --   local selection = {
  --     from = { line = 1, col = 5 },
  --     to = { line = 1, col = 8 },
  --   }
  --   local line = [[🌗🌗🌗🌗 true]]
  --   local output = sbt.get_offset(selection, line)
  --   assert.equal(4, output.left)
  --   assert.equal(1, output.right)
  -- end)
end)
