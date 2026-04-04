return {
	dir = "~/Projects/personal/neovim/nvim-pyseep",
	config = function()
		require("nvim-pyseep").setup({
			max_depth = 40,
		})
	end,
	cmd = {
		"PySeepWhy",
		"PSWhy",
		"PySeepChain",
		"PSChain",
		"PySeepTree",
		"PSTree",
		"PySeepRoots",
		"PSRoots",
		"PySeepDeps",
		"PSDeps",
	},
	keys = {},
}
