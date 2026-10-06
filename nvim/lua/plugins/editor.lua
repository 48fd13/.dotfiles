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
          window = {
            width = 30,
            mappings = {
              ["P"] = { "toggle_preview", config = { use_float = true } },
              ["<"] = function(state)
                local win = state.winid
                vim.api.nvim_win_set_width(win, vim.api.nvim_win_get_width(win) - 5)
              end,
              [">"] = function(state)
                local win = state.winid
                vim.api.nvim_win_set_width(win, vim.api.nvim_win_get_width(win) + 5)
              end,
            },
          },
        },
        default_component_configs = {
          indent = {
            with_expanders = true,
            expander_collapsed = "+",
            expander_expanded = "-",
          },
          git_status = {
            symbols = {
              added = "A", modified = "M", deleted = "D", renamed = "R",
              untracked = "?", ignored = "!", unstaged = "U", staged = "S", conflict = "C",
            },
          },
          diagnostics = {
            symbols = { error = "E", warn = "W", info = "I", hint = "H" },
          },
          modified = { symbol = "[+]" },
        },
        renderers = {
          directory = {
            { "indent" },
            { "current_filter" },
            {
              "container",
              content = {
                { "name", zindex = 10 },
                { "symlink_target", zindex = 10, highlight = "NeoTreeSymbolicLinkTarget" },
                { "clipboard", zindex = 10 },
                { "diagnostics", errors_only = true, zindex = 20, align = "right", hide_when_expanded = true },
                { "git_status", zindex = 10, align = "right", hide_when_expanded = true },
              },
            },
          },
          file = {
            { "indent" },
            {
              "container",
              content = {
                { "name", zindex = 10 },
                { "symlink_target", zindex = 10, highlight = "NeoTreeSymbolicLinkTarget" },
                { "clipboard", zindex = 10 },
                { "bufnr", zindex = 10 },
                { "modified", zindex = 20, align = "right" },
                { "diagnostics", zindex = 20, align = "right" },
                { "git_status", zindex = 10, align = "right" },
              },
            },
          },
        },
      })

      map("n", "<leader>e", "<cmd>Neotree toggle reveal<cr>", { desc = "Explorer" })
      map("n", "<leader>E", "<cmd>Neotree reveal<cr>", { desc = "Reveal file" })
    end,
  },
}
