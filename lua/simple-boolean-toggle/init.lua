---@class SimpleBooleanToggler
local M = {}

local toggle = require("simple-boolean-toggle.boolean_toggle")
local config = require("simple-boolean-toggle.config")

M.toggle_inc = function() toggle.toggle_dispatcher(true) end
M.toggle_dec = function() toggle.toggle_dispatcher(false) end
M.toggle = toggle.toggle_dispatcher

M.toggle_builtins = toggle.toggle_the_toggle
M.overwrite_builtins = toggle.overwrite_default_keys
M.restore_builtins = toggle.restore_default_keys

M.setup = config.setup

return M
