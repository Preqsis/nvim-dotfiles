local M = {}

function M.info(msg)
  vim.notify("[nvim-llm] " .. msg, vim.log.levels.INFO)
end

function M.error(msg)
  vim.notify("[nvim-llm] " .. msg, vim.log.levels.ERROR)
end

function M.dump_table(tbl)
  return vim.inspect(tbl)
end

return M
