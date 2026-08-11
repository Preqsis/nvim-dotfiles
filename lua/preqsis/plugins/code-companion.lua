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
				desc = "Toggle Claude Code chat",
			},
			{
				"<leader>h",
				"<cmd>CodeCompanionChat<CR>",
				mode = "n",
				desc = "New Claude Code chat",
			},
		},
		config = function()
			-- Custom color scheme
			vim.api.nvim_set_hl(0, "CodeCompanionDarkGreen", {
				bg = "#0a0a1a",
				fg = "#ffffff",
			})

			local rules_dir = vim.env.LLM_RULES_DIR
				or (vim.fn.stdpath("config") .. "/llm-rules")

			local function read_file(path)
				local file, err = io.open(path, "r")

				if not file then
					vim.notify(
						"Unable to open file: " .. path .. "\n" .. tostring(err),
						vim.log.levels.ERROR
					)
					return nil
				end

				local content = file:read("*a")
				file:close()

				return content
			end

			----------------------------------------------------------------
			-- Previous HTTP/local-model configuration
			--
			-- Kept here so it can be restored later.
			----------------------------------------------------------------

			-- local models = {
			-- 	opus = "claude-opus-4-6",
			-- 	sonnet = "claude-sonnet-4-5",
			-- 	qwen_7b = "qwen2.5-coder-7b-instruct",
			-- 	qwen_14b = "qwen2.5-coder-14b-instruct",
			-- 	qwen3_30b = "qwen3-coder-30b-a3b-instruct",
			-- }
			--
			-- local active_model = models.opus
			-- local active_adapter = "anthropic"
			--
			-- Alternative local setup:
			--
			-- local active_model = models.qwen3_30b
			-- local active_adapter = "lmstudio"

			require("codecompanion").setup({
				interactions = {
					chat = {
						-- Claude Code through the Agent Client Protocol.
						adapter = "claude_code",

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
										vim.notify(
											"No rule files found in: " .. rules_dir,
											vim.log.levels.WARN
										)
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

										local name =
											vim.fn.fnamemodify(selected, ":t:r")

										chat:add_message({
											role = "user",
											content = content,
										}, {
											visible = false,
											reference = name .. ".md",
											source = "slash_command",
											tag = "rules",
										})

										vim.notify(
											"Rules loaded: " .. name,
											vim.log.levels.INFO
										)
									end)
								end,
							},
						},
					},

					----------------------------------------------------------------
					-- Claude Code ACP currently supports chat only.
					--
					-- Restore this block when you switch back to an HTTP adapter.
					----------------------------------------------------------------

					-- inline = {
					-- 	adapter = {
					-- 		name = active_adapter,
					-- 		model = active_model,
					-- 	},
					-- },
					--
					-- shared = {
					-- 	keymaps = {
					-- 		accept_change = {
					-- 			modes = { n = "ga" },
					-- 		},
					-- 		reject_change = {
					-- 			modes = { n = "gr" },
					-- 		},
					-- 	},
					-- },
				},

				adapters = {
					acp = {
						claude_code = function()
							return require("codecompanion.adapters").extend(
								"claude_code",
								{
									-- Explicitly provide the same AWS Bedrock
									-- environment used by Claude Code.
									env = {
										CLAUDE_CODE_USE_BEDROCK = "1",
										AWS_PROFILE = "dev_claude_code",
										AWS_REGION = "us-east-1",
									},

									-- Claude Code will otherwise use its normal
									-- ~/.claude configuration, including the
									-- awsAuthRefresh command.
									defaults = {
										timeout = 120000,
									},
								}
							)
						end,
					},

					----------------------------------------------------------------
					-- Previous HTTP adapters
					--
					-- Uncomment these together with `models`, `active_model`,
					-- `active_adapter`, and the inline interaction above.
					----------------------------------------------------------------

					-- http = {
					-- 	anthropic = function()
					-- 		return require("codecompanion.adapters").extend(
					-- 			"anthropic",
					-- 			{
					-- 				env = {
					-- 					api_key = "ANTHROPIC_API_KEY",
					-- 				},
					-- 				schema = {
					-- 					model = {
					-- 						default = models.opus,
					-- 					},
					-- 				},
					-- 			}
					-- 		)
					-- 	end,
					--
					-- 	lmstudio = function()
					-- 		return require("codecompanion.adapters").extend(
					-- 			"openai_compatible",
					-- 			{
					-- 				env = {
					-- 					url = "http://localhost:1234",
					-- 					api_key = "lm-studio",
					-- 					chat_url = "/v1/chat/completions",
					-- 				},
					-- 				schema = {
					-- 					model = {
					-- 						default = models.qwen3_30b,
					-- 					},
					-- 				},
					-- 			}
					-- 		)
					-- 	end,
					-- },
				},

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

			-- Buffer-local settings
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
