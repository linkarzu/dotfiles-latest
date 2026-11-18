-- Filename: ~/github/dotfiles-latest/neovim/neobean/lua/config/modules/lesson_output.lua
-- ~/github/dotfiles-latest/neovim/neobean/lua/config/modules/lesson_output.lua
--
-- Stream lessons: a : command run with the cursor in a guide (below an
-- `<!-- obs-meeting-manager:slides:<deck> -->` line) shows itself and its result
-- in a popup at the top right, so viewers can read it. It stays until the next
-- command replaces it, Esc closes it, or I leave the buffer. Below an
-- `<!-- obs-meeting-manager:results:off -->` line, and everywhere else, messages
-- go to noice's mini view as usual. noice.lua routes the messages here.

local M = {}

local marker = "<!%-%- obs%-meeting%-manager:slides:[%w._-]+ %-%->"
-- Prompts wait for an answer, so noice keeps them
local skipped_kinds =
  { confirm = true, confirm_sub = true, number_prompt = true, return_prompt = true, search_count = true }
local error_kinds = { emsg = true, echoerr = true, lua_error = true, rpc_error = true }
-- Messages from the command arrive after it runs (noice batches them)
local window_ms = 500

local capture -- { cmd, buf, until_ms, messages = { { id, text, error } } }
local popup -- { win, buf, guide }
local ns = vim.api.nvim_create_namespace("lesson_output")

-- The nearest tag above the cursor decides: a slides tag turns the popup on,
-- this one turns it off (normal messages, to show what they look like)
local off_marker = "<!%-%- obs%-meeting%-manager:results:off %-%->"

local function in_guide()
  if vim.bo.filetype ~= "markdown" then
    return false
  end
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local lines = vim.api.nvim_buf_get_lines(0, 0, row, false)
  for index = #lines, 1, -1 do
    if lines[index]:match(marker) then
      return true
    elseif lines[index]:match(off_marker) then
      return false
    end
  end
  return false
end

function M.close()
  if not popup then
    return
  end
  if vim.api.nvim_win_is_valid(popup.win) then
    vim.api.nvim_win_close(popup.win, true)
  end
  if vim.api.nvim_buf_is_valid(popup.guide) then
    pcall(vim.keymap.del, "n", "<Esc>", { buffer = popup.guide })
  end
  popup = nil
end

local function show()
  if not capture then
    return
  end
  local lines, errors = { ":" .. capture.cmd }, {}
  for _, message in ipairs(capture.messages) do
    for _, line in ipairs(vim.split(message.text, "\n", { trimempty = true })) do
      table.insert(lines, line)
      if message.error then
        errors[#lines] = true
      end
    end
  end
  if #lines == 1 then
    table.insert(lines, "(no output)")
  end

  local width = 30
  for _, line in ipairs(lines) do
    width = math.max(width, vim.fn.strdisplaywidth(line))
  end
  width = math.min(width + 2, math.floor(vim.o.columns * 0.6))
  local height = math.min(#lines, math.floor(vim.o.lines * 0.6))

  if not popup or not vim.api.nvim_win_is_valid(popup.win) then
    M.close()
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
    popup = { win = win, buf = buf, guide = capture.buf }
    vim.keymap.set("n", "<Esc>", function()
      M.close()
      vim.cmd.nohlsearch()
    end, { buffer = capture.buf, desc = "Close the lesson result" })
  else
    vim.api.nvim_win_set_config(popup.win, { width = width, height = height })
  end

  vim.api.nvim_buf_set_lines(popup.buf, 0, -1, false, lines)
  vim.api.nvim_buf_clear_namespace(popup.buf, ns, 0, -1)
  vim.hl.range(popup.buf, ns, "Special", { 0, 0 }, { 0, -1 })
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

function M.setup()
  local group = vim.api.nvim_create_augroup("lesson_output", { clear = true })
  vim.api.nvim_create_autocmd("CmdlineLeave", {
    group = group,
    pattern = ":",
    callback = function()
      if vim.v.event.abort then
        return
      end
      local cmd = vim.fn.getcmdline()
      -- :13 only moves the cursor, maybe out of the guide
      if cmd:match("^%s*%d*%s*$") then
        return
      end
      if not in_guide() then
        capture = nil
        M.close()
        return
      end
      capture = { cmd = cmd, buf = vim.api.nvim_get_current_buf(), messages = {} }
      capture.until_ms = vim.uv.now() + window_ms
      -- After the command ran: a popup even when it printed nothing
      vim.schedule(function()
        if capture and capture.cmd == cmd then
          capture.until_ms = vim.uv.now() + window_ms
          show()
        end
      end)
    end,
  })
  vim.api.nvim_create_autocmd({ "BufLeave", "VimResized" }, {
    group = group,
    callback = function()
      M.close()
    end,
  })
end

return M
