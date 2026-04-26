return {
	"goolord/alpha-nvim",
	event = "VimEnter",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		-- If Neovim was started with a file/dir, skip the dashboard
		if vim.fn.argc() > 0 then
			return
		end

		local alpha = require("alpha")
		local startify = require("alpha.themes.startify")

        -- read file into a table of lines
        local function read_lines(path)
            local ok, data = pcall(vim.fn.readfile, path)
            return ok and data or { "ASCII header not found :(" }
        end

        -- point this to wherever you saved it
        local ascii = read_lines(vim.fn.stdpath("config") .. "/assets/avatar_2.txt")

        startify.section.header.val = ascii
		startify.nvim_web_devicons.enabled = true

		-- Handy buttons (Telescope assumed present; adjust as you like)
		startify.section.top_buttons.val = {
			startify.button("n", "  New file", ":ene | startinsert<CR>"),
			startify.button("r", "  Recent", ":Telescope oldfiles<CR>"),
			startify.button("p", "  File browser", ":Telescope file_browser<CR>"),
            -- startify.button("q", "󱄊  Quit", ":qa<CR>"),
		}

		alpha.setup(startify.config)

		-- Reopen dashboard later
		vim.keymap.set("n", "<leader>y", ":Alpha<CR>", { desc = "Open Alpha dashboard" })
	end,
}
