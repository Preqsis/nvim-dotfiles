local Job = require("plenary.job")

local M = {}

local api_key = os.getenv("CLAUDE_API_KEY") -- fetch api_key from environment variable
local default_endpoint = "https://api.anthropic.com/v1/messages" 
local default_model = "claude-3-7-sonnet-latest"
local default_role = "user"
local default_max_tokens = 5000
local default_anthropic_version = "2023-06-01"

function M.send_prompt(prompt, callback, opts)
	opts = opts or {}

    if api_key == "" then
        vim.notify("[nvim-llm] Claude API key is not set in the environment variable CLAUDE_API_KEY", vim.log.levels.ERROR)
    end

	Job:new({
		command = "curl",
		args = {
			"-s", -- silent mode
			"-X",
			"POST",
			"-H",
			"Content-Type: application/json",
			"-H",
			"x-api-key: " .. api_key,
			"-H",
			"anthropic-version: " .. (default_anthropic_version or opts.anthropic_version),
			"-d",
			build_payload(prompt, opts),
			opts.endpoint or default_endpoint,
		},
		on_exit = function(job, return_val)
			local success, parsed_response = pcall(vim.json.decode, table.concat(job:result(), "\n"))

			if success and parsed_response.content then
				local text_response = parsed_response.content[1].text
				callback(text_response)
			else
				callback(vim.inspect(parsed_response))
			end
		end,
	}):start()
end


function build_payload(prompt, opts)
	local payload = {
		model = opts.model or default_model,
		messages = {
			{
				role = opts.role or default_role,
				content = prompt,
			},
		},
		max_tokens = opts.max_tokens or default_max_tokens,
	}

    return vim.json.encode(payload)
end

return M
