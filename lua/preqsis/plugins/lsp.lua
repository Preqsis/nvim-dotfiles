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
					lsp_fallback = true,
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
			"hrsh7th/cmp-nvim-lsp",
			{ "antosha417/nvim-lsp-file-operations", config = true },
			-- telescope is used in the keymaps below
			{ "nvim-telescope/telescope.nvim", optional = true },
		},
		config = function()
			-- cmp capabilities (guarded)
			local ok_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			if ok_cmp then
				capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
			end

			-- diagnostic signs
			local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
			for type, icon in pairs(signs) do
				local hl = "DiagnosticSign" .. type
				vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
			end
			vim.diagnostic.config({
				virtual_text = { severity = { min = vim.diagnostic.severity.WARN } },
			})

			-- shared on_attach
			local on_attach = function(_, bufnr)
				local opts = { buffer = bufnr, silent = true, noremap = true }
				local keymap = vim.keymap.set

				if pcall(require, "telescope") then
					keymap("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts)
					keymap("n", "gr", "<cmd>Telescope lsp_references<CR>", opts)
					keymap("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts)  -- not working?
					keymap("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts)
					keymap("n", "<leader>d", "<cmd>Telescope diagnostics bufnr=0<CR>", opts)
				else
					keymap("n", "gd", vim.lsp.buf.definition, opts)
					keymap("n", "gr", vim.lsp.buf.references, opts)
					keymap("n", "gi", vim.lsp.buf.implementation, opts)
					keymap("n", "gt", vim.lsp.buf.type_definition, opts)
					keymap("n", "<leader>d", vim.diagnostic.setloclist, opts)
				end

				keymap({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
				keymap("n", "K", vim.lsp.buf.hover, opts)

				-- keymap("n", "gD", vim.lsp.buf.declaration, opts)  -- do I need this?
			end

			-- pyright (type checking)
			vim.lsp.config("pyright", {
				capabilities = capabilities,
				on_attach = on_attach,
				-- settings = { python = { analysis = { typeCheckingMode = "basic" } } },
			})

			-- ruff-lsp (linting/quickfixes) — formatting done via Conform (ruff)
			vim.lsp.config("ruff", {
				capabilities = capabilities,
				on_attach = on_attach,
				init_options = {
					settings = {
						args = {}, -- pass CLI args to ruff here if you want
					},
				},
			})

			-- lua_ls (Neovim dev UX)
			vim.lsp.config("lua_ls", {
				capabilities = capabilities,
				on_attach = on_attach,
				settings = {
					Lua = {
						diagnostics = { globals = { "vim" } },
						workspace = {
							library = vim.api.nvim_get_runtime_file("", true),
							checkThirdParty = false,
						},
						telemetry = { enable = false },
					},
				},
			})

			-- enable (auto-start for matching filetypes/root)
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
					"ruff", -- CLI for ruff_fix/ruff_format
					"stylua", -- Lua formatter
					"jq", -- JSON formatter
				},
				auto_update = false,
				run_on_start = true,
			})
		end,
	},
}
