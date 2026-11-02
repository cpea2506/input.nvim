---@alias input.type.range { min: integer, max: integer }

---@class input.config
local config = {}

---@class input.options
local defaults = {
    icon = " ",
    default_prompt = "Input",
    ---@type Partial<vim.wo>
    win_options = {
        wrap = true,
        linebreak = true,
        winhighlight = "Search:None",
    },
    ---@type vim.api.keyset.win_config
    win_config = {
        relative = "cursor",
        anchor = "NW",
        border = "rounded",
        row = 1,
        col = -1,
        width = 1,
        height = 1,
        style = "minimal",
    },
    size_options = {
        ---@type input.type.range
        width = {
            min = 40,
            max = 60,
        },
        ---@type input.type.range
        height = {
            min = 1,
            max = 6,
        },
    },
}

config.options = vim.deepcopy(defaults)

---Extend default with user's config.
---@param opts input.options
function config.extend(opts)
    if not opts or vim.tbl_isempty(opts) then
        return
    end

    config.options = vim.tbl_deep_extend("force", config.options, opts)
end

return config
