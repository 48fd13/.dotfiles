local map = vim.keymap.set

return {
  {
    "https://github.com/ibhagwan/fzf-lua.git",
    dependencies = { "https://github.com/nvim-tree/nvim-web-devicons.git" },
    config = function()
      local fzf = require("fzf-lua")

      fzf.setup({
        keymap = {
          fzf = {
            ["ctrl-j"] = "down",
            ["ctrl-k"] = "up",
          },
        },
        files = {
          fd_opts = table.concat({
            "--color=never",
            "--type f",
            "--hidden",
            "--follow",
            "--exclude .git",
            "--exclude .obsidian",
            "--exclude node_modules",
            "--exclude .cache",
            "--exclude dist",
            "--exclude build",
          }, " "),
        },
        grep = {
          rg_opts = table.concat({
            "--column",
            "--line-number",
            "--no-heading",
            "--color=always",
            "--smart-case",
            "--hidden",
            "--glob=!**/.git/**",
            "--glob=!**/.obsidian/**",
            "--glob=!**/node_modules/**",
            "--glob=!**/.cache/**",
            "--glob=!**/dist/**",
            "--glob=!**/build/**",
            "-e",
          }, " "),
        },
      })

      map("n", "<leader>ff", fzf.files, { desc = "Find files" })
      map("n", "<leader>fg", fzf.live_grep, { desc = "Live grep" })
      map("n", "<leader>fb", fzf.buffers, { desc = "Find buffers" })
      map("n", "<leader>fr", fzf.oldfiles, { desc = "Recent files" })
      map("n", "<leader>bb", fzf.buffers, { desc = "Buffers" })
      map("n", "<leader>gc", fzf.git_commits, { desc = "Git commits" })
      map("n", "<leader>gf", fzf.git_files, { desc = "Git files" })
      map("n", "<leader>gs", fzf.git_status, { desc = "Git status" })
    end,
  },
}
