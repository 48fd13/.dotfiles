-- Follow a markdown link `[text](path)` from anywhere on the current line,
-- not just when the cursor sits exactly on the path text. This makes link
-- following reliable even when markview.nvim is concealing the raw syntax.

local function follow_markdown_link()
  local line = vim.api.nvim_get_current_line()
  local cursor_col = vim.fn.col(".") -- 1-indexed

  local links = {}
  for open_paren, path, close_paren in line:gmatch("()%[.-%]%((.-)%)()") do
    table.insert(links, { start_col = open_paren, path = path, end_col = close_paren })
  end

  if #links == 0 then
    -- fall back to default gf behavior
    vim.cmd("normal! gf")
    return
  end

  -- prefer a link whose range contains the cursor, otherwise the closest one
  local best
  local best_dist = math.huge
  for _, link in ipairs(links) do
    if cursor_col >= link.start_col and cursor_col <= link.end_col then
      best = link
      break
    end
    local dist = math.min(math.abs(cursor_col - link.start_col), math.abs(cursor_col - link.end_col))
    if dist < best_dist then
      best_dist = dist
      best = link
    end
  end

  if not best then
    vim.cmd("normal! gf")
    return
  end

  local path = best.path
  -- strip a possible title, e.g. (path "title")
  path = path:match('^(%S+)') or path
  -- strip URL fragment for local file resolution
  local file_part = path:match("^([^#]+)") or path

  if file_part:match("^https?://") then
    vim.ui.open(path)
    return
  end

  local current_dir = vim.fn.expand("%:p:h")
  local target = vim.fn.simplify(current_dir .. "/" .. file_part)

  if vim.fn.filereadable(target) == 1 then
    vim.cmd("edit " .. vim.fn.fnameescape(target))
  else
    vim.notify("File not found: " .. target, vim.log.levels.WARN)
  end
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown" },
  callback = function(args)
    vim.keymap.set("n", "gf", follow_markdown_link, {
      buffer = args.buf,
      desc = "Follow markdown link (line-aware)",
    })
  end,
})
