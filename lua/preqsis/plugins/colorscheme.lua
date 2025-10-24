return {
    {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
        local catppuccin = require("catppuccin")

        catppuccin.setup({
            flavour = "mocha",
            term_colors = false,
            -- dim_inactive = {
                -- enabled = true,
                -- shade = "dark",
                -- percentage = 0.15
            -- },
            styles = {
                functions = {"bold"},
                conditionals = {}
            },
            integrations = {
                nvimtree = true,
                gitsigns = true,
                cmp = true,
                -- bufferline = true,
                indent_blankline = {
                    enabled = true
                }
            }
        })

        vim.cmd.colorscheme "catppuccin"

        -- Set line numbers colors
        vim.api.nvim_set_hl(0, "LineNr", {fg="#00cccc"})
        vim.api.nvim_set_hl(0, "CursorLineNr", {fg="#ffff00"})
        vim.o.signcolumn = "yes"

        -- Highlight column 121
        -- very dark red
        vim.opt.colorcolumn = "101"
        vim.api.nvim_set_hl(0, "ColorColumn", {bg="#220404"})
    end
    },
    -- {
        -- "xiyaowong/transparent.nvim",
        -- config = function ()
            -- require('transparent').clear_prefix('lualine')
            -- require('transparent').clear_prefix('BufferLine')
        -- end
--
    -- }
}
