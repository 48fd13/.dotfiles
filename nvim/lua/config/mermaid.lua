-- Render the ```mermaid code block under the cursor as ASCII art
-- using the `mermaid-ascii` binary, shown in a floating window.

local function find_mermaid_block()
  local cursor_line = vim.fn.line(".")
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

  local start_line, end_line
  for i = cursor_line, 1, -1 do
    if lines[i] and lines[i]:match("^```mermaid%s*$") then
      start_line = i
      break
    elseif lines[i] and lines[i]:match("^```%s*$") and i ~= cursor_line then
      break
    end
  end

  if not start_line then
    return nil
  end

  for i = start_line + 1, #lines do
    if lines[i]:match("^```%s*$") then
      end_line = i
      break
    end
  end

  if not end_line then
    return nil
  end

  if cursor_line < start_line or cursor_line > end_line then
    return nil
  end

  local block = {}
  for i = start_line + 1, end_line - 1 do
    table.insert(block, lines[i])
  end
  return table.concat(block, "\n")
end

local function show_mermaid_ascii()
  if vim.fn.executable("mermaid-ascii") ~= 1 then
    vim.notify("mermaid-ascii is not installed or not on PATH", vim.log.levels.WARN)
    return
  end

  local source = find_mermaid_block()
  if not source then
    vim.notify("Cursor is not inside a ```mermaid block", vim.log.levels.INFO)
    return
  end

  local tmp = vim.fn.tempname() .. ".mmd"
  vim.fn.writefile(vim.split(source, "\n"), tmp)

  local result = vim.system({ "mermaid-ascii", "-f", tmp }, { text = true }):wait()
  vim.fn.delete(tmp)

  if result.code ~= 0 then
    vim.notify("mermaid-ascii failed:\n" .. (result.stderr or ""), vim.log.levels.ERROR)
    return
  end

  local output_lines = vim.split(result.stdout, "\n")
  -- strip trailing empty lines
  while #output_lines > 0 and output_lines[#output_lines] == "" do
    table.remove(output_lines)
  end

  local width = 20
  for _, line in ipairs(output_lines) do
    width = math.max(width, vim.fn.strdisplaywidth(line))
  end
  width = math.min(width + 2, math.floor(vim.o.columns * 0.9))
  local height = math.min(#output_lines + 1, math.floor(vim.o.lines * 0.8))

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, output_lines)
  vim.bo[buf].modifiable = false
  vim.bo[buf].bufhidden = "wipe"

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "cursor",
    row = 1,
    col = 0,
    width = width,
    height = height,
    border = "rounded",
    title = " mermaid ",
    title_pos = "center",
    style = "minimal",
  })
  vim.wo[win].wrap = false

  local close = function()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end
  vim.keymap.set("n", "q", close, { buffer = buf, nowait = true })
  vim.keymap.set("n", "<Esc>", close, { buffer = buf, nowait = true })
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown" },
  callback = function(args)
    vim.keymap.set("n", "<leader>md", show_mermaid_ascii, {
      buffer = args.buf,
      desc = "Render mermaid diagram (ASCII)",
    })
  end,
})
