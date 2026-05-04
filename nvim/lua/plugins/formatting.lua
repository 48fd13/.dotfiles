local map = vim.keymap.set

return {
  {
    "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim.git",
    dependencies = { "https://github.com/mason-org/mason.nvim.git" },
    config = function()
      require("mason-tool-installer").setup({
        ensure_installed = { "black", "isort", "pyright", "ruff" },
      })
    end,
  },

  {
    "https://github.com/stevearc/conform.nvim.git",
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          python = { "isort", "black" },
        },
        format_on_save = function(bufnr)
          if vim.bo[bufnr].filetype == "python" then
            return { lsp_fallback = true, timeout_ms = 3000 }
          end
        end,
      })

      map("n", "<leader>fm", function()
        require("conform").format({ async = true, lsp_fallback = true })
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
