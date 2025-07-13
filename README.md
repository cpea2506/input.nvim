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

- Neovim >= 0.11.0

## ⚙️ Setup

Once installed, this plugin is activated automatically. No setup is required unless you want to customize the options.

### Available Options

| Option           | Description                               | Type                 | Note                                |
| ---------------- | ----------------------------------------- | -------------------- | ----------------------------------- |
| `icon`           | Icon displayed alongside the input prompt | `string`             | N/A                                 |
| `default_prompt` | Default text shown in the input prompt    | `string`             | N/A                                 |
| `win_options`    | Window-level Vim options                  | `table<string, any>` | `:h nvim_win_set_option`            |
| `buf_options`    | Buffer-level Vim options                  | `table<string, any>` | `:h nvim_buf_set_option`            |
| `win_config`     | Window configuration for `nvim_open_win`  | `table<string, any>` | `:h nvim_open_win`                  |
| `width_options`  | Dynamic width settings                    | `table<string, any>` | See [Width Options](#width-options) |

#### Width Options

| Sub-Option  | Description           | Type               | Note                                  |
| ----------- | --------------------- | ------------------ | ------------------------------------- |
| `prefer`    | Preferred input width | `number`           | Used as the default target width      |
| `min_value` | Minimum allowed width | `{number, number}` | Supports fixed width and window ratio |
| `max_value` | Maximum allowed width | `{number, number}` | Supports fixed width and window ratio |

### Default Configuration

```lua
require("input").setup({
    icon = "",
    default_prompt = "Input",
    win_options = {
        wrap = false,
        list = true,
        listchars = "precedes:…,extends:…",
        sidescrolloff = 0,
    },
    buf_options = {
        swapfile = false,
        bufhidden = "wipe",
        filetype = "input",
    },
    win_config = {
        relative = "cursor",
        anchor = "NW",
        border = vim.o.winborder,
        row = 1,
        col = 1,
        width = 40,
        height = 1,
        focusable = false,
        noautocmd = true,
        style = "minimal",
    },
    width_options = {
        prefer = 40,
        min_value = { 20, 0.2 },
        max_value = { 140, 0.9 },
    },
})
```

## :eyes: Inspiration

- [dressing.nvim](https://github.com/stevearc/dressing.nvim)

## :scroll: Contribution

For detailed instructions on how to contribute to this plugin, please see [the contributing guidelines](CONTRIBUTING.md).
