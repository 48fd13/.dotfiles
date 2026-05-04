return {
  {
    "https://github.com/nvim-treesitter/nvim-treesitter.git",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").setup({
        install_dir = vim.fn.stdpath("data") .. "/site",
      })
      require("nvim-treesitter").install({ "bash", "lua", "markdown", "markdown_inline", "python", "query", "vim", "vimdoc" })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "python" },
        callback = function()
          pcall(vim.treesitter.start)
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })
    end,
  },
}
