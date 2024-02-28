local M = {}

local toggler = require("simple-boolean-toggler.boolean_toggler")
local config = require("simple-boolean-toggler.config")

M.enable = toggler.enable_toggler
M.disable = toggler.disable_toggler
M.toggle = toggler.toggle_toggler

M.setup = config.setup

return M
