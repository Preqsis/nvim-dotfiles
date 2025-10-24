local openai = require("nvim-llm.providers.openai")
local claude = require("nvim-llm.providers.claude")

local M = {}

function M.send_to_provider(provider, prompt, callback)
    if provider == "openai" then
        return openai.send_prompt(prompt)
    elseif provider == "claude" then
        return claude.send_prompt(prompt, callback)
    else
        vim.notify("[nvim-llm] Unknown provider: " .. provider, vim.log.levels.ERROR)
    end
end

return M
