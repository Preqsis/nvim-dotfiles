return {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
        "nvim-treesitter/nvim-treesitter-textobjects",
    },
    config = function ()
        require("nvim-treesitter.configs").setup({
            ensure_installed = {
                "python",
                "lua",
                "bash",
                "yaml",
                "toml",
                "json",
                "terraform",
                "markdown"
            },
            sync_install = false,
            auto_install = true,
            highlight = {
                enable = true,
                additional_vim_regex_highlighting = false,
            },
            indent = {
                enable = true,
            },
            incremental_selection = {
                enable = true,
                keymaps = {
                    init_selection = "<C-space>",
                    node_incremental = "<C-space>",
                    scope_incremental = false,
                    node_decremental = "<bs>",
                },
            },
            textobjects = {
                select = {
                    enable = true,
                    lookahead = true,

                    keymaps = {
                        ["as"] = { query = "@assignment.outer", desc = "Select outer part of an assignment." },
                        ["is"] = { query = "@assignment.inner", desc = "Select inner part of an assignment." },
                        ["ls"] = { query = "@assignment.lhs", desc = "Select left hand side of an assignment." },
                        ["rs"] = { query = "@assignment.rhs", desc = "Select right hand side of an assignment." },

                        ["ai"] = { query = "@conditional.outer", desc = "Select inner part of a conditional." },
                        ["ii"] = { query = "@conditional.inner", desc = "Select outer part of a conditional." },

                        ["al"] = { query = "@loop.outer", desc = "Select inner part of a loop." },
                        ["il"] = { query = "@loop.inner", desc = "Select outer part of a loop." },

                        ["ac"] = { query = "@call.outer", desc = "Select inner part of a function call." },
                        ["ic"] = { query = "@call.inner", desc = "Select outer part of a function call." },

                        ["af"] = { query = "@function.outer", desc = "Select inner part of a method/function definition." },
                        ["if"] = { query = "@function.inner", desc = "Select outer part of a method/function definition." },
                    },
                },
            },
        })
    end
}



-- return {
--     "nvim-treesitter/nvim-treesitter",
--     -- run = vim.cmd.TSUpdate,
--     dependencies = {
--         "nvim-treesitter/nvim-treesitter-textobjects",
--         "p00f/nvim-ts-rainbow", -- rainbow brackets
--     },
--     config = function()
--         require("nvim-treesitter.configs").setup({
--             ensure_installed = {
--                 "python",
--                 "lua",
--                 "bash",
--                 "yaml",
--                 "json",
--                 "terraform",
--                 "markdown"
--             },
--             sync_install = false,
--             highlight = {
--                 enable = true,
--             },
--             rainbow = {
--                 enable = true,
--             },
--             indent = {
--                 enable = true,
--             },
--             incremental_selection = {
--                 enable = true,
--                 keymaps = {
--                     init_selection = "<C-space>",
--                     node_incremental = "<C-space>",
--                     scope_incremental = false,
--                     node_decremental = "<bs>",
--                 },
--             },
--             textobjects = {
--                 select = {
--                     enable = true,
--                     lookahead = true,
--
--                     keymaps = {
--                         ["as"] = { query = "@assignment.outer", desc = "Select outer part of an assignment." },
--                         ["is"] = { query = "@assignment.inner", desc = "Select inner part of an assignment." },
--                         ["ls"] = { query = "@assignment.lhs", desc = "Select left hand side of an assignment." },
--                         ["rs"] = { query = "@assignment.rhs", desc = "Select right hand side of an assignment." },
--
--                         ["ai"] = { query = "@conditional.outer", desc = "Select inner part of a conditional." },
--                         ["ii"] = { query = "@conditional.inner", desc = "Select outer part of a conditional." },
--
--                         ["al"] = { query = "@loop.outer", desc = "Select inner part of a loop." },
--                         ["il"] = { query = "@loop.inner", desc = "Select outer part of a loop." },
--
--                         ["ac"] = { query = "@call.outer", desc = "Select inner part of a function call." },
--                         ["ic"] = { query = "@call.inner", desc = "Select outer part of a function call." },
--
--                         ["af"] = { query = "@function.outer", desc = "Select inner part of a method/function definition." },
--                         ["if"] = { query = "@function.inner", desc = "Select outer part of a method/function definition." },
--                     },
--                 },
--             },
--         })
--     end,
-- }
