local openai = require("nvim-llm.providers.openai")

local M = {}

-- Default provider is OpenAI
local current_provider = openai

-- Function to switch providers dynamically (can be extended later)
function M.use(provider_name)
  if provider_name == "openai" then
    current_provider = openai
  else
    error("[nvim-llm] Unknown provider: " .. provider_name)
  end
end

-- Function to send a prompt to the selected provider
function M.send_prompt(prompt, opts)
  return current_provider.send_prompt(prompt, opts)
end

return M
