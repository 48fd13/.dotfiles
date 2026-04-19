vim.opt.nu = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.termguicolors = true
vim.opt.scrolloff = 8
vim.g.mapleader = " "

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  { "https://github.com/ellisonleao/gruvbox.nvim.git", priority = 1000, config = true },

  {
    "https://github.com/nvim-telescope/telescope.nvim.git",
    dependencies = { "https://github.com/nvim-lua/plenary.nvim.git" },
    config = function()
      local actions = require("telescope.actions")
      local builtin = require("telescope.builtin")

      require("telescope").setup({
        defaults = {
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
      })

      vim.keymap.set("n", "<leader>ff", builtin.find_files)
      vim.keymap.set("n", "<leader>fg", builtin.live_grep)
      vim.keymap.set("n", "<leader>fb", builtin.buffers)
    end,
  },

  {
    "https://github.com/nvim-treesitter/nvim-treesitter.git",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").setup({})
    end,
  },
})

vim.o.background = "dark"
vim.cmd([[colorscheme gruvbox]])
