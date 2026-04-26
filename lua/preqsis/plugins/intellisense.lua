return {
	-- Auto-completion
	{
		"saghen/blink.cmp",
		version = "1.*",
		event = "InsertEnter",
		dependencies = {
			"rafamadriz/friendly-snippets",
		},
		keys = {
			{
				"<Esc>",
				function()
					if vim.snippet.active() then
						vim.snippet.stop()
					end
					return "<Esc>"
				end,
				mode = { "i", "s" },
				expr = true,
				desc = "Exit snippet and leave insert mode",
			},
		},
		opts = {
			keymap = {
				preset = "none",
				["<C-k>"] = { "select_prev", "fallback" },
				["<C-j>"] = { "select_next", "fallback" },
				["<C-b>"] = { "scroll_documentation_up" },
				["<C-f>"] = { "scroll_documentation_down" },
				["<C-Space>"] = { "show" },
				["<C-e>"] = { "hide", "fallback" },
				["<CR>"] = { "accept", "fallback" },
				["<Tab>"] = { "snippet_forward", "select_next", "fallback" },
				["<S-Tab>"] = { "snippet_backward", "select_prev", "fallback" },
			},
			completion = {
				list = {
					selection = { preselect = true, auto_insert = false },
				},
				menu = {
					border = "single",
				},
				documentation = {
					auto_show = true,
					window = { border = "single" },
				},
				ghost_text = { enabled = false },
				accept = {
					auto_brackets = { enabled = true },
				},
			},
			signature = {
				enabled = true,
				window = { border = "single" },
			},
			sources = {
				default = { "lsp", "path", "snippets", "buffer" },
				per_filetype = {
					gitcommit = { "path", "buffer", "snippets" },
					markdown = { "path", "buffer", "snippets" },
				},
				providers = {
					buffer = { min_keyword_length = 3 },
					path = { min_keyword_length = 2 },
				},
			},
		},
	},

	-- -- Renaming
	-- {
	-- 	"smjonas/inc-rename.nvim",
	-- 	keys = {
	-- 		{
	-- 			"<leader>rn",
	-- 			function()
	-- 				return ":IncRename " .. vim.fn.expand("<cword>")
	-- 			end,
	-- 			expr = true,
	-- 			desc = "Incremental rename",
	-- 		},
	-- 	},
	-- 	config = function()
	-- 		require("inc_rename").setup()
	-- 	end,
	-- },

    -- Auto-pairs
	{ "windwp/nvim-autopairs", event = "InsertEnter", config = true },
}
