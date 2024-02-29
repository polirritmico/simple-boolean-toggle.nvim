local M = {}

M.defaults = {
  booleans = { -- use this table to reeplace this defaults
    { "True", "False" },
    { "Yes", "No" },
    { "On", "Off" },
  },
  extend_booleans = {}, -- If you want to add more entries use this table to extend the list
  overwrite_default_keys = true, -- Change or not the default `<C-a>`/`<C-x>` behavior
  only_booleans = false, -- Don't modify numbers, only the matching booleans. Useful when defining your own keys.
}

M.options = {}

function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", M.defaults, opts or {})
  if opts.extend_booleans then
    vim.list_extend(M.options.booleans, opts.extend_booleans)
  end

  local toggle = require("simple-boolean-toggle.boolean_toggle")
  toggle.generate_booleans(M.options.booleans)
  toggle.enabled_builtin = not M.options.only_booleans
  if M.options.overwrite_default_keys then
    toggle.overwrite_default_keys()
  end
end

return M
