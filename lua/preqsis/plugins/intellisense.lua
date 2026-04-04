return {
    -- Auto-completion
	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-nvim-lsp-signature-help", -- ← signature help in completion menu (great for Python)
			"L3MON4D3/LuaSnip",
			"saadparwaiz1/cmp_luasnip",
			"rafamadriz/friendly-snippets",
			"onsails/lspkind.nvim",
			-- optional but recommended for () on confirm:
			{ "windwp/nvim-autopairs", config = true },
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")
			local lspkind = require("lspkind")

			-- Load VS Code-style snippets
			require("luasnip.loaders.from_vscode").lazy_load()

			-- Global completion UI behavior
			vim.o.completeopt = "menu,menuone,noinsert,noselect"

			-- Super-Tab: tab to jump/expand snippets, else navigate menu
			local has_words_before = function()
				local line, col = unpack(vim.api.nvim_win_get_cursor(0))
				if col == 0 then
					return false
				end
				local prev = vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col)
				return not prev:match("%s")
			end

			cmp.setup({
				preselect = cmp.PreselectMode.None,
				performance = {
					debounce = 60,
					throttle = 30,
					fetching_timeout = 200,
				},
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				window = {
					completion = cmp.config.window.bordered(),
					documentation = cmp.config.window.bordered(),
				},
				formatting = {
					format = lspkind.cmp_format({
						mode = "symbol_text",
						maxwidth = 60,
						ellipsis_char = "…",
						show_labelDetails = true,
					}),
				},
				mapping = cmp.mapping.preset.insert({
					["<C-k>"] = cmp.mapping.select_prev_item(),
					["<C-j>"] = cmp.mapping.select_next_item(),
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-e>"] = cmp.mapping.abort(),
					["<CR>"] = cmp.mapping.confirm({ select = false }),

					-- Super-Tab
					["<Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						elseif luasnip.expand_or_jumpable() then
							luasnip.expand_or_jump()
						elseif has_words_before() then
							cmp.complete()
						else
							fallback()
						end
					end, { "i", "s" }),
					["<S-Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						elseif luasnip.jumpable(-1) then
							luasnip.jump(-1)
						else
							fallback()
						end
					end, { "i", "s" }),
				}),

				-- Sources: prioritize LSP + snippets; make buffer/path less eager
				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
					{ name = "nvim_lsp_signature_help" }, -- python call signatures inline
					{ name = "luasnip" },
					{ name = "path", keyword_length = 2 },
					{ name = "buffer", keyword_length = 3 },
				}),

				-- Subtle ghost text (optional)
				experimental = { ghost_text = false },
			})

			-- Optional: filetype-specific tweaks (examples)
			cmp.setup.filetype({ "gitcommit", "markdown" }, {
				sources = cmp.config.sources({
					{ name = "path" },
					{ name = "buffer", keyword_length = 2 },
					{ name = "luasnip" },
				}),
			})
		end,
	},
    -- Renaming
	{
		"smjonas/inc-rename.nvim",
		config = function()
			require("inc_rename").setup()

			vim.keymap.set("n", "<leader>rn", function()
				return ":IncRename " .. vim.fn.expand("<cword>")
			end, { expr = true })
		end,
	},
}
