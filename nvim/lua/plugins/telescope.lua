local map = vim.keymap.set

return {
  {
    "https://github.com/nvim-telescope/telescope.nvim.git",
    dependencies = { "https://github.com/nvim-lua/plenary.nvim.git" },
    config = function()
      local actions = require("telescope.actions")
      local builtin = require("telescope.builtin")
      local ignored_dirs = {
        "%.git/",
        "%.obsidian",
        "node_modules/",
        "%.cache/",
        "dist/",
        "build/",
      }

      require("telescope").setup({
        defaults = {
          file_ignore_patterns = ignored_dirs,
          vimgrep_arguments = {
            "rg",
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case",
            "--hidden",
            "--glob=!**/.git/**",
            "--glob=!**/node_modules/**",
            "--glob=!**/.cache/**",
            "--glob=!**/dist/**",
            "--glob=!**/build/**",
          },
          preview = {
            treesitter = false,
          },
          mappings = {
            i = {
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
            },
          },
        },
        pickers = {
          find_files = {
            hidden = true,
            no_ignore = false,
          },
        },
      })

      map("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
      map("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })
      map("n", "<leader>fb", builtin.buffers, { desc = "Find buffers" })
      map("n", "<leader>fr", builtin.oldfiles, { desc = "Recent files" })
      map("n", "<leader>bb", builtin.buffers, { desc = "Buffers" })
      map("n", "<leader>gc", builtin.git_commits, { desc = "Git commits" })
      map("n", "<leader>gf", builtin.git_files, { desc = "Git files" })
      map("n", "<leader>gs", builtin.git_status, { desc = "Git status" })
    end,
  },
}
