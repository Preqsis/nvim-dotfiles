return {
	{
		"olimorris/codecompanion.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
		},
		keys = {
			{ "<leader>a", "<cmd>CodeCompanionChat Toggle<CR>", mode = "n", desc = "Toggle CodeCompanion chat" },
			{ "<leader>h", "<cmd>CodeCompanionChat<CR>", mode = "n", desc = "New CodeCompanion chat" },
		},
		config = function()
			-- Custom color scheme
			vim.api.nvim_set_hl(0, "CodeCompanionDarkGreen", {
				bg = "#0a0a1a",
				fg = "#ffffff",
			})

			local rules_dir = vim.env.LLM_RULES_DIR or (vim.fn.stdpath("config") .. "/llm-rules")

			local function read_file(path)
				local f = io.open(path, "r")
				if not f then
					return nil
				end
				local content = f:read("*a")
				f:close()
				return content
			end

			-- Model aliases for easier handling
			local models = {
				opus = "claude-opus-4-6",
				sonnet = "claude-sonnet-4-5",
				qwen = "qwen2.5-coder-7b-instruct",
			}

			-- Currently active model
			local active_model = models.opus
			local active_adapter = "anthropic"

			local strategies = {
				chat = {
					adapter = {
						name = active_adapter,
						model = active_model,
					},
					keymaps = {
						send = { modes = { n = "<leader>s" } },
					},
					slash_commands = {
						["rules"] = {
							description = "Add LLM rules to the chat context",
							callback = function(chat)
								local scan = require("plenary.scandir")
								local files = scan.scan_dir(rules_dir, { depth = 1, search_pattern = "%.md$" })

								if #files == 0 then
									vim.notify("No rule files found in: " .. rules_dir, vim.log.levels.WARN)
									return
								end

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
										vim.notify("Failed to read: " .. selected, vim.log.levels.ERROR)
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
				inline = {
					adapter = {
						name = active_adapter,
						model = active_model,
					},
					keymaps = {
						accept_change = { modes = { n = "ga" } },
						reject_change = { modes = { n = "gr" } },
					},
				},
			}

			require("codecompanion").setup({
				strategies = strategies,
				adapters = {
					http = {
						anthropic = function()
							return require("codecompanion.adapters").extend("anthropic", {
								env = {
									api_key = "ANTHROPIC_API_KEY",
								},
								schema = {
									model = {
										default = "claude-opus-4-6",
									},
								},
							})
						end,
						lmstudio = function()
							return require("codecompanion.adapters").extend("openai_compatible", {
								env = {
									url = "http://localhost:1234",
									api_key = "lm-studio",
									chat_url = "/v1/chat/completions",
								},
								schema = {
									model = {
										default = "qwen2.5-coder-7b-instruct",
									},
								},
							})
						end,
					},
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

-- return {
--     {
--         "olimorris/codecompanion.nvim",
--         dependencies = {
--             "nvim-lua/plenary.nvim",
--             "nvim-treesitter/nvim-treesitter",
--         },
--         config = function()
--             vim.api.nvim_set_hl(0, "CodeCompanionDarkGreen", {
--                 bg = "#0a0a1a",
--                 fg = "#ffffff",
--             })
--
--             local rules_dir = vim.env.LLM_RULES_DIR or (vim.fn.stdpath("config") .. "/llm-rules")
--
--             local function read_file(path)
--                 local f = io.open(path, "r")
--                 if not f then
--                     return nil
--                 end
--                 local content = f:read("*a")
--                 f:close()
--                 return content
--             end
--
--             require("codecompanion").setup({
--                 opts = {
--                     log_level = "DEBUG",
--                 },
--
--                 strategies = {
--                     -- Keep chat smart, but default to Sonnet for edit reliability
--                     chat = {
--                         adapter = {
--                             name = "anthropic",
--                             model = "claude-sonnet-4-5",
--                         },
--                         keymaps = {
--                             send = { modes = { n = "<leader>s" } },
--                         },
--                         slash_commands = {
--                             ["rules"] = {
--                                 description = "Add LLM rules to the chat context",
--                                 callback = function(chat)
--                                     local scan = require("plenary.scandir")
--                                     local files = scan.scan_dir(rules_dir, { depth = 1, search_pattern = "%.md$" })
--
--                                     if #files == 0 then
--                                         vim.notify("No rule files found in: " .. rules_dir, vim.log.levels.WARN)
--                                         return
--                                     end
--
--                                     vim.ui.select(files, {
--                                         prompt = "Select a rule file",
--                                         format_item = function(path)
--                                             return vim.fn.fnamemodify(path, ":t:r")
--                                         end,
--                                     }, function(selected)
--                                         if not selected then
--                                             return
--                                         end
--
--                                         local content = read_file(selected)
--                                         if not content then
--                                             vim.notify("Failed to read: " .. selected, vim.log.levels.ERROR)
--                                             return
--                                         end
--
--                                         local name = vim.fn.fnamemodify(selected, ":t:r")
--
--                                         chat:add_message({
--                                             role = "user",
--                                             content = content,
--                                         }, {
--                                             visible = false,
--                                             reference = name .. ".md",
--                                             source = "slash_command",
--                                             tag = "rules",
--                                         })
--
--                                         vim.notify("Rules loaded: " .. name, vim.log.levels.INFO)
--                                     end)
--                                 end,
--                             },
--                         },
--                     },
--
--                     -- Inline edits should definitely use Sonnet
--                     inline = {
--                         adapter = {
--                             name = "anthropic",
--                             model = "claude-sonnet-4-5",
--                         },
--                         keymaps = {
--                             accept_change = { modes = { n = "ga" } },
--                             reject_change = { modes = { n = "gr" } },
--                         },
--                     },
--                 },
--
--                 tools = {
--                     opts = {
--                         auto_submit_errors = true,
--                         auto_submit_success = true,
--                         notify_on_approval = true,
--                     },
--                     default_tools = {
--                         "agent",
--                     },
--                 },
--
--                 adapters = {
--                     http = {
--                         anthropic = function()
--                             local adapter = require("codecompanion.adapters").extend("anthropic", {
--                                 env = {
--                                     api_key = "ANTHROPIC_API_KEY",
--                                 },
--                             })
--
--                             adapter.schema.model = vim.tbl_deep_extend("force", adapter.schema.model, {
--                                 default = "claude-sonnet-4-5",
--                                 choices = {
--                                     ["claude-opus-4-6"] = {
--                                         formatted_name = "Claude Opus 4.6",
--                                         opts = { can_reason = true, has_vision = true },
--                                     },
--                                     ["claude-sonnet-4-5"] = {
--                                         formatted_name = "Claude Sonnet 4.5",
--                                         opts = { can_reason = true, has_vision = true },
--                                     },
--                                 },
--                             })
--
--                             return adapter
--                         end,
--
--                         -- dont remove this block under any cirucmstances
--                         ollama = function()
--                             vim.env.OLLAMA_HOST = "http://192.168.0.2:11434"
--
--                             local adapter = require("codecompanion.adapters").extend("ollama", {
--                                 env = {
--                                     url = "http://192.168.0.2:11434",
--                                 },
--                                 schema = {
--                                     model = { default = "llama3-groq-tool-use:8b" },
--                                     num_ctx = { default = 8192 },
--                                     temperature = { default = 0.05 },
--                                 },
--                                 parameters = { sync = true },
--                             })
--
--                             adapter.schema.model.choices = function()
--                                 local ok, result = pcall(function()
--                                     return require("plenary.curl").get(
--                                         "http://192.168.0.2:11434/api/tags",
--                                         { timeout = 5000 }
--                                     )
--                                 end)
--
--                                 local choices = {}
--                                 if ok and result and result.body then
--                                     local data = vim.json.decode(result.body)
--                                     for _, m in ipairs(data.models or {}) do
--                                         choices[m.name] = { formatted_name = m.name }
--                                     end
--                                 end
--
--                                 if next(choices) == nil then
--                                     choices["llama3-groq-tool-use:8b"] = { formatted_name = "llama3-groq-tool-use:8b" }
--                                 end
--
--                                 return choices
--                             end
--
--                             return adapter
--                         end,
--                     },
--                 },
--
--                 display = {
--                     chat = {
--                         show_settings = true,
--                         window = {
--                             layout = "vertical",
--                             position = "right",
--                             width = 0.5,
--                             height = 1.0,
--                             border = "single",
--                             opts = {
--                                 winhl = "Normal:CodeCompanionDarkGreen,NormalFloat:CodeCompanionDarkGreen",
--                             },
--                         },
--                     },
--                 },
--             })
--
--             local function set_cc_adapter(adapter_value)
--                 local cfg = require("codecompanion.config")
--
--                 if cfg.interactions then
--                     if cfg.interactions.chat then
--                         cfg.interactions.chat.adapter = adapter_value
--                     end
--                     if cfg.interactions.inline then
--                         cfg.interactions.inline.adapter = adapter_value
--                     end
--                 end
--
--                 if cfg.strategies then
--                     if cfg.strategies.chat then
--                         cfg.strategies.chat.adapter = adapter_value
--                     end
--                     if cfg.strategies.inline then
--                         cfg.strategies.inline.adapter = adapter_value
--                     end
--                 end
--             end
--
--             vim.api.nvim_create_user_command("CodeCompanionModels", function()
--                 local models = {
--                     { name = "Claude Sonnet 4.5", model = "claude-sonnet-4-5", adapter = "anthropic" },
--                     { name = "Claude Opus 4.6", model = "claude-opus-4-6", adapter = "anthropic" },
--                     { name = "Llama 3 Groq Tool Use 8B", model = "llama3-groq-tool-use:8b", adapter = "ollama" },
--                 }
--
--                 local pickers = require("telescope.pickers")
--                 local finders = require("telescope.finders")
--                 local conf = require("telescope.config").values
--                 local actions = require("telescope.actions")
--                 local action_state = require("telescope.actions.state")
--
--                 pickers
--                     .new({}, {
--                         prompt_title = "CodeCompanion Models",
--                         finder = finders.new_table({
--                             results = models,
--                             entry_maker = function(entry)
--                                 local display = entry.name .. " (" .. entry.model .. ")"
--                                 return {
--                                     value = entry,
--                                     display = display,
--                                     ordinal = entry.name .. " " .. entry.model,
--                                 }
--                             end,
--                         }),
--                         sorter = conf.generic_sorter({}),
--                         attach_mappings = function(prompt_bufnr)
--                             actions.select_default:replace(function()
--                                 actions.close(prompt_bufnr)
--                                 local selection = action_state.get_selected_entry()
--                                 if selection then
--                                     local model = selection.value.model
--                                     local adapter = selection.value.adapter
--
--                                     set_cc_adapter({
--                                         name = adapter,
--                                         model = model,
--                                     })
--
--                                     vim.notify(
--                                         "CodeCompanion model set to: " .. selection.value.name,
--                                         vim.log.levels.INFO
--                                     )
--                                 end
--                             end)
--                             return true
--                         end,
--                     })
--                     :find()
--             end, {})
--
--             vim.api.nvim_create_autocmd("FileType", {
--                 pattern = "codecompanion",
--                 callback = function()
--                     vim.opt_local.winhl = "Normal:CodeCompanionDarkGreen,NormalFloat:CodeCompanionDarkGreen"
--                     vim.opt_local.number = false
--                     vim.opt_local.relativenumber = false
--                     vim.opt_local.signcolumn = "yes:1"
--                     vim.opt_local.foldcolumn = "1"
--                     vim.opt_local.sidescrolloff = 3
--                     vim.opt_local.scrolloff = 3
--                 end,
--             })
--         end,
--     },
-- }
