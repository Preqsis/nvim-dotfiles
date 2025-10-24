-- Remap the leader
vim.g.mapleader = ","
vim.g.maplocalleader = ","

local opts = {noremap=true, silent=true}
local map = vim.api.nvim_set_keymap

-- Cycle buffers by ctrl+n or cltr+p
map('n', '<C-n>', ':bnext<CR>', opts)
map('n', '<C-p>', ':bprevious<CR>', opts)

-- Quick save by ctrl+s
map('n', '<C-S>', ':update<CR>', opts)
map('v', '<C-S>', '<C-C>:update<CR>', opts)
map('i', '<C-S>', '<C-O>:update<CR>', opts)

-- Quick splits
map('n', '<leader>sv', ":vsplit<CR>", opts)
map('n', '<leader>sh', ":split<CR>", opts)

-- Quick window navigaion by ctrl+w
-- map('n', '<C-w>', '<C-w>w', opts)
map('n', '<C-h>', '<C-w>h', opts)
map('n', '<C-j>', '<C-w>j', opts)
map('n', '<C-k>', '<C-w>k', opts)
map('n', '<C-l>', '<C-w>l', opts)

-- Custom vertical movements
-- half page down / up + center page
map('n', '<C-d>', '<C-d>zz', opts)
map('n', '<C-u>', '<C-u>zz', opts)

-- Fold / Unfold by <Space>
map('n', '<Space>', 'zA', opts)

-- Motions
map('n', '<Up>', 'gk', opts)
map('n', '<Down>', 'gj', opts)
map('n', '<Home>', 'g<Home>', opts)
map('n', '<End>', 'g<End>', opts)
map('i', '<Up>', '<C-o>gk', opts)
map('i', '<Down>', '<C-o>gj', opts)
map('i', '<Home>', '<C-o>g<Home>', opts)
map('i', '<End>', '<C-o>g<End>', opts)

-- Czech chars are numbers for easier motions
-- for i, v in ipairs({'é', '+', 'ě', 'š', 'č', 'ř', 'ž', 'ý', 'á', 'í'}) do
--     map('n', v, tostring(i-1), opts)
--     map('v', v, tostring(i-1), opts)
-- end

-- Experimental
vim.keymap.set("x", "<leader>p", "\"_dP") -- paste and keep in clipboard

map("n", "<Leader>o", "o<Esc>k", opts)
map("n", "<Leader>O", "O<Esc>j", opts)

-- Resizing vim pane inside tmux session
vim.keymap.set("n", "ru", function() require("tmux").resize_top(5) end, opts)
vim.keymap.set("n", "rd", function() require("tmux").resize_bottom(5) end, opts)
vim.keymap.set("n", "rl", function() require("tmux").resize_left(5) end, opts)
vim.keymap.set("n", "rr", function() require("tmux").resize_right(5) end, opts)
