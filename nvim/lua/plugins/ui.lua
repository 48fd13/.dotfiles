return {
  {
    "https://github.com/famiu/bufdelete.nvim.git",
    lazy = false,
  },
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
        { "<leader>h", group = "harpoon" },
        { "<leader>o", group = "opencode" },
        { "<leader>w", group = "windows" },
      },
    },
  },
  {
    "https://github.com/OXY2DEV/markview.nvim.git",
    ft = { "markdown", "quarto", "rmd" },
    opts = {},
  },
  {
    "https://github.com/nyoom-engineering/oxocarbon.nvim.git",
    lazy = false,
    priority = 1000,
    config = function()
      vim.opt.background = "dark"
      vim.cmd.colorscheme("oxocarbon")
    end,
  },
  {
    "https://github.com/akinsho/bufferline.nvim.git",
    version = "*",
    dependencies = { "https://github.com/nvim-tree/nvim-web-devicons.git" },
    event = "VeryLazy",
    config = function()
      require("bufferline").setup({
        options = {
          diagnostics = "nvim_lsp",
          offsets = {
            { filetype = "neo-tree", text = "Explorer", highlight = "Directory", text_align = "left" },
          },
        },
      })

      local map = vim.keymap.set
      map("n", "<S-l>", "<cmd>BufferLineCycleNext<cr>", { desc = "Next buffer tab" })
      map("n", "<S-h>", "<cmd>BufferLineCyclePrev<cr>", { desc = "Previous buffer tab" })
      map("n", "<leader>bo", "<cmd>BufferLineCloseOthers<cr>", { desc = "Close other buffers" })
    end,
  },
  {
    "https://github.com/ThePrimeagen/harpoon.git",
    branch = "harpoon2",
    dependencies = { "https://github.com/nvim-lua/plenary.nvim.git" },
    config = function()
      local harpoon = require("harpoon")
      harpoon:setup()

      local map = vim.keymap.set
      map("n", "<leader>ha", function()
        harpoon:list():add()
      end, { desc = "Harpoon add file" })

      map("n", "<leader>hh", function()
        harpoon.ui:toggle_quick_menu(harpoon:list())
      end, { desc = "Harpoon menu" })

      for i = 1, 4 do
        map("n", "<leader>" .. i, function()
          harpoon:list():select(i)
        end, { desc = "Harpoon to file " .. i })
      end

      map("n", "<leader>hp", function()
        harpoon:list():prev()
      end, { desc = "Harpoon prev" })
      map("n", "<leader>hn", function()
        harpoon:list():next()
      end, { desc = "Harpoon next" })
    end,
  },
}
