local map = vim.keymap.set

return {
  {
    "https://github.com/stevearc/conform.nvim.git",
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          python = { "ruff_organize_imports", "ruff_format" },
          toml = { "taplo" },
        },
        format_on_save = {
          timeout_ms = 5000,
          lsp_format = "fallback",
        },
      })

      map("n", "<leader>fm", function()
        require("conform").format({ async = true, lsp_format = "fallback" })
      end, { desc = "Format" })
    end,
  },

  {
    "https://github.com/mfussenegger/nvim-lint.git",
    config = function()
      require("lint").linters_by_ft = {
        python = { "ruff" },
      }

      local lint = require("lint")
      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
        callback = function()
          lint.try_lint()
        end,
      })
    end,
  },
}
