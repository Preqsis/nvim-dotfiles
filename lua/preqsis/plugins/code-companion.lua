return {
	{
		"olimorris/codecompanion.nvim",

		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
		},

		keys = {
			{
				"<leader>a",
				"<cmd>CodeCompanionChat Toggle<CR>",
				mode = "n",
				desc = "Toggle Jarvis chat",
			},
			{
				"<leader>h",
				"<cmd>CodeCompanionChat<CR>",
				mode = "n",
				desc = "New Jarvis chat",
			},
		},

		config = function()
			----------------------------------------------------------------
			-- UI
			----------------------------------------------------------------

			vim.api.nvim_set_hl(0, "CodeCompanionDarkGreen", {
				bg = "#0a0a1a",
				fg = "#ffffff",
			})

			----------------------------------------------------------------
			-- Paths
			----------------------------------------------------------------

			local rules_dir = vim.env.LLM_RULES_DIR or (vim.fn.stdpath("config") .. "/llm-rules")

			----------------------------------------------------------------
			-- Claude
			--
			-- Used only for HTTP interactions such as inline editing.
			----------------------------------------------------------------

			local claude_model = "claude-opus-4-6"

			----------------------------------------------------------------
			-- Helpers
			----------------------------------------------------------------

			local function read_file(path)
				local file, err = io.open(path, "r")

				if not file then
					vim.notify("Unable to open file: " .. path .. "\n" .. tostring(err), vim.log.levels.ERROR)

					return nil
				end

				local content = file:read("*a")
				file:close()

				return content
			end

			----------------------------------------------------------------
			-- CodeCompanion
			----------------------------------------------------------------

			require("codecompanion").setup({
				----------------------------------------------------------------
				-- Interactions
				----------------------------------------------------------------

				interactions = {
					------------------------------------------------------------
					-- Chat
					--
					-- Jarvis owns:
					--   - session state
					--   - tools
					--   - sandbox
					--   - model
					--   - persistence
					------------------------------------------------------------

					chat = {
						adapter = "jarvis",

						keymaps = {
							send = {
								modes = {
									n = "<leader>s",
									i = "<C-s>",
								},
							},
						},

						slash_commands = {
							["rules"] = {
								description = "Add LLM rules to the chat context",

								callback = function(chat)
									local scan = require("plenary.scandir")

									local files = scan.scan_dir(rules_dir, {
										depth = 1,
										search_pattern = "%.md$",
									})

									if #files == 0 then
										vim.notify("No rule files found in: " .. rules_dir, vim.log.levels.WARN)

										return
									end

									table.sort(files)

									vim.ui.select(files, {
										prompt = "Select a rule file",

										format_item = function(path)
											return vim.fn.fnamemodify(path, ":t:r")
										end,
									}, function(selected)
										if not selected then
											return
										end

										local content = read_file(selected)

										if not content then
											return
										end

										local name = vim.fn.fnamemodify(selected, ":t:r")

										chat:add_message({
											role = "user",
											content = content,
										}, {
											visible = false,
											reference = name .. ".md",
											source = "slash_command",
											tag = "rules",
										})

										vim.notify("Rules loaded: " .. name, vim.log.levels.INFO)
									end)
								end,
							},
						},
					},

					------------------------------------------------------------
					-- Inline editing
					--
					-- ACP agents are chat-only.
					-- Keep Claude/Anthropic HTTP here.
					------------------------------------------------------------

					inline = {
						adapter = {
							name = "anthropic",
							model = claude_model,
						},
					},

					------------------------------------------------------------
					-- Shared keymaps
					------------------------------------------------------------

					shared = {
						keymaps = {
							accept_change = {
								modes = {
									n = "ga",
								},
							},

							reject_change = {
								modes = {
									n = "gr",
								},
							},
						},
					},
				},

				----------------------------------------------------------------
				-- Adapters
				----------------------------------------------------------------

				adapters = {
					------------------------------------------------------------
					-- HTTP
					--
					-- Claude remains available for inline editing and can also
					-- still be selected manually in CodeCompanion if needed.
					------------------------------------------------------------

					http = {
						anthropic = function()
							return require("codecompanion.adapters").extend("anthropic", {
								env = {
									api_key = "ANTHROPIC_API_KEY",
								},

								schema = {
									model = {
										default = claude_model,
									},
								},
							})
						end,
					},

					------------------------------------------------------------
					-- ACP
					--
					-- CodeCompanion starts one Jarvis ACP process and creates
					-- sessions inside it.
					------------------------------------------------------------

					acp = {
						jarvis = function()
							local helpers = require("codecompanion.adapters.acp.helpers")

							return {
								name = "jarvis",
								formatted_name = "Jarvis",
								type = "acp",

								roles = {
									llm = "assistant",
									user = "user",
								},

								commands = {
									default = {
										"/home/preqsis/Projects/jarvis/master/.venv/bin/jarvis",
										"acp",
									},
								},

								defaults = {
									mcpServers = {},
									timeout = 60000,
								},

								parameters = {
									protocolVersion = 1,

									clientCapabilities = {
										fs = {
											readTextFile = true,
											writeTextFile = true,
										},
									},

									clientInfo = {
										name = "CodeCompanion.nvim",
										version = "1.0.0",
									},
								},

								handlers = {
									setup = function()
										return true
									end,

									auth = function()
										return true
									end,

									form_messages = function(self, messages, capabilities)
										return helpers.form_messages(self, messages, capabilities)
									end,

									on_exit = function() end,
								},
							}
						end,
					},
				},

				----------------------------------------------------------------
				-- Display
				----------------------------------------------------------------

				display = {
					chat = {
						show_settings = true,

						window = {
							layout = "vertical",
							position = "right",
							width = 0.5,
							border = "single",

							opts = {
								winhl = "Normal:CodeCompanionDarkGreen",
							},
						},
					},
				},
			})

			----------------------------------------------------------------
			-- Buffer-local settings
			----------------------------------------------------------------

			vim.api.nvim_create_autocmd("FileType", {
				pattern = "codecompanion",

				callback = function()
					vim.opt_local.number = false
					vim.opt_local.relativenumber = false
				end,
			})
		end,
	},
}
