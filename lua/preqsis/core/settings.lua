-- Use system clipboard
vim.o.clipboard = "unnamedplus"

-- Show line numbers
vim.wo.number = true
vim.wo.relativenumber = true

-- Enable cursor Line
-- highlight numbers only
vim.opt.cursorline = true
vim.opt.cursorlineopt = "both"

-- Real programmers don't use TABs but spaces!!!
vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.shiftwidth = 4
vim.o.shiftround = true
vim.o.expandtab = true

-- Enable cursor move by mouse
vim.o.mouse = "a"

-- Jump line with left or right move
vim.o.whichwrap = vim.o.whichwrap .. "<,>,h,l,[,]"

-- Disable backup and swap files
vim.o.backup = false
vim.o.writebackup = false
vim.o.swapfile = false

-- Line wrapping
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.list = false
vim.opt.virtualedit = ""
vim.opt.display:append("lastline")

-- Broader gitconfig filetype detenction
vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
  pattern = "*gitconfig*",
  callback = function()
    vim.bo.filetype = "gitconfig"
  end,
})

