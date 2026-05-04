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
      map("n", "<leader>gg", function()
        if vim.fn.executable("lazygit") ~= 1 then
          vim.notify("lazygit is not installed", vim.log.levels.WARN)
          return
        end

        local width = math.floor(vim.o.columns * 0.9)
        local height = math.floor(vim.o.lines * 0.9)
        local buf = vim.api.nvim_create_buf(false, true)
        local win = vim.api.nvim_open_win(buf, true, {
          relative = "editor",
          width = width,
          height = height,
          row = math.floor((vim.o.lines - height) / 2),
          col = math.floor((vim.o.columns - width) / 2),
          border = "rounded",
        })

        vim.fn.termopen("lazygit", {
          on_exit = function()
            if vim.api.nvim_win_is_valid(win) then
              vim.api.nvim_win_close(win, true)
            end
          end,
        })
        vim.cmd.startinsert()
      end, { desc = "LazyGit" })
    end,
  },
}
