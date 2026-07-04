local M = setmetatable({}, {
    __call = function(t, ...)
        return t.input(...)
    end,
})

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

---@generic T
---@class Input
---@field on_confirm fun(input?: string)
---@field winid integer
---@field buf integer
---@field prompt string
---@field prompt_icon string
---@field default string
---@field icon_end_col integer
local Input = {}
Input.__index = Input

function Input.new(opts, on_confirm)
    opts = opts or {}

    local config = require "input.config"
    local prompt_icon = (" %s "):format(config.icon)

    return setmetatable({
        on_confirm = on_confirm,
        winid = nil,
        bufnr = nil,
        prompt = opts.prompt or config.default_prompt,
        prompt_icon = prompt_icon,
        icon_end_col = vim.fn.strlen(prompt_icon),
        default = opts.default or "",
    }, Input)
end

function Input:close()
    vim.cmd.stopinsert()

    if self.winid and vim.api.nvim_win_is_valid(self.winid) then
        vim.api.nvim_win_close(self.winid, true)
    end

    if self.buf and vim.api.nvim_buf_is_valid(self.buf) then
        vim.api.nvim_buf_delete(self.buf, { force = true })
    end
end

function Input:confirm(content)
    self:close()
    self.on_confirm(content)
end

function Input:cancel()
    self:confirm(nil)
end

function Input:create_buffer()
    -- Create buffer.
    self.buf = vim.api.nvim_create_buf(false, true)

    ---@type vim.bo
    local buf_options = {
        swapfile = false,
        buftype = "prompt",
        bufhidden = "wipe",
        filetype = "input",
    }

    -- Set buffer options.
    for option, value in pairs(buf_options) do
        vim.bo[self.buf][option] = value
    end
end

function Input:resize()
    local config = require "input.config"
    local size_options = config.size_options
    local content = table.concat(vim.api.nvim_buf_get_lines(self.buf, 0, -1, false), "")
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

    vim.api.nvim_win_set_config(self.winid, { width = width, height = height })
end

function Input:setup_prompt()
    vim.fn.prompt_setprompt(self.buf, self.prompt_icon)
    vim.fn.prompt_setcallback(self.buf, function(content)
        self:confirm(content)
    end)
    vim.fn.prompt_setinterrupt(self.buf, function()
        self:cancel()
    end)
end

function Input:open_window()
    local config = require "input.config"
    local win_config = config.win_config

    win_config.title = trim_and_pad_title(self.prompt)

    -- Create floating window.
    self.winid = vim.api.nvim_open_win(self.buf, true, win_config)

    -- Set window options.
    for option, value in pairs(config.win_options) do
        vim.wo[self.winid][option] = value
    end

    vim.api.nvim_win_call(self.winid, function()
        vim.api.nvim_buf_set_text(self.buf, 0, self.icon_end_col, 0, self.icon_end_col, { self.default })
        self:resize()
        vim.cmd.startinsert()
    end)
    vim.api.nvim_win_set_cursor(self.winid, { 1, vim.api.nvim_strwidth(self.default) + self.icon_end_col })

    local ns = vim.api.nvim_create_namespace "input"

    vim.hl.range(self.buf, ns, "InputIcon", { 0, 1 }, { 0, self.icon_end_col })
end

function Input:set_keymaps()
    vim.keymap.set("n", "<esc>", function()
        self:cancel()
    end, { buffer = self.buf })
    vim.keymap.set("n", "q", function()
        self:cancel()
    end, { buffer = self.buf })
    vim.keymap.set("n", "<cr>", function()
        local content = vim.fn.prompt_getinput(self.buf)
        self:confirm(content)
    end, { buffer = self.buf })
end

function Input:create_autocmds()
    local augroup = vim.api.nvim_create_augroup("input", { clear = true })

    vim.api.nvim_create_autocmd("BufLeave", {
        group = augroup,
        desc = "Cancel vim.ui.input",
        buffer = self.buf,
        nested = true,
        once = true,
        callback = function()
            self:close()
        end,
    })
    vim.api.nvim_create_autocmd("CursorMoved", {
        group = augroup,
        desc = "Constrain prompt cursor position",
        buffer = self.buf,
        nested = true,
        callback = function()
            local row, col = unpack(vim.api.nvim_win_get_cursor(self.winid))

            if col < self.icon_end_col then
                vim.api.nvim_win_set_cursor(self.winid, { row, self.icon_end_col })
            end
        end,
    })
    vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
        group = augroup,
        desc = "Resize vim.ui.input",
        buffer = self.buf,
        nested = true,
        callback = function()
            self:resize()
        end,
    })
end

function Input:show()
    self:create_buffer()
    self:setup_prompt()
    self:open_window()
    self:set_keymaps()
    self:create_autocmds()
end

---@type Input
local instance = nil

function M.input(opts, on_confirm)
    if instance then
        instance:close()
    end

    instance = Input.new(opts, on_confirm)
    instance:show()
end

return M
