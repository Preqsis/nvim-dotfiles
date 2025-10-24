return {
	"akinsho/bufferline.nvim",
	version = "*",
	event = "VeryLazy",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
		{ "catppuccin/nvim", name = "catppuccin" }, -- <- ensure it's installed/loaded
	},
	config = function()
		local ok_cat, cat = pcall(require, "catppuccin.groups.integrations.bufferline")
		require("bufferline").setup({
			highlights = ok_cat and cat.get() or {}, -- fall back if catppuccin isn't ready
			options = {
				-- your options...
			},
		})
	end,
}
