local M = {}

local commands = require("nvim-llm.commands")

function M.setup()
    M.setup_default_keymaps()
end

function M.setup_default_keymaps()
    -- OpenAI
    vim.keymap.set("v", "<leader>ai", function()
        commands.ask_with_selection("openai")
    end, { desc = "Trigger LLM with selected text" })

    vim.keymap.set("n", "<leader>ai", function()
        commands.ask_with_line("openai")
    end, { desc = "Trigger LLM with current line" })

    -- Claude
    vim.keymap.set("v", "<leader>ac", function()
        commands.ask_with_selection("claude")
    end, { desc = "Trigger LLM with selected text (Claude)" })

    vim.keymap.set("n", "<leader>ac", function()
        commands.ask_with_line("claude")
    end, { desc = "Trigger LLM with current line (Claude)" })

    -- Toggle chat window
    vim.keymap.set("n", "<leader>av", function()
        commands.toggle_chat()
    end, { desc = "Toggle LLM chat in vertical split (Claude)" })

    -- Send input to LLM
    vim.keymap.set("n", "<leader>as", function()
        require("nvim-llm.chat").handle_user_input()
    end, { desc = "Send user input to LLM" })

    vim.keymap.set("n", "<C-f>", function()
        require("nvim-llm.chat").handle_user_input()
    end, { noremap = true, silent = true })

    vim.keymap.set("i", "<C-f>", function()
        require("nvim-llm.chat").handle_user_input()
    end, { noremap = true, silent = true })
end

return M

