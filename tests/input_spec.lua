describe("Input", function()
    local input = require "input"
    input.setup()

    ---@param keys string
    local function feedkeys(keys)
        vim.api.nvim_feedkeys(vim.keycode(keys), "xt", false)
    end

    local result = nil

    before_each(function()
        result = nil
    end)

    after_each(function()
        for _, winid in ipairs(vim.api.nvim_list_wins()) do
            if vim.api.nvim_win_get_config(winid).relative ~= "" then
                vim.api.nvim_win_close(winid, true)
            end
        end
    end)

    it("should display prompt icon and default content", function()
        local config = require "input.config"

        vim.ui.input({ prompt = "Enter value:", default = "default_content" }, function() end)

        local bufnr = vim.api.nvim_get_current_buf()
        local prompt = vim.fn.prompt_getprompt(bufnr)
        local content = vim.fn.prompt_getinput(bufnr)

        assert.equal((" %s "):format(config.icon), prompt)
        assert.equal("default_content", content)
    end)

    it("should accept new content with <CR> in insert mode", function()
        vim.ui.input({ prompt = "Enter value:" }, function(content)
            result = content
        end)

        feedkeys "inew_content<cr>"

        assert.equal("new_content", result)
    end)

    it("should accept new content with <CR> in normal mode", function()
        vim.ui.input({ prompt = "Enter value:" }, function(content)
            result = content
        end)

        feedkeys "inew_content<esc><cr>"

        assert.equal("new_content", result)
    end)

    it("should abort with <C-c> in insert mode", function()
        vim.ui.input({ prompt = "Enter value:" }, function(content)
            result = content
        end)

        local winid = vim.api.nvim_get_current_win()

        assert.is_true(vim.api.nvim_win_is_valid(winid))

        feedkeys "i<C-c>"

        assert.equal(nil, result)
        assert.is_false(vim.api.nvim_win_is_valid(winid))
    end)

    it("should abort with q in normal mode", function()
        vim.ui.input({ prompt = "Enter value:" }, function(content)
            result = content
        end)

        local winid = vim.api.nvim_get_current_win()

        assert.is_true(vim.api.nvim_win_is_valid(winid))

        feedkeys "q"

        assert.equal(nil, result)
        assert.is_false(vim.api.nvim_win_is_valid(winid))
    end)

    it("should abort with Escape in normal mode", function()
        vim.ui.input({ prompt = "Enter value:" }, function(content)
            result = content
        end)

        local winid = vim.api.nvim_get_current_win()

        assert.is_true(vim.api.nvim_win_is_valid(winid))

        feedkeys "<esc>"

        assert.equal(nil, result)
        assert.is_false(vim.api.nvim_win_is_valid(winid))
    end)
end)
