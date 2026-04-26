return {
	"nvim-telescope/telescope.nvim",
	version = "*",
	dependencies = {
		"nvim-lua/plenary.nvim",
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		"nvim-telescope/telescope-file-browser.nvim",
		"nvim-telescope/telescope-ui-select.nvim",
		"nvim-telescope/telescope-live-grep-args.nvim",
	},
	config = function()
		local telescope = require("telescope")
		local actions = require("telescope.actions")
		local builtin = require("telescope.builtin")
		local themes = require("telescope.themes")

		local function project_root()
			local dir = vim.fn.expand("%:p:h")
			local git = vim.fn.systemlist("git -C " .. vim.fn.fnameescape(dir) .. " rev-parse --show-toplevel")[1]
			if git and vim.v.shell_error == 0 and git ~= "" then
				return git
			end
			return vim.uv.cwd()
		end

		telescope.setup({
			defaults = {
				prompt_prefix = "  ",
				selection_caret = "󰈺 ",
				path_display = { "truncate" },
				results_title = false,

				sorting_strategy = "ascending",
				selection_strategy = "reset",
				default_selection_index = 1,

				layout_config = {
					prompt_position = "bottom",
					width = 0.95,
					height = 0.85,
					preview_cutoff = 80,
				},

				vimgrep_arguments = {
					"rg",
					"--color=never",
					"--no-heading",
					"--with-filename",
					"--line-number",
					"--column",
					"--smart-case",
					"--hidden",
					"--glob=!.git/*",
				},

				file_ignore_patterns = {
					"%.git/",
					"__pycache__/",
					"%.pyc$",
					"%.pyo$",
					"%.venv/",
					"^venv/",
					"^.venv/",
					"^env/",
					"site%-packages/",
					"node_modules/",
					"dist/",
					"build/",
				},

				mappings = {
					i = {
						["<C-j>"] = actions.move_selection_next,
						["<C-k>"] = actions.move_selection_previous,
						["<C-u>"] = false,
						["<C-d>"] = false,
					},
				},

				preview = {
					timeout = 200,
					treesitter = false, -- TODO: enable when telescope fixes combatibility
				},

				dynamic_preview_title = true,
			},

			pickers = {
				find_files = {
					hidden = true,
					follow = true,
					find_command = { "rg", "--files", "--hidden", "--glob", "!.git/*" },
				},
				buffers = { sort_mru = true, ignore_current_buffer = true },
				diagnostics = { severity = nil },

				live_grep = {
					only_sort_text = true,
					default_selection_index = 1,
					selection_strategy = "reset",
				},
			},

			extensions = {
				file_browser = {
					hijack_netrw = true,
					respect_gitignore = true,
					hidden = true,
					grouped = true,
				},

				["ui-select"] = themes.get_dropdown({
					previewer = false,
					initial_mode = "insert",
					sorting_strategy = "ascending",
				}),

				live_grep_args = {
					auto_quoting = true,
					default_selection_index = 1,
					selection_strategy = "reset",
					only_sort_text = true,
				},

				fzf = {
					fuzzy = false,
					override_generic_sorter = true,
					override_file_sorter = true,
					case_mode = "smart_case",
				},
			},
		})

		pcall(telescope.load_extension, "fzf")
		pcall(telescope.load_extension, "file_browser")
		pcall(telescope.load_extension, "ui-select")
		pcall(telescope.load_extension, "live_grep_args")

		vim.keymap.set("n", "<leader>ff", function()
			builtin.find_files({ cwd = project_root() })
		end, { desc = "Find files (root)" })

		vim.keymap.set("n", "<leader>fg", function()
			local actions = require("telescope.actions")

			require("telescope").extensions.live_grep_args.live_grep_args({
				cwd = project_root(),
				sorting_strategy = "ascending",
				selection_strategy = "reset",
				default_selection_index = 1,
				only_sort_text = true,

				on_input_filter_cb = function(prompt)
					vim.schedule(function()
						pcall(actions.move_to_top, vim.api.nvim_get_current_buf())
					end)
					return { prompt = prompt }
				end,
			})
		end, { desc = "Live grep (root, with args)" })

		vim.keymap.set("n", "<leader>fr", builtin.oldfiles, { desc = "Recent files" })
		vim.keymap.set("n", "<leader>fd", builtin.diagnostics, { desc = "Diagnostics" })
		vim.keymap.set("n", "<leader>fs", builtin.lsp_document_symbols, { desc = "Document symbols" })
		vim.keymap.set(
			"n",
			"<leader>fb",
			"<cmd>Telescope file_browser path=%:p:h select_buffer=true<CR>",
			{ desc = "File browser" }
		)
		vim.keymap.set("n", "<leader>fm", builtin.git_commits, { desc = "Git commits" })
		vim.keymap.set("n", "<leader>fc", builtin.git_status, { desc = "Git status" })
	end,
}
