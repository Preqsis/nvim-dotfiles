
return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    { "antosha417/nvim-lsp-file-operations", config = true },
  },
  config = function()
    local lspconfig = require("lspconfig")
    local cmp_nvim_lsp = require("cmp_nvim_lsp")

    -- capabilities (with offsetEncoding fix)
    local capabilities = cmp_nvim_lsp.default_capabilities()
    capabilities.offsetEncoding = { "utf-16" }

    -- diagnostic signs
    local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
    for type, icon in pairs(signs) do
      local hl = "DiagnosticSign" .. type
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
    end

    -- on_attach function
    local on_attach = function(_, bufnr)
      local opts = { buffer = bufnr, silent = true, noremap = true }
      local keymap = vim.keymap.set

      keymap("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts)
      keymap("n", "gD", vim.lsp.buf.declaration, opts)
      keymap("n", "gR", "<cmd>Telescope lsp_references<CR>", opts)
      keymap("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts)
      keymap("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts)
      keymap("n", "K", vim.lsp.buf.hover, opts)
      keymap("n", "<leader>rn", vim.lsp.buf.rename, opts)
      keymap({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
      keymap("n", "<leader>d", "<cmd>Telescope diagnostics bufnr=0<CR>", opts)
      keymap("n", "<leader>dl", vim.diagnostic.open_float, opts)
      keymap("n", "[d", vim.diagnostic.goto_prev, opts)
      keymap("n", "]d", vim.diagnostic.goto_next, opts)
    end

    -- pyright setup
    lspconfig.pyright.setup({
      capabilities = capabilities,
      on_attach = on_attach,
    })

    -- ruff-lsp setup (complement pyright)
    lspconfig.ruff.setup({
      capabilities = capabilities,
      on_attach = on_attach,
      init_options = {
        settings = {
          args = {}, -- optional: pass custom CLI args
        },
      },
    })

    -- lua_ls setup
    lspconfig.lua_ls.setup({
      capabilities = capabilities,
      on_attach = on_attach,
      settings = {
        Lua = {
          diagnostics = {
            globals = { "vim" },
          },
          workspace = {
            library = {
              [vim.fn.expand("$VIMRUNTIME/lua")] = true,
              [vim.fn.stdpath("config") .. "/lua"] = true,
            },
          },
        },
      },
    })
  end,
}

