return {
    "stevearc/conform.nvim",
    lazy = true,
    event = { "BufReadPre", "BufNewFile" }, -- to disable, comment this out
    config = function()
        local conform = require("conform")

        conform.setup({
            formatters_by_ft = {
                lua = { "stylua" },
                python = { "isort", "black" },
                json = { "jq" },
            },
        })

        vim.keymap.set({ "n", "v" }, "<leader>ft", function()
            conform.format({
                lsp_fallback = true,
                async = true,
                timeout_ms = 100,
            })
        end, { desc = "Format file or range (in visual mode)" })
    end,
}
