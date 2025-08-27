local input = require "input"
local config = require "input.config"

describe("Config options", function()
    it("could be indexed without options field", function()
        assert.equal(" ", config.icon)
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
        local function tbl_contains(table, value)
            return vim.tbl_contains(table, function(v)
                for k, _ in pairs(value) do
                    if v[k] ~= value[k] then
                        return false
                    end
                end

                return true
            end, { predicate = true })
        end

        assert.equal(expected.icon, config.icon)
        assert.equal(expected.default_prompt, config.default_prompt)
        assert.is_true(tbl_contains({ config.win_config }, { relative = "editor", anchor = "SE", border = "rounded" }))
    end)
end)
