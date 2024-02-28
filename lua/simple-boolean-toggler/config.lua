local toggler = require("simple-boolean-toggler.boolean_toggler")

---@class SimpleBooleanToggleConfig
local M = {}

M.defaults = {
  booleans = {
    -- { "Enabled", "Disabled" }, -- conflicts with Lazy plugin spec key
    { "Enable", "Disable" },
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
  opts = vim.tbl_deep_extend("force", {}, M.defaults, opts or {})

  toggler.generate_booleans(opts.booleans, opts)

  if opts.enabled_by_default then
    toggler.overwrite_default_keys()
  end
end

return M
