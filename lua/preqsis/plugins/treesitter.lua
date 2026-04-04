return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false,
  priority = 10000,
  build = ":TSUpdate",
  dependencies = {
    {
      "nvim-treesitter/nvim-treesitter-textobjects",
      branch = "main",
    },
  },
  config = function()
    require("nvim-treesitter").setup({
      ensure_installed = {
        "python",
        "lua",
        "bash",
        "yaml",
        "toml",
        "json",
        "terraform",
        "markdown",
      },
      sync_install = false,
      auto_install = true,
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
      indent = {
        enable = true,
      },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-space>",
          node_incremental = "<C-space>",
          scope_incremental = false,
          node_decremental = "<bs>",
        },
      },
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ["as"] = { query = "@assignment.outer", desc = "Select outer part of an assignment." },
            ["is"] = { query = "@assignment.inner", desc = "Select inner part of an assignment." },
            ["ls"] = { query = "@assignment.lhs", desc = "Select left hand side of an assignment." },
            ["rs"] = { query = "@assignment.rhs", desc = "Select right hand side of an assignment." },
            ["ai"] = { query = "@conditional.outer", desc = "Select outer part of a conditional." },
            ["ii"] = { query = "@conditional.inner", desc = "Select inner part of a conditional." },
            ["al"] = { query = "@loop.outer", desc = "Select outer part of a loop." },
            ["il"] = { query = "@loop.inner", desc = "Select inner part of a loop." },
            ["ac"] = { query = "@call.outer", desc = "Select outer part of a function call." },
            ["ic"] = { query = "@call.inner", desc = "Select inner part of a function call." },
            ["af"] = { query = "@function.outer", desc = "Select outer part of a method/function definition." },
            ["if"] = { query = "@function.inner", desc = "Select inner part of a method/function definition." },
          },
        },
      },
    })

    vim.api.nvim_create_autocmd({ "FileType", "BufReadPost", "BufNewFile" }, {
      callback = function(args)
        pcall(vim.treesitter.start, args.buf)
      end,
    })
  end,
}
