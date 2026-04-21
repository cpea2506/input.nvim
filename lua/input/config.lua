---@class input.type.range
---@field min integer
---@field max integer

---@class input.config.size_options
---@field width input.type.range
---@field height input.type.range

---@class input.config
---@field icon string
---@field default_prompt string
---@field win_options vim.wo
---@field win_config vim.api.keyset.win_config
---@field size_options input.config.size_options
local config = {}

---@type input.config
local defaults = {
    icon = " ",
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

setmetatable(config, {
    __index = function(_, k)
        return options[k]
    end,
})

return config
