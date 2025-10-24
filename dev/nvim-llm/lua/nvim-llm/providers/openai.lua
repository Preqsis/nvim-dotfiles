local Job = require("plenary.job")
local utils = require("nvim-llm.utils")

local M = {}

-- Fetch API key from environment variables (better than hardcoding)
local api_key = os.getenv("OPENAI_API_KEY")
local endpoint = "https://api.openai.com/v1/completions"
local model = "text-davinci-003"

-- Function to send a prompt to OpenAI's API
function M.send_prompt(prompt, opts)
	opts = opts or {}

	-- Prepare payload for OpenAI API request
	local payload = {
		model = model,
		prompt = prompt,
		max_tokens = opts.max_tokens or 150,
		temperature = opts.temperature or 0.7,
	}

	-- Start the async job to call OpenAI API
	return Job:new({
		command = "curl",
		args = {
			"-s", -- silent mode
			"-X",
			"POST",
			"-H",
			"Content-Type: application/json",
			"-H",
			"Authorization: Bearer " .. api_key,
			"-d",
			vim.fn.json_encode(payload),
			endpoint,
		},
		on_exit = function(job, return_val)
			-- Get the response and parse it
			local response = job:result()
			local ok, parsed = pcall(vim.fn.json_decode, table.concat(response, "\n"))

			if ok and parsed.choices then
				local text_response = parsed.choices[1].text
				utils.info("[nvim-llm] Response: " .. text_response)
			else
				utils.error("[nvim-llm] Error: Could not get valid response from OpenAI.")
			end
		end,
	}):start()
end

return M
