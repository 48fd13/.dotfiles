return {
  {
    "https://github.com/nvim-treesitter/nvim-treesitter.git",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      local parsers = { "bash", "lua", "markdown", "markdown_inline", "python", "query", "vim", "vimdoc" }

      require("nvim-treesitter.configs").setup({
        ensure_installed = parsers,
        sync_install = false,
        auto_install = true,
        highlight = {
          enable = true,
        },
        indent = {
          enable = true,
        },
      })
    end,
  },
}
