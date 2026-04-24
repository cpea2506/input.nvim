local M = setmetatable({}, {
    __call = function(t, ...)
        return t.input(...)
    end,
})

local buf_options = {
    swapfile = false,
    buftype = "prompt",
    bufhidden = "wipe",
    filetype = "input",
}

---Trim and pad title.
---@param title string
---@return string
local function trim_and_pad_title(title)
    title = vim.trim(title):gsub(":$", "")

    return (" %s "):format(title)
end

---Clamp value to between min and max.
---@param value number
---@param min number
---@param max number
local function clamp(value, min, max)
    return math.max(math.min(value, max), min)
end

---Split wrapped lines.
---@param text string
---@param width number
local function split_wrapped_lines(text, width)
    if text == "" then
        return {}
    end

    local lines = {}
    local textlen = vim.fn.strcharlen(text)

    local i = 0

    while i < textlen do
        local len = i + width <= textlen and width or textlen - i
        local new_line = vim.fn.strcharpart(text, i, len)

        table.insert(lines, new_line)

        i = i + len
    end

    return lines
end

---@param opts? vim.ui.input.Opts
---@param on_confirm fun(input?: string)
function M.input(opts, on_confirm)
    opts = opts or {}

    local config = require "input.config"

    local size_options = config.size_options
    local win_config = config.win_config

    local prompt = opts.prompt or config.default_prompt
    local default = opts.default or ""

    win_config.title = trim_and_pad_title(prompt)

    -- Create buffer.
    local bufnr = vim.api.nvim_create_buf(false, true)

    -- Set buffer options.
    for option, value in pairs(buf_options) do
        vim.bo[bufnr][option] = value
    end

    -- Create floating window.
    local winid = vim.api.nvim_open_win(bufnr, true, win_config)

    -- Set window options.
    for option, value in pairs(config.win_options) do
        vim.wo[winid][option] = value
    end

    local function close()
        vim.cmd.stopinsert()
        vim.api.nvim_win_close(winid, true)
    end

    local function confirm(content)
        on_confirm(content)
        close()
    end

    local function cancel()
        confirm(nil)
    end

    local function resize()
        local content = table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), "")
        local width, height = size_options.width.min, size_options.height.min

        if content ~= "" then
            local lines = split_wrapped_lines(content, size_options.width.max)
            local max_len_width = vim.iter(lines):fold(size_options.width.min, function(acc, line)
                return math.max(acc, vim.api.nvim_strwidth(line))
            end)

            width = clamp(max_len_width, size_options.width.min, size_options.width.max) + 1
            height = clamp(
                width == size_options.width.max + 1 and #lines + 1 or #lines,
                size_options.height.min,
                size_options.height.max
            )
        end

        vim.api.nvim_win_set_config(winid, { width = width, height = height })
    end

    local prompt_icon = (" %s "):format(config.icon)
    local icon_end_col = vim.fn.strlen(prompt_icon)

    vim.fn.prompt_setprompt(bufnr, prompt_icon)
    vim.fn.prompt_setcallback(bufnr, confirm)
    vim.fn.prompt_setinterrupt(bufnr, cancel)

    vim.api.nvim_win_call(winid, function()
        vim.api.nvim_buf_set_text(bufnr, 0, icon_end_col, 0, icon_end_col, { default })
        resize()
        vim.cmd.startinsert()
    end)
    vim.api.nvim_win_set_cursor(winid, { 1, vim.api.nvim_strwidth(default) + icon_end_col })

    local ns = vim.api.nvim_create_namespace "input"

    vim.hl.range(bufnr, ns, "InputIcon", { 0, 1 }, { 0, icon_end_col })

    vim.keymap.set("n", "<esc>", cancel, { buffer = bufnr })
    vim.keymap.set("n", "q", cancel, { buffer = bufnr })
    vim.keymap.set("n", "<cr>", function()
        local content = vim.fn.prompt_getinput(bufnr)
        confirm(content)
    end, { buffer = bufnr })

    local augroup = vim.api.nvim_create_augroup("input", { clear = true })

    vim.api.nvim_create_autocmd("BufLeave", {
        group = augroup,
        desc = "Cancel vim.ui.input",
        buffer = bufnr,
        nested = true,
        once = true,
        callback = close,
    })

    vim.api.nvim_create_autocmd("CursorMoved", {
        group = augroup,
        desc = "Constrain prompt cursor position",
        buffer = bufnr,
        nested = true,
        callback = function()
            local row, col = unpack(vim.api.nvim_win_get_cursor(winid))

            if col < icon_end_col then
                vim.api.nvim_win_set_cursor(winid, { row, icon_end_col })
            end
        end,
    })

    vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
        group = augroup,
        desc = "Resize vim.ui.input",
        buffer = bufnr,
        nested = true,
        callback = function()
            resize()
        end,
    })
end

return M
