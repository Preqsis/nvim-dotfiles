return {
	"nvim-telescope/telescope.nvim",
	branch = "0.1.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-telescope/telescope-file-browser.nvim",
		"nvim-telescope/telescope-ui-select.nvim",
	},
	config = function()
		local telescope_status, telescope = pcall(require, "telescope")
		if not telescope_status then
			print("Failed to require 'telescope'")
			return
		end

		local telescope_actions_status, telescope_actions = pcall(require, "telescope.actions")
		if not telescope_actions_status then
			print("Failse to require 'telescope.actionss'")
			return
		end

		telescope.setup({
			defaults = {
				mappings = {
					i = {
						["<C-j>"] = telescope_actions.move_selection_next,
						["<C-k>"] = telescope_actions.move_selection_previous,
					},
				},
			},
			extensions = {
				file_browser = {
					-- disables netrw and use telescope-file-browser in its place
					hijack_netrw = true,
					mappings = {
						["i"] = {
							-- your custom insert mode mappings
						},
						["n"] = {
							-- your custom normal mode mappings
						},
					},
				},
				us_select = {
					require("telescope.themes").get_dropdown({}),
				},
			},
		})

		telescope.load_extension("file_browser")

		local telescope_builtin_status, telescope_builtin = pcall(require, "telescope.builtin")
		if not telescope_builtin_status then
			print("Failed to require 'telescope.builtin")
			return
		end

		vim.keymap.set("n", "<leader>ff", telescope_builtin.find_files, {})
		-- vim.keymap.set("n", "<leader>fg", telescope_builtin.live_grep, {})
        vim.keymap.set("n", "<leader>fg", function()
            require("telescope.builtin").live_grep({
                additional_args = function() return { "--hidden", "--glob=!.git/*" } end,
            })
        end, {})
		vim.api.nvim_set_keymap("n", "<leader>fb", ":Telescope file_browser<cr>", { noremap = true })
		vim.api.nvim_set_keymap("n", "<leader>fp", ":Telescope neovim-project discover<cr>", { noremap = true })
		vim.api.nvim_set_keymap("n", "<leader>fh", ":Telescope neovim-project history<cr>", { noremap = true })
	end,
}
