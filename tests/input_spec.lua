describe("Input", function()
    local input = require "input"
    input.setup()

    local function feedkeys(key)
        vim.api.nvim_feedkeys(key, "m", true)
    end

    local result = nil

    before_each(function()
        result = nil
    end)

    it("should accept new content with <CR> in insert mode", function()
        vim.ui.input({ prompt = "Enter value:" }, function(content)
            result = content
        end)
        feedkeys "new content"
        feedkeys(vim.keycode "<cr>")

        assert.equal("new content", result)
    end)

    it("should accept new content with <CR> in normal mode", function()
        vim.ui.input({ prompt = "Enter value:" }, function(content)
            result = content
        end)
        feedkeys(vim.keycode "<esc>")
        feedkeys(vim.keycode "<cr>")

        assert.equal("new content", result)
    end)

    it("should abort with <C-c> in insert mode", function()
        vim.ui.input({ prompt = "Enter value:" }, function(content)
            result = content
        end)
        feedkeys "<C-c>"
        feedkeys "<C-c>"

        assert.equal(nil, result)
    end)

    it("should abort with q in normal mode", function()
        vim.ui.input({ prompt = "Enter value:" }, function(content)
            result = content
        end)
        feedkeys "<esc>"
        feedkeys "q"

        assert.equal(nil, result)
    end)

    it("should abort with Escape in normal mode", function()
        vim.ui.input({ prompt = "Enter value:" }, function(content)
            result = content
        end)
        feedkeys "<esc>"
        feedkeys "<esc>"

        assert.equal(nil, result)
    end)
end)
