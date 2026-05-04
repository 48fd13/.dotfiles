return {
  {
    "https://github.com/mason-org/mason.nvim.git",
    config = function()
      require("mason").setup()
    end,
  },

  {
    "https://github.com/mason-org/mason-lspconfig.nvim.git",
    dependencies = {
      "https://github.com/mason-org/mason.nvim.git",
      "https://github.com/neovim/nvim-lspconfig.git",
    },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "pyright", "ruff" },
      })
    end,
  },

  {
    "https://github.com/neovim/nvim-lspconfig.git",
    dependencies = {
      "https://github.com/hrsh7th/cmp-nvim-lsp.git",
    },
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      vim.lsp.config("pyright", {
        capabilities = capabilities,
      })
      vim.lsp.enable("pyright")

      vim.lsp.config("ruff", {
        capabilities = capabilities,
      })
      vim.lsp.enable("ruff")
    end,
  },
}
