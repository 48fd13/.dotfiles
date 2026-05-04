local map = vim.keymap.set

return {
  {
    "https://github.com/nickjvandyke/opencode.nvim.git",
    version = "*",
    config = function()
      vim.g.opencode_opts = {}

      map("n", "<leader>oa", function()
        require("opencode").ask("@this: ", { submit = true })
      end, { desc = "Ask opencode" })
      map("n", "<leader>ot", function()
        require("opencode").toggle()
      end, { desc = "Toggle opencode" })
    end,
  },
}
