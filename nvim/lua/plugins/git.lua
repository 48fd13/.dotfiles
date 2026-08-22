local map = vim.keymap.set

return {
  {
    "https://github.com/lewis6991/gitsigns.nvim.git",
    config = function()
      require("gitsigns").setup({
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns
          local opts = { buffer = bufnr }

          map("n", "]g", function()
            if vim.wo.diff then
              return "]c"
            end
            vim.schedule(function()
              gs.nav_hunk("next")
            end)
            return "<Ignore>"
          end, vim.tbl_extend("force", opts, { expr = true, desc = "Next git hunk" }))

          map("n", "[g", function()
            if vim.wo.diff then
              return "[c"
            end
            vim.schedule(function()
              gs.nav_hunk("prev")
            end)
            return "<Ignore>"
          end, vim.tbl_extend("force", opts, { expr = true, desc = "Previous git hunk" }))

          map("n", "<leader>gp", gs.preview_hunk, vim.tbl_extend("force", opts, { desc = "Preview hunk" }))
          map("n", "<leader>gS", gs.stage_hunk, vim.tbl_extend("force", opts, { desc = "Stage hunk" }))
          map("n", "<leader>gr", gs.reset_hunk, vim.tbl_extend("force", opts, { desc = "Reset hunk" }))
          map("n", "<leader>gb", gs.blame_line, vim.tbl_extend("force", opts, { desc = "Blame line" }))
        end,
      })
    end,
  },

  {
    "https://github.com/sindrets/diffview.nvim.git",
    dependencies = { "https://github.com/nvim-lua/plenary.nvim.git" },
    config = function()
      require("diffview").setup()

      map("n", "<leader>gd", "<cmd>DiffviewOpen<cr>", { desc = "Open diff view" })
      map("n", "<leader>gD", "<cmd>DiffviewClose<cr>", { desc = "Close diff view" })
      map("n", "<leader>gh", "<cmd>DiffviewFileHistory<cr>", { desc = "File history" })
    end,
  },

  {
    "https://github.com/kdheepak/lazygit.nvim.git",
    dependencies = { "https://github.com/nvim-lua/plenary.nvim.git" },
    config = function()
      map("n", "<leader>gg", function()
        -- Walk up from the current buffer's directory to find the nearest .git
        local buf_path = vim.fn.expand("%:p:h")
        local git_root = vim.fn.systemlist("git -C " .. vim.fn.shellescape(buf_path) .. " rev-parse --show-toplevel")[1]
        if vim.v.shell_error == 0 and git_root and git_root ~= "" then
          require("lazygit").lazygit(git_root)
        else
          require("lazygit").lazygit()
        end
      end, { desc = "LazyGit" })
    end,
  },
}
