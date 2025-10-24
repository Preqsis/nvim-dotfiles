-- DETELE: this might not be needed at all!!

return {
	{
		"coffebar/neovim-project",
		opts = {
			projects = { -- define project roots
				"~/Projects/work/repo/*/*",
			},
			last_session_on_startup = false,
		},
		init = function()
			-- enable saving the state of plugins in the session
			vim.opt.sessionoptions:append("globals") -- save global variables that start with an uppercase letter and contain at least one lowercase letter.
		end,
		dependencies = {
			{ "nvim-lua/plenary.nvim" },
			{ "nvim-telescope/telescope.nvim", tag = "0.1.4" },
			{ "Shatur/neovim-session-manager" },
		},
		lazy = false,
		priority = 100,
	},
	-- {
	--     "notjedi/nvim-rooter.lua",
	--     config = function()
	--         require("nvim-rooter").setup()
	--     end,
	-- },
	-- {
	--     "linux-cultist/venv-selector.nvim",
	--     dependencies = {
	--         "neovim/nvim-lspconfig",
	--         "mfussenegger/nvim-dap",
	--         -- "mfussenegger/nvim-dap-python", --optional
	--         "nvim-telescope/telescope.nvim",
	--     },
	--     opts = {
	--         auto_refresh = true,
	--     },
	--     event = "VeryLazy",
    --     branch = "regexp",
	--     keys = {
	--         { ",fv", "<cmd>VenvSelect<cr>" },
	--     },
	-- },
}
