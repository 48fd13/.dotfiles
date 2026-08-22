return {
  {
    "https://github.com/nvim-treesitter/nvim-treesitter.git",
    branch = "master",
    build = ":TSUpdate",
    config = function()
      local parsers = { "bash", "lua", "markdown", "markdown_inline", "python", "query", "vim", "vimdoc" }
      local compilers = { "cc", "gcc", "clang", "cl", "zig" }
      local has_compiler = vim.iter(compilers):any(function(compiler)
        return vim.fn.executable(compiler) == 1
      end)

      require("nvim-treesitter.configs").setup({
        ensure_installed = has_compiler and parsers or {},
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
