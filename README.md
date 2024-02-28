# 🌗 Simple Boolean Toggler (WIP)

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
  {
    "polirritmico/simple-boolean-togger.nvim"
    event = { "BufReadPost", "BufWritePost", "BufNewFile" }, -- For lazy loading
    config = true,
  },
}
```

## 🔍 Usage

Just like `<C-a>`/`<C-x>`. For example, for this text:

```lua
local foo = { true, 99 }
```

If the cursor is before or over any character of the word "`true`", and
`<C-a>`/`<C-x>` is pressed, it would change it to:

```lua
local foo = { false, 99 }
```

If the cursor is over the "`,`", the space between, or the number "`99`" and
`<C-a>` is pressed, it would change it to:

```lua
local foo = { false, 100 }
```

## 🛠️ Configuration:

### Defaults

Simple Boolean Toggler comes with the following defaults:

```lua
{
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
```

## 🌱 Contributions

This plugin is made mainly for my personal use, but suggestions, issues, or pull
requests are very welcome.

***Enjoy***

