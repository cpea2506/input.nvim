local M = {}

function M.setup(opts)
    local config = require "input.config"

    if vim.fn.hlexists "InputIcon" == 0 then
        vim.api.nvim_set_hl(0, "InputIcon", { link = "Keyword" })
    end

    config.extend(opts)

    vim.ui.input = require "input.input"
end

return M
