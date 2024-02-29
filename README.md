# 🌗 Simple Boolean Toggle (WIP)

<!-- panvimdoc-ignore-start -->

![Pull Requests](https://img.shields.io/badge/Pull_Requests-Welcome-a4e400?style=flat-square)
![GitHub last commit](https://img.shields.io/github/last-commit/polirritmico/telescope-lazy-plugins.nvim/main?style=flat-square&color=62d8f1)
![GitHub issues](https://img.shields.io/github/issues/polirritmico/telescope-lazy-plugins.nvim?style=flat-square&color=fc1a70)

<!-- panvimdoc-ignore-end -->

## 🐧 Description

A simple plugin to add toggle boolean behaviour to the `<C-a>`/`<C-x>` builtin
functionality.

<!-- panvimdoc-ignore-start -->

## Demo

![fallback text](image.jpg "hover text")

<!-- panvimdoc-ignore-end -->

## 📦 Installation

- For lazy:

```lua
return {
  { "polirritmico/simple-boolean-toggle.nvim", config = true },
}
```

## 🔍 Usage

Just like `<C-a>`/`<C-x>` default behaviour. For example, for this text:

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

To access them just require the module:

```lua
local boolean_toggle = require("simple-boolean-togger")
```

## 🛠️ Configuration:

### Defaults

Simple Boolean Toggle comes with the following defaults:

```lua
{
  booleans = { -- If you want to fully reeplace this defaults use this table. (Only alpha characters)
    { "True", "False" },
    { "Yes", "No" },
    { "On", "Off" },
  },
  extend_booleans = {}, -- If you want to add more entries use this table to extend the list
  overwrite_default_keys = true, -- Change or not the default `<C-a>`/`<C-x>` behavior
  only_booleans = false, -- Don't modify numbers, only the matching booleans. Useful when defining your own keys.
}
```

### Full example

```lua
return {
  {
    "polirritmico/simple-boolean-togger.nvim",
    event = { "BufReadPost", "BufWritePost", "BufNewFile" }, -- For lazy loading
    keys = {
      {
        "<leader>tb",
        ":lua require('simple-boolean-toggle').toggle_builtins()<Cr>",
        desc = "Boolean Toggle: On/Off",
      },
    },
    opts = {
      extend_booleans = {
        -- Use only Title Case, upper and lower cases are auto-generated
        { "High", "Low" }
        -- Manually define upper and lower case variants for auto-generation
        -- { "Something", "Nothing", { uppercase = true, lowercase = false } },
        -- Or be specific:
        -- { "foO", "bAR", { uppercase = false, lowercase = false } },
      },
    },
  },
}
```

## 🌱 Contributions

This plugin is made mainly for my personal use, but suggestions, issues, or pull
requests are very welcome.

***Enjoy***

