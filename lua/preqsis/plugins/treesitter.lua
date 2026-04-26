return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false,
		build = ":TSUpdate",
		config = function()
			local ts = require("nvim-treesitter")
			ts.setup({})

			local langs = {
				"python",
				"lua",
				"bash",
				"yaml",
				"toml",
				"json",
				"terraform",
				"hcl",
				"markdown",
				"markdown_inline",
			}

			ts.install(langs)

			-- map parser names to filetypes where they differ
			local ft_pattern = {
				"python",
				"lua",
				"bash",
				"sh",
				"yaml",
				"toml",
				"json",
				"terraform",
				"hcl",
				"markdown",
			}

			vim.api.nvim_create_autocmd("FileType", {
				pattern = ft_pattern,
				callback = function(ev)
					pcall(vim.treesitter.start, ev.buf)
					vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end,
			})
		end,
	},

	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		branch = "main",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
		},
		config = function()
			require("nvim-treesitter-textobjects").setup({
				select = {
					lookahead = true,
				},
			})

			local select = require("nvim-treesitter-textobjects.select")

			local map = function(lhs, query, desc)
				vim.keymap.set({ "x", "o" }, lhs, function()
					select.select_textobject(query, "textobjects")
				end, { desc = desc })
			end

			map("as", "@assignment.outer", "Select outer part of an assignment")
			map("is", "@assignment.inner", "Select inner part of an assignment")
			map("ls", "@assignment.lhs", "Select left hand side of an assignment")
			map("rs", "@assignment.rhs", "Select right hand side of an assignment")

			map("ai", "@conditional.outer", "Select outer part of a conditional")
			map("ii", "@conditional.inner", "Select inner part of a conditional")

			map("al", "@loop.outer", "Select outer part of a loop")
			map("il", "@loop.inner", "Select inner part of a loop")

			map("ac", "@call.outer", "Select outer part of a function call")
			map("ic", "@call.inner", "Select inner part of a function call")

			map("af", "@function.outer", "Select outer part of a method/function definition")
			map("if", "@function.inner", "Select inner part of a method/function definition")
		end,
	},
}

-- return {
--   "nvim-treesitter/nvim-treesitter",
--   build = ":TSUpdate",
--   event = { "BufReadPre", "BufNewFile" },
--   dependencies = {
--     "nvim-treesitter/nvim-treesitter-textobjects",
--   },
--   config = function()
--     local configs = require("nvim-treesitter.configs")
--
--     configs.setup({
--       ensure_installed = {
--         "python", "lua", "bash", "yaml", "toml", "json",
--         "terraform", "markdown",
--       },
--       sync_install = false,
--       auto_install = true,
--       highlight = { enable = true },
--       indent = { enable = true },
--       incremental_selection = {
--         enable = true,
--         keymaps = {
--           init_selection = "<C-space>",
--           node_incremental = "<C-space>",
--           scope_incremental = false,
--           node_decremental = "<bs>",
--         },
--       },
--       textobjects = {
--         select = {
--           enable = true,
--           lookahead = true,
--           keymaps = {
--             ["as"] = { query = "@assignment.outer", desc = "Select outer part of an assignment." },
--             ["is"] = { query = "@assignment.inner", desc = "Select inner part of an assignment." },
--             ["ls"] = { query = "@assignment.lhs", desc = "Select left hand side of an assignment." },
--             ["rs"] = { query = "@assignment.rhs", desc = "Select right hand side of an assignment." },
--             ["ai"] = { query = "@conditional.outer", desc = "Select outer part of a conditional." },
--             ["ii"] = { query = "@conditional.inner", desc = "Select inner part of a conditional." },
--             ["al"] = { query = "@loop.outer", desc = "Select outer part of a loop." },
--             ["il"] = { query = "@loop.inner", desc = "Select inner part of a loop." },
--             ["ac"] = { query = "@call.outer", desc = "Select outer part of a function call." },
--             ["ic"] = { query = "@call.inner", desc = "Select inner part of a function call." },
--             ["af"] = { query = "@function.outer", desc = "Select outer part of a method/function definition." },
--             ["if"] = { query = "@function.inner", desc = "Select inner part of a method/function definition." },
--           },
--         },
--       },
--     })
--
--     vim.api.nvim_create_autocmd({ "FileType", "BufReadPost", "BufNewFile" }, {
--       callback = function(args)
--         pcall(vim.treesitter.start, args.buf)
--       end,
--     })
--   end,
-- }
