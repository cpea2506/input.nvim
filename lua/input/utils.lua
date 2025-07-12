---Thanks: https://github.com/stevearc/dressing.nvim/blob/master/lua/dressing/util.lua
local M = {}

local function calculate_float(value, max_value)
    if value then
        local _, p = math.modf(value)

        if p ~= 0 then
            return math.min(max_value, value * max_value)
        end
    end

    return value
end

local function calculate_list(value, max_value, aggregator, limit)
    local result = limit

    for _, v in ipairs(value) do
        result = aggregator(result, calculate_float(v, max_value))
    end

    return result
end

local function get_max_width(relative, winid)
    return relative == "editor" and vim.o.columns or vim.api.nvim_win_get_width(winid or 0)
end

---Calculate size.
---@param current_size number
---@param size_options input.width_options
---@param total_size number
---@return integer
local function calculate_size(current_size, size_options, total_size)
    local result = calculate_float(current_size, total_size)
    local min_val = calculate_list(size_options.min_value, total_size, math.max, 1)
    local max_val = calculate_list(size_options.max_value, total_size, math.min, total_size)

    if not result then
        result = calculate_float(size_options.prefer, total_size)
    end

    result = math.min(result, max_val)
    result = math.max(result, min_val)

    return math.floor(result)
end

---Calculate width.
---@param relative "cursor"|"editor"
---@param current_size number
---@param width_options input.width_options
---@return integer
function M.calculate_width(relative, current_size, width_options)
    return calculate_size(current_size, width_options, get_max_width(relative))
end

---Get max string width.
---@param lines table<string>
---@return integer
function M.get_max_strwidth(lines)
    local max = 0

    for _, line in ipairs(lines) do
        max = math.max(max, vim.api.nvim_strwidth(line))
    end

    return max
end

---Trim and pad title.
---@param title string
---@return string
function M.trim_and_pad_title(title)
    title = vim.trim(title):gsub(":$", "")

    return (" %s "):format(title)
end

return M
