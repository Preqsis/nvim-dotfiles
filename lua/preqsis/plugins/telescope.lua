

return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope-file-browser.nvim",
    "nvim-telescope/telescope-ui-select.nvim",
    "nvim-telescope/telescope-live-grep-args.nvim", -- ← new
  },
  config = function()
    local ok_telescope, telescope = pcall(require, "telescope")
    if not ok_telescope then
      vim.notify("telescope.nvim not found", vim.log.levels.WARN)
      return
    end
    local ok_actions, actions = pcall(require, "telescope.actions")
    if not ok_actions then
      vim.notify("telescope.actions not found", vim.log.levels.WARN)
      return
    end
    local builtin = require("telescope.builtin")
    local themes = require("telescope.themes")

    -- detect project root (git), fallback to cwd
    local function project_root()
      local git = vim.fn.systemlist("git -C " .. vim.fn.expand("%:p:h") .. " rev-parse --show-toplevel")[1]
      if git and vim.v.shell_error == 0 and git ~= "" then
        return git
      end
      return vim.loop.cwd()
    end

    telescope.setup({
      defaults = {
        prompt_prefix = "   ",
        selection_caret = "󰈺 ",
        path_display = { "truncate" },
        results_title = false,
        sorting_strategy = "ascending",
        layout_config = {
          prompt_position = "top",
          width = 0.95,
          height = 0.85,
          preview_cutoff = 80,
        },
        vimgrep_arguments = {
          "rg",
          "--color=never",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column",
          "--smart-case",
          "--hidden",
          "--glob=!.git/*",
        },
        file_ignore_patterns = {
          "%.git/", "__pycache__/", "%.pyc$", "%.pyo$",
          "%.venv/", "^venv/", "^.venv/", "^env/",
          "site%-packages/", "node_modules/", "dist/", "build/",
        },
        mappings = {
          i = {
            ["<C-j>"] = actions.move_selection_next,
            ["<C-k>"] = actions.move_selection_previous,
            ["<C-u>"] = false,
            ["<C-d>"] = false,
          },
        },
        preview = { timeout = 200 },
        dynamic_preview_title = true,
      },
      pickers = {
        find_files = {
          hidden = true,
          follow = true,
          find_command = { "rg", "--files", "--hidden", "--glob", "!.git/*" },
        },
        buffers = { sort_mru = true, ignore_current_buffer = true },
        diagnostics = { severity = nil },
      },
      extensions = {
        file_browser = {
          hijack_netrw = true,
          respect_gitignore = true,
          hidden = true,
          grouped = true,
        },
        ["ui-select"] = themes.get_dropdown({
          previewer = false,
          initial_mode = "insert",
          sorting_strategy = "ascending",
        }),
        -- live grep with inline args like: foo -g src/** -g tests/**
        live_grep_args = {
          auto_quoting = true, -- easier quoting of args
        },
      },
    })

    telescope.load_extension("file_browser")
    telescope.load_extension("ui-select")
    telescope.load_extension("live_grep_args")

    -- Keymaps (project-rooted find/grep; plus some handy extras)
    local map = vim.keymap.set
    map("n", "<leader>ff", function()
      builtin.find_files({ cwd = project_root() })
    end, { desc = "Find files (root)" })

    -- Grep with args, rooted to project by default
    map("n", "<leader>fg", function()
      require("telescope").extensions.live_grep_args.live_grep_args({
        cwd = project_root(),
      })
    end, { desc = "Live grep (root, with args)" })

    map("n", "<leader>fr", builtin.oldfiles, { desc = "Recent files" })
    map("n", "<leader>fd", builtin.diagnostics, { desc = "Diagnostics (workspace)" })
    map("n", "<leader>fs", builtin.lsp_document_symbols, { desc = "LSP document symbols" })
    map("n", "<leader>fb", "<cmd>Telescope file_browser path=%:p:h select_buffer=true<CR>", { desc = "File browser" })

    -- Git
    map("n", "<leader>fm", builtin.git_commits, { desc = "Git commits" })
    map("n", "<leader>fc", builtin.git_status, { desc = "Git status" })
  end,
}

