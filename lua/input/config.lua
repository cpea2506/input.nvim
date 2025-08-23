---@class input.width_options
---@field prefer number
---@field min_value number[]
---@field max_value number[]

---@class input.config
---@field icon string
---@field default_prompt string
---@field win_options vim.wo
---@field buf_options vim.bo
---@field win_config vim.api.keyset.win_config
---@field width_options input.width_options
local config = {}

---@type input.config
local defaults = {
    icon = " ",
    default_prompt = "Input",
    win_options = {
        wrap = false,
        list = true,
        listchars = "precedes:…,extends:…",
        sidescrolloff = 0,
        statuscolumn = [[%!v:lua.require("input.config").statuscolumn()]],
    },
    buf_options = {
        swapfile = false,
        buftype = "prompt",
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
        style = "minimal",
    },
    width_options = {
        prefer = 40,
        min_value = { 20, 0.2 },
        max_value = { 140, 0.9 },
    },
}

local options = vim.deepcopy(defaults)

---Extend default with user's config.
---@param opts input.config
function config.extend(opts)
    if not opts or vim.tbl_isempty(opts) then
        return
    end

    options = vim.tbl_deep_extend("force", options, opts)
end

function config.statuscolumn()
    if vim.fn.hlexists "InputIcon" == 0 then
        vim.api.nvim_set_hl(0, "InputIcon", { fg = "#56b6c2" })
    end

    return (" %%#InputIcon#%s "):format(options.icon)
end

setmetatable(config, {
    __index = function(_, k)
        return options[k]
    end,
})

return config
