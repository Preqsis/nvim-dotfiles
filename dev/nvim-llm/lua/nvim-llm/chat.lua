local M = {}
local api = vim.api
local thinking_timer = nil
local thinking_line_index = nil

local llm_provider = require("nvim-llm.providers.claude")

local prompt_index = nil

local chat_window = nil
local chat_buffer = nil
local chat_history = {}
local chat_index = 0
local chat_aliases = {
    ["user"] = "User",
    ["llm"] = "LLM"
}
local chat_avatars = {
    ["user"] = "👽",
    ["llm"] = "🤖",
}


function M.toggle_chat_window()
    if #chat_history == 0 then
        M.init_chat_history()
    end

	if not M.chat_buffer_exists() then
		M.create_chat_buffer()
	end

	if M.is_chat_window_open() then
		M.close_chat_window()
	else
		M.open_chat_window()
		M.render_chat()
	end
end

function M.init_chat_history()
	M.add_message_to_history("chat", "message", "[nvim-llm] Chat started...")
	M.add_message_to_history("chat", "separator", nil)
end

function M.chat_buffer_exists()
	if chat_buffer == nil then
		return false
	end
	return vim.api.nvim_buf_is_valid(chat_buffer)
end

function M.create_chat_buffer()
	chat_buffer = api.nvim_create_buf(false, true)
	api.nvim_buf_set_name(chat_buffer, "nvim-llm-chat")
	api.nvim_buf_set_option(chat_buffer, "modifiable", true)
	api.nvim_buf_set_option(chat_buffer, "readonly", false)
	api.nvim_buf_set_option(chat_buffer, "swapfile", false)
	api.nvim_buf_set_option(chat_buffer, "filetype", "markdown")
end

function M.open_chat_window()
	api.nvim_command("vsplit") -- This creates the vertical split
	api.nvim_set_current_buf(chat_buffer) -- Set the chat buffer as the active buffer
	chat_window = api.nvim_get_current_win()
end

function M.close_chat_window()
	vim.api.nvim_win_close(chat_window, true)
end

function M.is_chat_window_open()
	if chat_window == nil then
		return false
	end
	return vim.api.nvim_win_is_valid(chat_window)
end

function M.render_chat()
	chat_index = 0
	if M.chat_buffer_exists() then
		-- Clear buffer
		api.nvim_buf_set_lines(chat_buffer, 0, -1, false, {})

		-- Render all items in history
		for _, item in ipairs(chat_history) do
			if item.content_type == "separator" then
				M.render_separator()
			elseif item.content_type == "message" then
				M.render_message(item.sender, item.content)
			end
		end
	end
    
    -- Scroll down
    api.nvim_win_set_cursor(chat_window, { api.nvim_buf_line_count(chat_buffer), 0 })

    -- Add prompt
    M.render_empty_prompt()

end

function M.render_message(sender, content)
    local lines = M.split_message_to_lines(content)
    if sender ~= "chat" then
        lines[1] = string.format("%s %s: %s", chat_avatars[sender], chat_aliases[sender], lines[1])
    end
	M.render_lines(lines)
end

function M.render_separator()
	local separator = string.rep("─", 50)
	M.render_lines({ "", separator, "" })
end

function M.render_lines(lines)
	for _, line in ipairs(lines) do
        M.render_line(line)
	end
end

function M.render_line(line)
    api.nvim_buf_set_lines(chat_buffer, chat_index, -1, false, { line })
    chat_index = chat_index + 1
end

function M.render_empty_prompt()
    prompt_index = chat_index
    local prompt_text = string.format("%s %s: ", chat_avatars["user"], chat_aliases["user"])
    M.render_line(prompt_text)
    api.nvim_win_set_cursor(chat_window, { chat_index, #prompt_text })
end

function M.split_message_to_lines(content)
    local lines = {}
    for line in string.gmatch(content, "[^\n]+") do
        table.insert(lines, line)
    end
    return lines
end

function M.add_message_to_history(sender, content_type, content)
	table.insert(chat_history, {
		sender = sender,
		content_type = content_type,
		content = content,
	})
end

-- Function to get the user input from the chat window
function M.get_user_input()
    local lines = api.nvim_buf_get_lines(chat_buffer, prompt_index, -1, false)
    return table.concat(lines, "\n"):match(":%s*(.*)")
end

-- Function to handle user input when <leader>as is pressed
function M.handle_user_input()
    local input_content = M.get_user_input()
    M.add_message_to_history("user", "message", input_content)
    M.get_llm_response(input_content, M.handle_llm_response)
end

-- Function to call the Claude provider and get a response
function M.get_llm_response(input, response_callback)
    M.start_thinking_animation()
    llm_provider.send_prompt(input, response_callback)
end

function M.handle_llm_response(response_content)
    M.add_message_to_history("llm", "message", response_content)
    M.add_message_to_history("chat", "separator", nil)
    vim.schedule(M.stop_thinking_animation)
    vim.schedule(M.render_chat)
end


-- TODO: refactor the following
function M.start_thinking_animation()
    local dots = { "Thinking", "Thinking.", "Thinking..", "Thinking..." }
    local i = 1

    thinking_line_index = api.nvim_buf_line_count(chat_buffer) + 1
    thinking_timer = vim.loop.new_timer()
    thinking_timer:start(
        0,
        250,
        vim.schedule_wrap(function()
            i = (i % #dots) + 1
            api.nvim_buf_set_lines(
                chat_buffer,
                thinking_line_index - 1,
                thinking_line_index,
                false,
                { "🤖 LLM: " .. dots[i] }
            )
        end)
    )
end

function M.stop_thinking_animation()
    if thinking_timer then
        thinking_timer:stop()
        thinking_timer:close()
        thinking_timer = nil
    end

    -- Optionally clear that line (or replace in add_message)
    api.nvim_buf_set_lines(chat_buffer, thinking_line_index - 1, thinking_line_index, false, {})
    thinking_line_index = nil
end

return M
