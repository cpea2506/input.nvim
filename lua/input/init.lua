local M = {}

function M.setup(opts)
    local config = require "input.config"

    config.extend(opts)

    vim.api.nvim_set_hl(0, "InputIcon", { link = "Keyword", default = true })

    vim.ui.input = require "input.input"
end

return M
