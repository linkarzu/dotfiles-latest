-- Filename: ~/github/dotfiles-latest/neovim/neobean/lua/config/modules/lesson_output.lua
-- ~/github/dotfiles-latest/neovim/neobean/lua/config/modules/lesson_output.lua
--
-- Stream lessons: with the result popup on (<leader>uR), a : command shows
-- itself and its result in a popup at the top right, so viewers can read it.
-- It stays until the next command replaces it, Esc closes it, or I leave the
-- buffer. Off (the default), messages go to noice's mini view as usual.
-- noice.lua routes the messages here.
--
-- Lesson files (lua-lessons/*.lua in my notes) work like a notebook: Enter
-- runs the block under the cursor (the lines between blank lines) as Lua,
-- the same as :lua would, shows its code and result in the popup, and moves
-- to the next block. Enter on a visual selection runs just those lines.

local M = {}

-- Prompts wait for an answer, so noice keeps them
local skipped_kinds =
  { confirm = true, confirm_sub = true, number_prompt = true, return_prompt = true, search_count = true }
local error_kinds = { emsg = true, echoerr = true, lua_error = true, rpc_error = true }
-- Messages from the command arrive after it runs (noice batches them)
local window_ms = 500

local lessons_dir = vim.fn.expand("~/github/notes/010-newNotes/lua-lessons/")

local enabled = false
-- title: the command or the code that ran, code: draw a line under it,
-- error: what stopped a block (shown last)
local capture -- { title, code, buf, until_ms, error, messages = { { id, text, error } } }
local popup -- { win, buf, owner }
local ns = vim.api.nvim_create_namespace("lesson_output")

-- noice drops a message that is the same as the last one it showed, so running
-- print(answer) again would show (no output): forget the last one first
local function start(mine)
  pcall(function()
    require("noice.ui.state").clear("msg_show")
  end)
  capture = mine
end

function M.close()
  if not popup then
    return
  end
  if vim.api.nvim_win_is_valid(popup.win) then
    vim.api.nvim_win_close(popup.win, true)
  end
  if vim.api.nvim_buf_is_valid(popup.owner) then
    pcall(vim.keymap.del, "n", "<Esc>", { buffer = popup.owner })
  end
  popup = nil
end

local function show()
  if not capture then
    return
  end
  -- Nothing printed and another buffer is up (:e, :h): that buffer is the result
  if #capture.messages == 0 and not capture.error and vim.api.nvim_get_current_buf() ~= capture.buf then
    M.close()
    return
  end
  local lines, errors = vim.list_extend({}, capture.title), {}
  local rule = capture.code and #lines + 1
  if rule then
    table.insert(lines, "")
  end
  local head = #lines
  local messages = vim.list_extend({}, capture.messages)
  if capture.error then
    table.insert(messages, { text = capture.error, error = true })
  end
  for _, message in ipairs(messages) do
    for _, line in ipairs(vim.split(message.text, "\n", { trimempty = true })) do
      table.insert(lines, line)
      if message.error then
        errors[#lines] = true
      end
    end
  end
  if #lines == head then
    table.insert(lines, "(no output)")
  end

  local width = 30
  for _, line in ipairs(lines) do
    width = math.max(width, vim.fn.strdisplaywidth(line))
  end
  width = math.min(width + 2, math.floor(vim.o.columns * 0.6))
  if rule then
    lines[rule] = string.rep("─", width)
  end
  local height = math.min(#lines, math.floor(vim.o.lines * 0.6))

  local owner = vim.api.nvim_get_current_buf()
  if popup and (popup.owner ~= owner or not vim.api.nvim_win_is_valid(popup.win)) then
    M.close()
  end
  if not popup then
    local buf = vim.api.nvim_create_buf(false, true)
    vim.bo[buf].bufhidden = "wipe"
    local win = vim.api.nvim_open_win(buf, false, {
      relative = "editor",
      anchor = "NE",
      row = 1,
      col = vim.o.columns - 1,
      width = width,
      height = height,
      style = "minimal",
      border = "rounded",
      title = " Result ",
      title_pos = "center",
      focusable = false,
      zindex = 60,
    })
    vim.wo[win].wrap = true
    popup = { win = win, buf = buf, owner = owner }
    vim.keymap.set("n", "<Esc>", function()
      M.close()
      vim.cmd.nohlsearch()
    end, { buffer = owner, desc = "Close the lesson result" })
  else
    vim.api.nvim_win_set_config(popup.win, { width = width, height = height })
  end

  vim.api.nvim_buf_set_lines(popup.buf, 0, -1, false, lines)
  vim.api.nvim_buf_clear_namespace(popup.buf, ns, 0, -1)
  for row = 1, #capture.title do
    vim.hl.range(popup.buf, ns, "Special", { row - 1, 0 }, { row - 1, -1 })
  end
  if rule then
    vim.hl.range(popup.buf, ns, "Comment", { rule - 1, 0 }, { rule - 1, -1 })
  end
  for row in pairs(errors) do
    vim.hl.range(popup.buf, ns, "ErrorMsg", { row - 1, 0 }, { row - 1, -1 })
  end
end

-- noice route filter: true takes the message out of noice's views (the route
-- skips it) after keeping its text for the popup
function M.takes(message)
  if not capture or vim.uv.now() > capture.until_ms or skipped_kinds[message.kind] then
    return false
  end
  local text = message:content()
  local entry
  for _, kept in ipairs(capture.messages) do
    if kept.id == message.id then
      entry = kept
    end
  end
  if not entry then
    entry = { id = message.id }
    table.insert(capture.messages, entry)
  end
  entry.text, entry.error = text, error_kinds[message.kind] or false
  vim.schedule(show)
  return true
end

function M.toggle()
  enabled = not enabled
  if not enabled then
    capture = nil
    M.close()
  end
  vim.notify(enabled and "Result popup on" or "Result popup off")
end

local function blank(row)
  return vim.fn.getline(row):match("^%s*$") ~= nil
end

local function is_comment(line)
  return line:match("^%s*%-%-") ~= nil
end

-- Runs lines first..last as one chunk of Lua, like :first,lastlua
function M.run(first, last)
  local lines = vim.api.nvim_buf_get_lines(0, first - 1, last, false)
  local code = vim.tbl_filter(function(line)
    return not is_comment(line) and not line:match("^%s*$")
  end, lines)
  if #code == 0 then
    return
  end
  local mine = { title = code, code = true, buf = vim.api.nvim_get_current_buf(), messages = {} }
  mine.until_ms = vim.uv.now() + window_ms
  start(mine)
  -- load() instead of :first,lastlua: the same globals and locals, but what the
  -- block printed before an error still shows (:lua drops it)
  local chunk, err = load(table.concat(lines, "\n"), "=lesson", "t")
  local ok = chunk ~= nil
  if chunk then
    ok, err = pcall(chunk)
  end
  if not ok then
    -- "lesson:2: attempt ..." -> "Error: attempt ...". No line number: inside a
    -- function it counts from the block that made the function
    -- Kept apart: what the block printed reaches the popup later, through noice
    mine.error = "Error: " .. tostring(err):gsub("^lesson:%d+: ", "")
  end
  vim.schedule(function()
    if capture == mine then
      mine.until_ms = vim.uv.now() + window_ms
      show()
    end
  end)
end

-- The block under the cursor: from the blank line above to the blank line below
local function block_at(row)
  local last_row = vim.fn.line("$")
  while row <= last_row and blank(row) do
    row = row + 1
  end
  if row > last_row then
    return nil
  end
  local first, last = row, row
  while first > 1 and not blank(first - 1) do
    first = first - 1
  end
  while last < last_row and not blank(last + 1) do
    last = last + 1
  end
  return first, last
end

-- The first code line of the next block that has code (headings are comments only)
local function next_code_row(after)
  local last_row = vim.fn.line("$")
  local row = after + 1
  while row <= last_row do
    local first, last = block_at(row)
    if not first then
      return nil
    end
    for line = first, last do
      if not is_comment(vim.fn.getline(line)) then
        return line
      end
    end
    row = last + 1
  end
end

function M.run_block()
  local first, last = block_at(vim.fn.line("."))
  if not first then
    return
  end
  M.run(first, last)
  local row = next_code_row(last)
  if row then
    vim.api.nvim_win_set_cursor(0, { row, 0 })
  end
end

function M.run_selection()
  local first, last = vim.fn.line("v"), vim.fn.line(".")
  if first > last then
    first, last = last, first
  end
  vim.api.nvim_feedkeys(vim.keycode("<Esc>"), "nx", false)
  M.run(first, last)
end

-- A lesson file: Enter runs Lua, and no lua_ls warnings or format on save
-- (the file breaks rules on purpose, like 2editor = "Vim")
local function lesson_buffer(buf)
  if vim.b[buf].lesson_file or not vim.startswith(vim.api.nvim_buf_get_name(buf), lessons_dir) then
    return
  end
  vim.b[buf].lesson_file = true
  vim.b[buf].autoformat = false
  vim.diagnostic.enable(false, { bufnr = buf })
  vim.keymap.set("n", "<CR>", M.run_block, { buffer = buf, desc = "[P]Run this block, go to the next" })
  vim.keymap.set("x", "<CR>", M.run_selection, { buffer = buf, desc = "[P]Run the selected lines" })
end

function M.setup()
  local group = vim.api.nvim_create_augroup("lesson_output", { clear = true })
  vim.api.nvim_create_autocmd("CmdlineLeave", {
    group = group,
    pattern = ":",
    callback = function()
      if not enabled or vim.v.event.abort then
        return
      end
      local cmd = vim.fn.getcmdline()
      -- :13 only moves the cursor
      if cmd:match("^%s*%d*%s*$") then
        return
      end
      local mine = { title = { ":" .. cmd }, buf = vim.api.nvim_get_current_buf(), messages = {} }
      mine.until_ms = vim.uv.now() + window_ms
      start(mine)
      -- After the command ran: a popup even when it printed nothing
      vim.schedule(function()
        if capture == mine then
          capture.until_ms = vim.uv.now() + window_ms
          show()
        end
      end)
    end,
  })
  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = "lua",
    callback = function(event)
      lesson_buffer(event.buf)
    end,
  })
  -- A lesson file opened before this module loaded (nvim lesson-1.lua)
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].filetype == "lua" then
      lesson_buffer(buf)
    end
  end
  vim.api.nvim_create_autocmd({ "BufLeave", "VimResized" }, {
    group = group,
    callback = function()
      M.close()
    end,
  })
end

return M
