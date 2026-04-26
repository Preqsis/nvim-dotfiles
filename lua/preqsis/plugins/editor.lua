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
					neotree = true,
					gitsigns = true,
					blink_cmp = true,
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
		cmd = "Neotree",
		keys = {
			{ "<leader>g", "<cmd>Neotree toggle<CR>", desc = "Toggle Neo-tree" },
		},
		config = function()
			local neo_tree = require("neo-tree")
			neo_tree.setup({
				enable_diagnostics = true,
				source_selector = {
					winbar = false,
					statusline = false,
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
		end,
	},

	-- Lualnie (bottom info line)
	{
		"nvim-lualine/lualine.nvim",
		dependencies = "nvim-tree/nvim-web-devicons",
		config = function()
			require("lualine").setup({
				options = {
					component_separators = { left = "", right = "" },
					section_separators = { left = "", right = "" },
					globalstatus = true,
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
					local ok, stats = pcall(vim.uv.fs_stat, args.file)
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
		keys = {
			{ "<leader>tm", "<cmd>TodoTelescope<CR>", desc = "Search TODOs (Telescope)" },
		},
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
		end,
	},

	-- Session persistence
	{
		"folke/persistence.nvim",
		event = "BufReadPre",
		keys = {
			{ "<leader>ql", "<cmd>SessionLoad<CR>", desc = "Session load (cwd)" },
		},
		opts = {
		},
		init = function()
			-- custom commands
			vim.api.nvim_create_user_command("SessionLoad", function()
				require("persistence").load()
			end, {})

			vim.api.nvim_create_user_command("SessionLast", function()
				require("persistence").load({ last = true })
			end, {})

			vim.api.nvim_create_user_command("SessionSelect", function()
				require("persistence").select()
			end, {})
			
            -- Clean up non-file buffers before session save
			local excluded_fts = { "neo-tree", "codecompanion" }
			vim.api.nvim_create_autocmd("VimLeavePre", {
				callback = function()
					for _, buf in ipairs(vim.api.nvim_list_bufs()) do
						if vim.api.nvim_buf_is_valid(buf) then
							local ft = vim.bo[buf].filetype
							if vim.tbl_contains(excluded_fts, ft) then
								pcall(vim.api.nvim_buf_delete, buf, { force = true })
							end
						end
					end
				end,
			})

			vim.api.nvim_create_autocmd("VimEnter", {
				nested = true,
				callback = function()
					if vim.fn.argc() == 0 and not vim.g.started_with_stdin then
						vim.schedule(function()
							require("persistence").load()
						end)
					end
				end,
			})
		end,
	},

	-- WezTerm pane navigation
	{
		"mrjones2014/smart-splits.nvim",
		event = "VeryLazy",
		config = function()
			require("smart-splits").setup({
				at_edge = "stop",
			})
			vim.keymap.set("n", "<C-h>", require("smart-splits").move_cursor_left, { desc = "Move to left split/pane" })
			vim.keymap.set("n", "<C-j>", require("smart-splits").move_cursor_down, { desc = "Move to below split/pane" })
			vim.keymap.set("n", "<C-k>", require("smart-splits").move_cursor_up, { desc = "Move to above split/pane" })
			vim.keymap.set("n", "<C-l>", require("smart-splits").move_cursor_right, { desc = "Move to right split/pane" })
		end,
	},

	-- Treesitter-aware comment strings
	{
		"folke/ts-comments.nvim",
		event = "VeryLazy",
		opts = {},
	},
}
