return {
	"olimorris/codecompanion.nvim",
	dependencies = { "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter" },
	opts = {
		strategies = {
			chat = {
				adapter = "anthropic",
				keymaps = {
					send = {
						modes = { n = "<C-h>", i = "<C-h>" },
					},
				},
			},
			inline = {
                adapter = "anthropic",
                keymaps = {
                    accept_change = { modes = { n = "ga" } },
                    reject_change = { modes = { n = "gr" } },
                }
            },
		},
		adapters = {
			http = {
				anthropic = function()
					return require("codecompanion.adapters").extend("anthropic", {
						env = { api_key = "ANTHROPIC_API_KEY" },
						schema = {
							-- model = { default = "claude-3-5-sonnet-latest" }, -- pick your Claude
							model = { default = "claude-sonnet-4-20250514" },
						},
					})
				end,
			},
		},
		display = {
            chat = {
                show_settings = false,
                window = {
                    layout = "vertical",
                    position = "right",
                    border = "single",
                    height = 0.8,
                    withd = 0.45
                }
            },
        },
	},
}
