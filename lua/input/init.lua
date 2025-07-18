local M = {}

local function input(opts, on_confirm)
    local config = require "input.config"
    local utils = require "input.utils"
    local win_config = config.win_config

    local prompt = opts.prompt or config.default_prompt
    local default = opts.default or ""
    local prompt_lines = vim.split(prompt, "\n", { plain = true, trimempty = true })

    local width = utils.calculate_width(win_config.relative, win_config.width, config.width_options)
    width = math.max(width, utils.get_max_strwidth(prompt_lines) + 4, vim.api.nvim_strwidth(default) + 2)

    win_config.title = utils.trim_and_pad_title(prompt)
    win_config.width = utils.calculate_width(win_config.relative, width, config.width_options)

    --- Create buffer.
    local bufnr = vim.api.nvim_create_buf(false, true)

    -- Set buffer options.
    for option, value in pairs(config.buf_options) do
        vim.bo[bufnr][option] = value
    end

    vim.bo[bufnr].buftype = "prompt"
    -- Create floating window.
    local winid = vim.api.nvim_open_win(bufnr, true, win_config)

    -- Set window options.
    for option, value in pairs(config.win_options) do
        vim.wo[winid][option] = value
    end

    vim.wo[winid].statuscolumn = [[%!v:lua.require("input.config").statuscolumn()]]
    local function close()
        vim.api.nvim_win_close(winid, true)
    end

    local function confirm(content)
        on_confirm(content)
        close()
    end

    vim.fn.prompt_setprompt(bufnr, "")
    vim.fn.prompt_setcallback(bufnr, confirm)
    vim.fn.prompt_setinterrupt(bufnr, close)

    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { default })
    vim.api.nvim_win_call(winid, function()
        vim.cmd.startinsert()
    end)
    vim.api.nvim_win_set_cursor(winid, { 1, vim.str_utfindex(default, "utf-8") + 1 })

    vim.keymap.set("n", "<esc>", close, { buffer = bufnr })
    vim.keymap.set("n", "q", close, { buffer = bufnr })

    local augroup = vim.api.nvim_create_augroup("input", { clear = true })

    vim.api.nvim_create_autocmd("BufLeave", {
        group = augroup,
        desc = "Cancel vim.ui.input",
        buffer = bufnr,
        nested = true,
        once = true,
        callback = close,
    })
end

function M.setup(opts)
    local config = require "input.config"

    config.extend(opts)

    vim.ui.input = input
end

return M
