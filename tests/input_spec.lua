local input = require "input"

describe("Input", function()
    input.setup()

    it("should accept new content", function()
        local result = ""

        vim.ui.input({ prompt = "Test" }, function(content)
            result = content
        end)

        vim.api.nvim_feedkeys("test", "m", true)
        local cr = vim.api.nvim_replace_termcodes("<CR>", true, false, true)
        vim.api.nvim_feedkeys(cr, "m", true)

        assert.equal(result, "test")
    end)

    it("should abort or cancel", function()
        local result = ""

        vim.ui.input({ prompt = "Test" }, function(input)
            print(input)
        end)

        local cr = vim.keycode "<CR>"
        vim.api.nvim_feedkeys(cr, "m", true)

        assert.equal(result, "")
    end)
end)
