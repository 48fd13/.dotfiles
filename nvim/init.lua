vim.g.mapleader = " "
vim.g.maplocalleader = " "

if vim.fn.isdirectory("/opt/homebrew/bin") == 1 then
  vim.env.PATH = "/opt/homebrew/bin:" .. vim.env.PATH
end

require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.lazy")
