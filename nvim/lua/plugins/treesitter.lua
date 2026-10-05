return {
  {
    "https://github.com/nvim-treesitter/nvim-treesitter.git",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      local parsers = { "bash", "lua", "markdown", "markdown_inline", "python", "query", "vim", "vimdoc" }

      local treesitter = require("nvim-treesitter")
      treesitter.setup({})
      treesitter.install(parsers)

      vim.api.nvim_create_autocmd("FileType", {
        callback = function()
          if pcall(vim.treesitter.start) then
            vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },
}
