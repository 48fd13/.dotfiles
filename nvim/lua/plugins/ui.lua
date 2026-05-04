return {
  {
    "https://github.com/folke/which-key.nvim.git",
    event = "VeryLazy",
    opts = {
      preset = "modern",
      spec = {
        { "<leader>b", group = "buffers" },
        { "<leader>c", group = "code/lsp" },
        { "<leader>e", desc = "Explorer" },
        { "<leader>f", group = "files/search" },
        { "<leader>g", group = "git" },
        { "<leader>o", group = "opencode" },
        { "<leader>w", group = "windows" },
      },
    },
  },
}
