return {
    'folke/todo-comments.nvim',
    dependencies = {"nvim-lua/plenary.nvim"},
    opts = {},
    config = function()
        local todo = require("todo-comments")

        todo.setup({
            keywords = {
                DEL = {
                    icon = "󰆳", color = "error", alt = {"DELETE"}
                }
            },
            highlight = {
                multiline = false,
            },
            search = {
                command = "rg",
                args = {
                    "--color=never",
                    "--no-heading",
                    "--with-filename",
                    "--line-number",
                    "--column",
                },
                -- regex that will be used to match keywords.
                -- don't replace the (KEYWORDS) placeholder
                pattern = [[\b(KEYWORDS):]], -- ripgrep regex
                -- pattern = [[\b(KEYWORDS)\b]], -- match without the extra colon. You'll likely get false positives
            },
        })

        vim.keymap.set('n', '<leader>fm', '<cmd>TodoTelescope<cr>', {})
    end
}
