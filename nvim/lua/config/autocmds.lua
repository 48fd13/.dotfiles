local map = vim.keymap.set

vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  pattern = "*",
  command = "if mode() != 'c' | checktime | endif",
})

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(event)
    local opts = { buffer = event.buf }

    map("n", "gd", vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "Go to definition" }))
    map("n", "gr", vim.lsp.buf.references, vim.tbl_extend("force", opts, { desc = "References" }))
    map("n", "K", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "Hover" }))
    map("n", "<leader>rn", vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "Rename" }))
    map("n", "<leader>cr", vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "Rename" }))
    map("n", "<leader>ca", vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "Code action" }))
  end,
})

local function bold_existing_highlights(groups)
  for _, group in ipairs(groups) do
    local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = group, link = false })
    if ok and next(hl) then
      hl.bold = true
      vim.api.nvim_set_hl(0, group, hl)
    end
  end
end

local markdown_heading_groups = {
  "markdownH1",
  "markdownH2",
  "markdownH3",
  "markdownH4",
  "markdownH5",
  "markdownH6",
  "@markup.heading.markdown",
  "@markup.heading.1.markdown",
  "@markup.heading.2.markdown",
  "@markup.heading.3.markdown",
  "@markup.heading.4.markdown",
  "@markup.heading.5.markdown",
  "@markup.heading.6.markdown",
}

vim.api.nvim_create_autocmd({ "VimEnter", "ColorScheme" }, {
  callback = function()
    bold_existing_highlights(markdown_heading_groups)
  end,
})
