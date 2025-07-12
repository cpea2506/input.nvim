local config = require "input.config"
local input = require "input"

describe("Config options", function()
    it("could be indexed without options field", function()
        assert.equal("", config.icon)
        assert.equal("Input", config.default_prompt)
    end)
end)

describe("Override config", function()
    local expected = {
        icon = "",
        default_prompt = "Select",
        win_config = {
            relative = "editor",
            anchor = "SE",
            border = "rounded",
        },
    }

    input.setup(expected)

    it("should change default config", function()
        assert.equal(expected.icon, config.icon)
        assert.equal(expected.default_prompt, config.default_prompt)
        assert.are.same(expected.win_config, config.win_config)
    end)
end)
