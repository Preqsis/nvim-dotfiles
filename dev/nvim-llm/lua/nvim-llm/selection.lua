local M = {}

-- Gets the visually selected text as a string
function M.get_visual_selection()
  -- Save current register
  local original_reg = vim.fn.getreg('"')
  local original_mode = vim.fn.mode()

  -- Yank the selected text to the default register
  vim.cmd('normal! "vy')

  local selection = vim.fn.getreg('"')

  -- Restore original register and mode
  vim.fn.setreg('"', original_reg)
  if original_mode ~= "v" and original_mode ~= "V" then
    vim.cmd("normal! <Esc>")
  end

  return selection
end

-- Gets the current line under the cursor
function M.get_current_line()
  return vim.api.nvim_get_current_line()
end

return M
