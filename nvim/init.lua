vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.opt.clipboard = "unnamedplus"
if vim.fn.isdirectory("/opt/homebrew/bin") == 1 then
  vim.env.PATH = "/opt/homebrew/bin:" .. vim.env.PATH
end

require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.mermaid")
require("config.markdown_links")
require("config.lazy")
