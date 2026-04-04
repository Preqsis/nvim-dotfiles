return {
  {
    name = "pdf2md-local",
    dir = vim.fn.stdpath("config"), -- ~/.config/nvim-lab
    cmd = { "Pdf2Markdown" },
    config = function()
      local function convert(pdf_path)
        if not pdf_path or pdf_path == "" then
          vim.notify("Pdf2Markdown: No path provided", vim.log.levels.ERROR)
          return
        end

        if vim.fn.filereadable(pdf_path) == 0 then
          vim.notify("Pdf2Markdown: File not found: " .. pdf_path, vim.log.levels.ERROR)
          return
        end

        local py = table.concat({
          "import sys",
          "import pymupdf4llm",
          "path = sys.argv[1]",
          "print(pymupdf4llm.to_markdown(path))",
        }, "\n")

        local cmd = { "python3", "-c", py, pdf_path }

        vim.notify("Pdf2Markdown: Converting...", vim.log.levels.INFO)

        vim.fn.jobstart(cmd, {
          stdout_buffered = true,
          on_stdout = function(_, data)
            if not data or #data == 0 then return end
            vim.schedule(function()
              vim.cmd("enew")
              vim.bo.bufhidden = "wipe"
              vim.bo.swapfile = false
              vim.bo.filetype = "markdown"
              vim.api.nvim_buf_set_lines(0, 0, -1, false, data)
              vim.notify("Pdf2Markdown: Done", vim.log.levels.INFO)
            end)
          end,
          on_stderr = function(_, data)
            if not data or #data == 0 then return end
            local msg = table.concat(vim.tbl_filter(function(s) return s ~= "" end, data), "\n")
            if msg ~= "" then
              vim.schedule(function()
                vim.notify("Pdf2Markdown error:\n" .. msg, vim.log.levels.ERROR)
              end)
            end
          end,
        })
      end

      vim.api.nvim_create_user_command("Pdf2Markdown", function(opts)
        convert(opts.args)
      end, { nargs = 1, complete = "file" })
    end,
  },
}
