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

  it("1 byte char", function()
    -- ASCII, 1 byte
    local selection = {
      from = { line = 1, col = 5 },
      to = { line = 1, col = 8 },
    }

    local line = [[aaaa true]]
    local output = sbt.get_offset(selection, line)
    assert.equal(0, output.left)
    assert.equal(1, output.right)

    selection.to.col = 9
    output = sbt.get_offset(selection, line)
    assert.equal(0, output.right)
  end)

  it("2 byte char (2)", function()
    -- Latin-1, 2 bytes
    local selection = {
      from = { line = 1, col = 7 },
      to = { line = 1, col = 10 },
    }
    local line = [[ññ   true]]
    local output = sbt.get_offset(selection, line)
    assert.equal(0, output.left)
    assert.equal(1, output.right)
  end)

  it("2 byte char (4)", function()
    -- Latin-1, 2 bytes
    local selection = {
      from = { line = 1, col = 9 },
      to = { line = 1, col = 12 },
    }
    local line = [[ññññ true]]
    local output = sbt.get_offset(selection, line)
    assert.equal(0, output.left)
    assert.equal(1, output.right)
  end)

  it("3 byte char", function()
    -- Basic Multilingual, 3 bytes
    local selection = {
      from = { line = 1, col = 13 },
      to = { line = 1, col = 16 },
    }
    local line = [[⛗⛗⛗⛗ true]]
    local output = sbt.get_offset(selection, line)
    assert.equal(0, output.left)
    assert.equal(1, output.right)
  end)

  it("4 byte char", function()
    -- Supplementary, 4 bytes
    local selection = {
      from = { line = 1, col = 17 },
      to = { line = 1, col = 20 },
    }
    local line = [[𝄠𝄠𝄠𝄠 true]]
    local output = sbt.get_offset(selection, line)
    assert.equal(0, output.left)
    assert.equal(1, output.right)
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
