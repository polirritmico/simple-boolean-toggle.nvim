local toggler = require("simple-boolean-toggler.boolean_toggler")

---@class SimpleBooleanToggleConfig
local M = {}

M.defaults = {
  booleans = {
    { "Enable", "Disable" },
    -- { "Enabled", "Disabled" }, -- conflicts with Lazy plugin spec
    { "On", "Off" },
    { "True", "False" },
    { "Yes", "No" },
  },
  uppercase = true,
  lowercase = true,
  enabled_by_default = true,
}

function M.setup(opts)
  -- TODO: Check if you add a boolean in the booleans table will overwrite the
  -- full table or would append the new one into defaults
  -- TODO: Add option or a way to remove an entry from defaults.
  opts = vim.tbl_deep_extend("force", {}, M.defaults, opts or {})

  toggler.generate_booleans(opts.booleans, opts)

  if opts.enabled_by_default then
    toggler.wrap_default_keys()
  end
end

return M
