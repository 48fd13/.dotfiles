local map = vim.keymap.set

return {
  {
    "https://github.com/nvim-neo-tree/neo-tree.nvim.git",
    branch = "v3.x",
    dependencies = {
      "https://github.com/nvim-lua/plenary.nvim.git",
      "https://github.com/MunifTanjim/nui.nvim.git",
      "https://github.com/nvim-tree/nvim-web-devicons.git",
    },
    config = function()
      require("neo-tree").setup({
        filesystem = {
          follow_current_file = {
            enabled = true,
          },
          use_libuv_file_watcher = true,
        },
      })

      map("n", "<leader>e", "<cmd>Neotree toggle reveal<cr>", { desc = "Explorer" })
      map("n", "<leader>E", "<cmd>Neotree reveal<cr>", { desc = "Reveal file" })
    end,
  },
}
