return {
  {
    "https://github.com/nvim-treesitter/nvim-treesitter.git",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      local parsers = { "bash", "lua", "markdown", "markdown_inline", "python", "query", "vim", "vimdoc" }
      local compilers = { "cc", "gcc", "clang", "cl", "zig" }
      local has_compiler = vim.iter(compilers):any(function(compiler)
        return vim.fn.executable(compiler) == 1
      end)

      local treesitter = require("nvim-treesitter")
      treesitter.setup({})

      if has_compiler then
        treesitter.install(parsers)
      end

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
