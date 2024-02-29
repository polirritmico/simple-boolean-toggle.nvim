# 🌗 Simple Boolean Toggle (WIP)

<!-- panvimdoc-ignore-start -->

![Pull Requests](https://img.shields.io/badge/Pull_Requests-Welcome-a4e400?style=flat-square)
![GitHub last commit](https://img.shields.io/github/last-commit/polirritmico/simple-boolean-toggle.nvim/main?style=flat-square&color=62d8f1)
![GitHub issues](https://img.shields.io/github/issues/polirritmico/simple-boolean-toggle.nvim?style=flat-square&color=fc1a70)

<!-- panvimdoc-ignore-end -->

## 🐧 Description

A simple plugin to add toggle boolean behaviour to the `<C-a>`/`<C-x>` builtin
functionality.

<!-- panvimdoc-ignore-start -->

## 📽 In Action

https://github.com/polirritmico/simple-boolean-toggle.nvim/assets/24460484/04bed6c8-c146-4a20-907c-d1ce48524b75

<!-- panvimdoc-ignore-end -->

## 📦 Installation

- For lazy:

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

If the cursor is before or over any character of the word "`true`", and
`<C-a>`/`<C-x>` is pressed, it would change it to:

```lua
local foo = { false, 99 }
```

If the cursor is over the "`,`", the space between, or the number "`99`" and
`<C-a>` is pressed, it would change the number to:

```lua
local foo = { false, 100 }
```

## Functions:

Simple Boolean Toggle comes with the following functions:

| Function             | Description                                                |
|----------------------|------------------------------------------------------------|
| `toggle_inc`         | Run the increment function at the current cursor position. |
| `toggle_dec`         | Run the increment function at the current cursor position. |
| `toggle_builtins`    | Enable/disable the plugin functions                        |
| `overwrite_builtins` | Replaces the base `<C-a>`/`<C-x>`.                         |
| `restore_builtins`   | Restore to the Neovim builtin behavior                     |
| `setup`              | Setup function. Check the Configurations section.          |

To access them just require the module. For example:

```lua
local boolean_toggle = require("simple-boolean-toggle")
boolean_toggle.toggle_builtins()
```

## 🛠️ Configuration:

### Defaults

Simple Boolean Toggle comes with the following defaults:

```lua
{
  -- Use Title Case, the plugin generates the upper and lower case variants
  booleans = { -- Use this table only to fully replace this defaults entries.
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

If you want to keep the default keymaps or behaviour just add your own map:

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

This plugin is made mainly for my personal use, but suggestions, new
functionality, issues, or pull requests are very welcome.

***Enjoy***

