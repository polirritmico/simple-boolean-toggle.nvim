# 🌗 Simple Boolean Toggle (WIP)

## TODO

- [ ] Fix last line visual mode
- [ ] Fix v mode selection outside line (right most, extra space)
- [ ] Document limitations (non space in booleans, only alphanumeric)

<!-- panvimdoc-ignore-start -->

![Pull Requests](https://img.shields.io/badge/Pull_Requests-Welcome-a4e400?style=flat-square)
![GitHub last commit](https://img.shields.io/github/last-commit/polirritmico/simple-boolean-toggle.nvim/main?style=flat-square&color=62d8f1)
![GitHub issues](https://img.shields.io/github/issues/polirritmico/simple-boolean-toggle.nvim?style=flat-square&color=fc1a70)

<!-- panvimdoc-ignore-end -->

## 🐧 Description

A simple plugin to add toggle boolean behaviour to the `<C-a>`/`<C-x>` built-in
functionality. Works in visual, visual-line and visual-block modes
(`v`/`V`/`^V`).

<!-- panvimdoc-ignore-start -->

## 📽 In Action

https://github.com/polirritmico/simple-boolean-toggle.nvim/assets/24460484/04bed6c8-c146-4a20-907c-d1ce48524b75

<!-- panvimdoc-ignore-end -->

## 📦 Installation

- For Lazy:

```lua
return {
  { "polirritmico/simple-boolean-toggle.nvim", config = true },
}
```

## 🔍 Usage

Just like `<C-a>`/`<C-x>` default behaviours. For example, for this text:

```lua
local foo = { true, 99 }
```

If the cursor is before or over any character of the word "`true`" and
`<C-a>`/`<C-x>` is pressed, it would change it to:

```lua
local foo = { false, 99 }
```

If instead the cursor is over the "`,`", the space between, or the number
"`99`", and `<C-a>` is pressed, it would change the number to:

```lua
local foo = { true, 100 }
```

### Visual modes

In visual mode, only affects the selected region and just like the built-in
behaviour, it would only toggle the first match in each line (the leftmost
number or boolean value).

## Functions:

Simple Boolean Toggle provides the following functions:

| Function             | Description                                                  |
| -------------------- | ------------------------------------------------------------ |
| `toggle_inc`         | Run the increment function from the current cursor position. |
| `toggle_dec`         | Run the decrement function from the current cursor position. |
| `toggle`             | Toggle boolean values from the current cursor position.      |
| `overwrite_builtins` | Replaces the base `<C-a>`/`<C-x>` built-in behaviour.        |
| `restore_builtins`   | Restore to the Neovim built-in behavior.                     |
| `toggle_builtins`    | Overwrite/Restore the built-ins `<C-a>`/`<C-x>` maps.        |

To access them just require the module. For example:

```lua
local sbt = require("simple-boolean-toggle")
vim.keymap.set("n", "<leader>tb", sbt.toggle, { silent = true, desc = "Boolean Toggle: Toggle the boolean values from the current cursor position" })
```

## 🛠️ Configuration:

### Defaults

Simple Boolean Toggle comes with the following defaults:

```lua
{
  -- Use Title Case, the plugin generates the upper and lower case variants
  booleans = { -- Use this table only to fully replace this default entries.
    { "True", "False" },
    { "Yes", "No" },
    { "On", "Off" },
  },
  extend_booleans = {}, -- If you want to add more entries use this table to extend the list
  overwrite_builtins = true, -- `true` to overwrite the base `<C-a>`/`<C-x>` keymaps and enable numbers increase/decrease. If this is set to `false` then you would need to define custom mappings to use the plugin. Check the provided functions.
}
```

### Full Examples

This is for the base use case (overwriting `<C-a>`/`<C-x>`) and adding a custom
boolean pair:

```lua
return {
  {
    "polirritmico/simple-boolean-toggle.nvim",
    event = { "BufReadPost", "BufWritePost", "BufNewFile" }, -- For lazy loading
    keys = {
      { "<leader>tb", ":lua require('simple-boolean-toggle').toggle_builtins()<Cr>", desc = "Boolean Toggle: On/Off" },
    },
    opts = {
      extend_booleans = {
        -- Use only Title Case, upper and lower cases are auto-generated
        { "High", "Low" }
        -- Manually define upper and lower case variants for auto-generation
        -- { "Something", "Nothing", { uppercase = true, lowercase = false } },
        -- Or match only one case:
        -- { "foO", "bAR", { uppercase = false, lowercase = false } },
      },
    },
  },
}
```

To simply add a new map and keep the Nvim defaults:

```lua
return {
  {
    "polirritmico/simple-boolean-toggle.nvim",
    keys = {
      { "<leader>tb", ":lua require('simple-boolean-toggle').toggle()<Cr>", desc = "Boolean Toggle: Change the next matching boolean string." },
    },
    opts = { overwrite_builtins = false },
  },
}
```

## 🌱 Contributions

This plugin is made mainly for my personal use, but suggestions, requests for
new functionality, issues, or pull requests are very welcome.

**_Enjoy_**
