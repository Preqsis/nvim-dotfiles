return {
    "nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
        "MunifTanjim/nui.nvim",
	},
	config = function()
		local neo_tree = require("neo-tree")
		neo_tree.setup({
            enable_diagnostics = true,
			source_selector = {
				winbar = false,
				statuslien = false,
			},
            filesystem = {
                filtered_items = {
                    hide_dotfiles = false,
                    hide_gitignored = false,
                },
                follow_current_file = {
                    enabled = false,
                    leave_dirs_open = false,
                }
            }
		})

		vim.keymap.set("n", "<leader>g", ":Neotree toggle<CR>", {})
        -- vim.keymap.set("n", "<leader>gg", ":Neotree toggle position=float<CR>", {})
    end,
}
