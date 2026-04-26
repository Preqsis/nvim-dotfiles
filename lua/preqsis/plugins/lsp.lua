return {
	-- 1) Formatting: Conform (ruff format, no black/isort)
	{
		"stevearc/conform.nvim",
		event = { "BufReadPre", "BufNewFile" },
		opts = {
			-- run ruff fixes first, then ruff format; lsp_fallback covers other filetypes
			formatters_by_ft = {
				python = { "ruff_fix", "ruff_format" },
				lua = { "stylua" },
				json = { "jq" },
			},
			notify_on_error = true,
		},
		init = function()
			-- format keymap
			vim.keymap.set({ "n", "v" }, "<leader>cf", function()
				require("conform").format({
					lsp_format = "fallback",
					async = true,
					timeout_ms = 3000,
				})
			end, { desc = "Format file or selection" })
		end,
	},

	-- 2) LSP core (pyright, ruff, lua_ls)
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			{ "saghen/blink.cmp" },
			{ "nvim-telescope/telescope.nvim" },
			{ "antosha417/nvim-lsp-file-operations", config = true },
		},
		config = function()
			-- blink.cmp capabilities
			local capabilities = require("blink.cmp").get_lsp_capabilities()

			-- diagnostic signs
			vim.diagnostic.config({
				virtual_text = { severity = { min = vim.diagnostic.severity.WARN } },
				signs = {
					text = {
						[vim.diagnostic.severity.ERROR] = " ",
						[vim.diagnostic.severity.WARN] = " ",
						[vim.diagnostic.severity.HINT] = "󰠠 ",
						[vim.diagnostic.severity.INFO] = " ",
					},
				},
			})

			-- LSP keymaps via autocmd
			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(event)
					local buf = event.buf
					local function opts(desc)
						return { buffer = buf, silent = true, noremap = true, desc = desc }
					end

					vim.keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts("Go to definition"))
					vim.keymap.set("n", "grr", "<cmd>Telescope lsp_references<CR>", opts("References"))
					vim.keymap.set("n", "gri", "<cmd>Telescope lsp_implementations<CR>", opts("Implementations"))
					vim.keymap.set("n", "grt", "<cmd>Telescope lsp_type_definitions<CR>", opts("Type definitions"))
					vim.keymap.set(
						"n",
						"<leader>d",
						"<cmd>Telescope diagnostics bufnr=0<CR>",
						opts("Buffer diagnostics")
					)
					vim.keymap.set({ "n", "v" }, "gra", vim.lsp.buf.code_action, opts("Code action"))
					vim.keymap.set("n", "K", vim.lsp.buf.hover, opts("Hover"))
				end,
			})

			-- server configs (remove on_attach from each)
			vim.lsp.config("pyright", { capabilities = capabilities })
			vim.lsp.config("ruff", {
				capabilities = capabilities,
				init_options = { settings = { args = {} } },
			})
			vim.lsp.config("lua_ls", {
				capabilities = capabilities,
				settings = {
					Lua = {
						diagnostics = { globals = { "vim" } },
						workspace = {
							library = vim.api.nvim_list_runtime_paths(),
							checkThirdParty = false,
						},
						telemetry = { enable = false },
					},
				},
			})

			vim.lsp.enable("pyright")
			vim.lsp.enable("ruff")
			vim.lsp.enable("lua_ls")
		end,
	},

	-- 3) Mason (servers + tools managed in one place)
	{
		"williamboman/mason.nvim",
		build = ":MasonUpdate",
		config = function()
			require("mason").setup({
				ui = {
					icons = {
						package_installed = "✓",
						package_pending = "➜",
						package_uninstalled = "✗",
					},
				},
			})
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = { "williamboman/mason.nvim" },
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = { "pyright", "ruff", "lua_ls" },
				automatic_installation = true,
			})
			-- we configure servers in lspconfig file; no extra handlers needed here
		end,
	},
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		dependencies = { "williamboman/mason.nvim" },
		config = function()
			require("mason-tool-installer").setup({
				ensure_installed = {
					"stylua", -- Lua formatter
					"jq", -- JSON formatter
				},
				auto_update = false,
				run_on_start = true,
			})
		end,
	},
}
