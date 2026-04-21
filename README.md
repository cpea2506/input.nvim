<div align="center">
  <h1>
      <img width="180" alt="icon" src="https://github.com/user-attachments/assets/af30a095-bb46-4eed-b5b5-a7035439fe14"/>
      <br/>
      Input Nvim
  </h1>

Opinionated, simple replacement for `vim.ui.input`.

</div>

<img width="1427" height="810" alt="Screenshot 2025-07-13 at 16 03 28" src="https://github.com/user-attachments/assets/1af56862-26a6-425f-9bad-6b4dd7345fbc" />

## 🚀 Installation

```lua
{
  "cpea2506/input.nvim"
}
```

### Requirements

- Neovim >= 0.12.0

## ⚙️ Setup

This plugin works immediately after installation.
Configuration is optional, only needed if you want to override defaults.

### Available Options

| Option           | Description                              | Type                 | Notes                             |
| ---------------- | ---------------------------------------- | -------------------- | --------------------------------- |
| `icon`           | Icon displayed next to the prompt        | `string`             | N/A                               |
| `default_prompt` | Default text for the prompt              | `string`             | N/A                               |
| `win_options`    | Window-level Vim options                 | `table<string, any>` | See `:h nvim_win_set_option`      |
| `win_config`     | Window configuration for `nvim_open_win` | `table<string, any>` | See `:h nvim_open_win`            |
| `size_options`   | Dynamic sizing configuration             | `table`              | See [Size Options](#size-options) |

#### Size Options

| Option       | Description                        | Type      | Notes |
| ------------ | ---------------------------------- | --------- | ----- |
| `width.min`  | Minimum width of the input window  | `integer` | N/A   |
| `width.max`  | Maximum width of the input window  | `integer` | N/A   |
| `height.min` | Minimum height of the input window | `integer` | N/A   |
| `height.max` | Maximum height of the input window | `integer` | N/A   |

### Default Configuration

```lua
require("input").setup({
    icon = "",
    default_prompt = "Input",
    win_options = {
        wrap = true,
        linebreak = true,
        winhighlight = "Search:None",
    },
    win_config = {
        relative = "cursor",
        anchor = "NW",
        border = vim.o.winborder,
        row = 1,
        col = -1,
        width = 1,
        height = 1,
        style = "minimal",
    },
    size_options = {
        width = {
            min = 40,
            max = 60,
        },
        height = {
            min = 1,
            max = 6,
        },
    },
})
```

## ⌨️ Key Mappings

These are the default key mappings:

| Keybinding | Mode(s) | Action                                  |
| ---------- | ------- | --------------------------------------- |
| `<C-c>`    | i, n    | Cancel content changes and close input  |
| `<Esc>`    | n       | Cancel content changes and close input  |
| `q`        | n       | Cancel content changes and close input  |
| `<CR>`     | i, n    | Confirm content changes and close input |

## 🎨 Highlights

| Highlight Group | Purpose                                               |
| --------------- | ----------------------------------------------------- |
| `InputIcon`     | Status column icon, which displayed before the prompt |

To customize highlights for the plugin window:

```lua
require("input").setup({
  win_options = {
    winhighlight = "NormalFloat:DiagnosticError"
  }
})
```

For more, see `:h winhighlight`.

## 👀 Inspiration

- [dressing.nvim](https://github.com/stevearc/dressing.nvim)
- [multinput.nvim](https://github.com/r0nsha/multinput.nvim)

## :scroll: Contribution

For detailed instructions on how to contribute to this plugin, please see [the contributing guidelines](CONTRIBUTING.md).
