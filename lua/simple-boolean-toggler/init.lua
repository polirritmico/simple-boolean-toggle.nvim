local M = {}

local toggler = require("simple-boolean-toggler.boolean_toggler")
local config = require("simple-boolean-toggler.config")

M.enable = toggler.overwrite_default_keys
M.disable = toggler.restore_default_keys
M.toggle = toggler.toggle_the_toggler

M.toggle_inc = toggler.toggle(true)
M.toggle_dec = toggler.toggle(false)

M.setup = config.setup

return M
