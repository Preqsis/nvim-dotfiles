local core = require("nvim-llm.core")
local selection = require("nvim-llm.selection")
local chat = require("nvim-llm.chat")

local M = {}

-- function M.ask_with_selection(provider)
--     local selected_text = selection.get_visual_selection()
--
--     if selected_text == "" then
--         vim.notify("[nvim-llm] No text selected!", vim.log.levels.ERROR)
--         return
--     end
--
--     core.send_to_provider(provider, selected_text)
-- end
--
-- function M.ask_with_line(provider)
--     local current_line = vim.fn.getline(".")
--     core.send_to_provider(provider, current_line)
-- end
--
-- -- Start a chat session and send a prompt to the LLM
-- function M.start_chat_and_send_prompt(provider)
--     -- First, open the vertical split chat window
--     chat.run(provider)
--
--     -- Ask the user for the initial prompt
--     -- local input = vim.fn.input("Enter your prompt: ")
--
--     -- Send the prompt to Claude (or other LLM provider)
--     -- core.send_to_provider(provider, input)
-- end

-- Toggle the chat window
function M.toggle_chat()
    chat.toggle_chat_window()
end

return M
