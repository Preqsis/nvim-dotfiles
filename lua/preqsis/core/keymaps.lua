-- Remap the leader
vim.g.mapleader = ","
vim.g.maplocalleader = ","

local opts = { noremap = true, silent = true }
local map = vim.keymap.set

-- Cycle buffers by ctrl+n or cltr+p
map("n", "<C-n>", "<cmd>bnext<CR>", opts)
map("n", "<C-p>", "<cmd>bprevious<CR>", opts)

-- Quick save by ctrl+s
map("n", "<C-S>", "<cmd>update<CR>", opts)
map("v", "<C-S>", "<cmd>update<CR>", opts)
map("i", "<C-S>", "<cmd>update<CR>", opts)

-- Quick splits
map("n", "<leader>sv", "<cmd>vsplit<CR>", opts)
map("n", "<leader>sh", "<cmd>split<CR>", opts)

-- Quick window navigaion by ctrl+w
-- map('n', '<C-w>', '<C-w>w', opts)
map("n", "<C-h>", "<C-w>h", opts)
map("n", "<C-j>", "<C-w>j", opts)
map("n", "<C-k>", "<C-w>k", opts)
map("n", "<C-l>", "<C-w>l", opts)

-- Custom vertical movements
-- half page down / up + center page
map("n", "<C-d>", "<C-d>zz", opts)
map("n", "<C-u>", "<C-u>zz", opts)

-- Fold / Unfold by <Space>
map("n", "<Space>", "zA", opts)

-- Motions
map("n", "<Up>", "gk", opts)
map("n", "<Down>", "gj", opts)
map("n", "<Home>", "g<Home>", opts)
map("n", "<End>", "g<End>", opts)
map("i", "<Up>", "<C-o>gk", opts)
map("i", "<Down>", "<C-o>gj", opts)
map("i", "<Home>", "<C-o>g<Home>", opts)
map("i", "<End>", "<C-o>g<End>", opts)

-- Experimental
vim.keymap.set("x", "<leader>p", '"_dP') -- paste and keep in clipboard

map("n", "<Leader>o", "o<Esc>k", opts)
map("n", "<Leader>O", "O<Esc>j", opts)

-- Resizing vim pane inside tmux session
vim.keymap.set("n", "ru", function()
	require("tmux").resize_top(5)
end, opts)
vim.keymap.set("n", "rd", function()
	require("tmux").resize_bottom(5)
end, opts)
vim.keymap.set("n", "rl", function()
	require("tmux").resize_left(5)
end, opts)
vim.keymap.set("n", "rr", function()
	require("tmux").resize_right(5)
end, opts)

-- Execute current line as shell command and insert output below
-- Only inserts into buffer on success with output, otherwise shows notifications:
-- - Success with output: inserts command output on following lines
-- - Success without output: shows notification only
-- - Error: shows notification with exit code and error details
-- - Empty line: shows warning notification
local function execute_line_as_command()
	-- Get the current line
	local line = vim.api.nvim_get_current_line()

	-- Skip if line is empty or only whitespace
	if line:match("^%s*$") then
		vim.notify("No command to execute (empty line)", vim.log.levels.WARN)
		return
	end

	-- Execute the command
	local output = vim.fn.system(line)
	local exit_code = vim.v.shell_error

	-- Check if command failed
	if exit_code ~= 0 then
		local error_msg = "Command failed with exit code: " .. exit_code
		if output and output ~= "" then
			-- Add error output to notification
			output = output:gsub("\n$", "")
			error_msg = error_msg .. "\nError output: " .. output:gsub("\n", " | ")
		end
		vim.notify(error_msg, vim.log.levels.ERROR)
		return
	end

	-- Command succeeded
	if output and output ~= "" then
		-- Remove trailing newline if present
		output = output:gsub("\n$", "")
		-- Split output into lines, filtering out empty ones
		local lines = {}
		for s in output:gmatch("[^\n]+") do
			table.insert(lines, s)
		end
		-- Insert the output starting from the next line
		local row = vim.api.nvim_win_get_cursor(0)[1] -- current row (1-indexed)
		vim.api.nvim_buf_set_lines(0, row, row, false, lines)
	else
		-- Success but no output - just notify
		vim.notify("Command executed successfully (no output)", vim.log.levels.INFO)
	end
end

vim.keymap.set("n", "Q", execute_line_as_command, opts)
