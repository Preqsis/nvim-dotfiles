return {
	-- Theme
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		config = function()
			vim.opt.termguicolors = true
			require("catppuccin").setup({
				flavour = "mocha",
				term_colors = true,
				styles = {
					functions = { "bold" },
					conditionals = {},
				},
				integrations = {
					treesitter = true,
					telescope = { enabled = true },
					native_lsp = { enabled = true },
					nvimtree = true,
					gitsigns = true,
					cmp = true,
					indent_blankline = { enabled = true },
				},
				custom_highlights = function()
					return {
						LineNr = { fg = "#00cccc" },
						CursorLineNr = { fg = "#ffff00" },
						ColorColumn = { bg = "#220404" }, -- dark red for column 121
					}
				end,
			})
			vim.cmd.colorscheme("catppuccin")
			vim.o.signcolumn = "yes"
			vim.opt.colorcolumn = "121"
		end,
	},

	-- NeoTree (tree style file browser)
	{
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
					},
				},
			})

			vim.keymap.set("n", "<leader>g", ":Neotree toggle<CR>", {})
			-- vim.keymap.set("n", "<leader>gg", ":Neotree toggle position=float<CR>", {})
		end,
	},

	-- Lualnie (bottom info line)
	{
		"nvim-lualine/lualine.nvim",
		dependencies = "nvim-tree/nvim-web-devicons",
		config = function()
			require("lualine").setup({
				options = {
					icons_enabled = true,
					theme = "auto",
					component_separators = { left = "", right = "" },
					section_separators = { left = "", right = "" },
					disabled_filetypes = {
						statusline = {},
						winbar = {},
					},
					ignore_focus = {},
					always_divide_middle = true,
					globalstatus = true,
					refresh = {
						statusline = 1000,
						tabline = 1000,
						winbar = 1000,
					},
				},
				sections = {
					lualine_a = { "mode" },
					lualine_b = { "branch", "diff", "diagnostics" },
					lualine_c = {
						{
							"filename",
							path = 1,
						},
					},
					lualine_x = { "encoding", "fileformat", "filetype" },
					lualine_y = { "progress" },
					lualine_z = { "location" },
				},
				inactive_sections = {
					lualine_a = {},
					lualine_b = {},
					lualine_c = { "filename" },
					lualine_x = { "location" },
					lualine_y = {},
					lualine_z = {},
				},
				tabline = {},
				winbar = {},
				inactive_winbar = {},
				extensions = {},
			})
		end,
	},

	-- Bufferline (top buffer list)
	{
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
	},

	-- Indent guides and scope highlighting
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			local colors = {}
			pcall(function()
				colors = require("catppuccin.palettes").get_palette("mocha")
			end)

			require("ibl").setup({
				indent = {
					char = "│", -- or "▏" for even lighter
					highlight = { "IblIndent" },
				},
				whitespace = { remove_blankline_trail = true },
				scope = {
					enabled = true,
					show_start = true,
					show_end = true,
					highlight = { "IblScope" },
					include = {
						node_type = {
							python = {
								"function_definition",
								"class_definition",
								"if_statement",
								"for_statement",
								"while_statement",
								"with_statement",
								"try_statement",
								"except_clause",
							},
						},
					},
				},
				exclude = {
					filetypes = {
						"help",
						"alpha",
						"dashboard",
						"neo-tree",
						"NvimTree",
						"lazy",
						"mason",
						"TelescopePrompt",
						"Trouble",
						"terminal",
						"quickfix",
						"notify",
						"gitcommit",
					},
					buftypes = { "terminal", "nofile", "prompt" },
				},
			})

			if next(colors) ~= nil then
				vim.api.nvim_set_hl(0, "IblIndent", { fg = colors.surface2, nocombine = true })
				vim.api.nvim_set_hl(0, "IblScope", { fg = colors.overlay0, nocombine = true })
			else
				vim.api.nvim_set_hl(0, "IblIndent", { fg = "#3b3f52", nocombine = true })
				vim.api.nvim_set_hl(0, "IblScope", { fg = "#5b6078", nocombine = true })
			end

			vim.keymap.set("n", "<leader>ti", function()
				require("ibl").setup_buffer(0, { enabled = not require("ibl.config").get_config(0).enabled })
			end, { desc = "Toggle indent guides" })

			vim.api.nvim_create_autocmd("BufReadPre", {
				callback = function(args)
					local ok, stats = pcall(vim.loop.fs_stat, args.file)
					if ok and stats and stats.size > 2 * 1024 * 1024 then
						require("ibl").setup_buffer(args.buf, { enabled = false })
					end
				end,
			})
		end,
	},

	-- Surround text-objects (editing helper)
	{
		"kylechui/nvim-surround",
		version = "*",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			require("nvim-surround").setup({})
		end,
	},

	-- TODO comments & navigation
	{
		"folke/todo-comments.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			local todo = require("todo-comments")
			todo.setup({
				keywords = {
					DEL = { icon = "󰆳", color = "error", alt = { "DELETE" } },
					BUG = { icon = "", color = "error" },
					WIP = { icon = "", color = "info", alt = { "INPROGRESS" } },
				},
				highlight = { multiline = false, keyword = "wide", after = "fg" },
				colors = {
					error = { "DiagnosticError", "ErrorMsg", "#DC2626" },
					warn = { "DiagnosticWarn", "WarningMsg", "#F59E0B" },
					info = { "DiagnosticInfo", "#2563EB" },
					hint = { "DiagnosticHint", "#10B981" },
					default = { "Identifier", "#7C3AED" },
				},
				search = {
					command = "rg",
					args = {
						"--color=never",
						"--no-heading",
						"--with-filename",
						"--line-number",
						"--column",
						"--hidden",
						"--glob=!.git/*",
					},
					pattern = [[\b(KEYWORDS):]],
				},
				signs = true,
			})
			vim.keymap.set("n", "<leader>tm", "<cmd>TodoTelescope<CR>", { desc = "Search TODOs (Telescope)" })
		end,
	},

	-- Tmux integration
	{
		"aserowy/tmux.nvim",
		config = function()
			return require("tmux").setup({
				copy_sync = {
					enable = false,
				},
				resize = {
					enable_default_keybindings = false,
				},
			})
		end,
	},

	-- Nerd-commenter
	{
		"preservim/nerdcommenter",
		config = function()
			-- Create default mappings
			vim.g.NERDCreateDefaultMappings = 1
			-- Add spaces after comment delimiters by default
			vim.g.NERDSpaceDelims = 1
			-- Use compact syntax for prettified multi-line comments
			vim.g.NERDCompactSexyComs = 1
			-- Align line-wise comment delimiters flush left instead of following code indentation
			vim.g.NERDDefaultAlign = "left"
			-- Set a language to use its alternate delimiters by default
			vim.g.NERDAltDelims_java = 1
			-- Allow commenting and inverting empty lines (useful when commenting a region)
			vim.g.NERDCommentEmptyLines = 1
			-- Enable trimming of trailing whitespace when uncommenting
			vim.g.NERDTrimTrailingWhitespace = 1
            -- Enable NERDCommenterToggle to check all selected lines is commented or not
			vim.g.NERDToggleCheckAllLines = 1
		end,
	},
}
