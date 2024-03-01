---@class BooleanToggleConfig
local M = {}

---@class BooleanToggleOptions
---@field booleans { [string]: string }
---@field extend_booleans { [string]: string }
---@field overwrite_builtins boolean
M.defaults = {
  -- Use Title Case, the plugin generates the upper and lower case variants
  booleans = { -- Use this table only to fully replace these default entries.
    { "True", "False" },
    { "Yes", "No" },
    { "On", "Off" },
  },
  extend_booleans = {}, -- If you want to add more entries use this table to extend the list
  overwrite_builtins = true, -- `true` to overwrite the base `<C-a>`/`<C-x>` keymaps. If this is set to `false` then you would need to define custom mappings to use the plugin. Check the provided functions.
}

M.options = {}

function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", M.defaults, opts or {})
  -- FIX: Check: https://github.com/neovim/neovim/issues/23654
  if opts.extend_booleans then
    vim.list_extend(M.options.booleans, opts.extend_booleans)
  end

  local toggle = require("simple-boolean-toggle.boolean_toggle")
  toggle.generate_booleans(M.options.booleans)

  if M.options.overwrite_builtins then
    toggle.overwrite_default_keys(true)
  end
end

return M
