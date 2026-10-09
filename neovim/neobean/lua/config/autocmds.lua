-- Filename: ~/github/dotfiles-latest/neovim/neobean/lua/config/autocmds.lua

-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- config/autocmds.lua

-- Require the colors.lua module and access the colors directly without
-- additional file reads
-- local colors = require("config.colors")

local function augroup(name)
  return vim.api.nvim_create_augroup("lazyvim_" .. name, { clear = true })
end

-- -- This is for dadbod-ui auto completion
-- -- https://github.com/kristijanhusak/vim-dadbod-completion/issues/53#issuecomment-1705335855
-- local cmp = require("cmp")
-- local autocomplete_group = vim.api.nvim_create_augroup("vimrc_autocompletion", { clear = true })
-- vim.api.nvim_create_autocmd("FileType", {
--   pattern = { "sql", "mysql", "plsql" },
--   callback = function()
--     cmp.setup.buffer({
--       sources = {
--         { name = "vim-dadbod-completion" },
--         { name = "buffer" },
--         { name = "luasnip" },
--       },
--     })
--   end,
--   group = autocomplete_group,
-- })

-- -- close some filetypes with <esc>
-- vim.api.nvim_create_autocmd("FileType", {
--   group = augroup("close_with_q"),
--   pattern = {
--     "PlenaryTestPopup",
--     "grug-far",
--     "help",
--     "lspinfo",
--     "notify",
--     "qf",
--     "spectre_panel",
--     "startuptime",
--     "tsplayground",
--     "neotest-output",
--     "checkhealth",
--     "neotest-summary",
--     "neotest-output-panel",
--     "dbout",
--     "gitsigns-blame",
--     "Lazy",
--   },
--   callback = function(event)
--     vim.bo[event.buf].buflisted = false
--     vim.schedule(function()
--       vim.keymap.set("n", "<esc>", function()
--         vim.cmd("close")
--         pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
--       end, {
--         buffer = event.buf,
--         silent = true,
--         desc = "Quit buffer",
--       })
--     end)
--   end,
-- })

-- -- This is used to switch between light and dark background colors when the
-- -- focus is lost or gained, for example when I switch from neovim to a tmux
-- -- pane on the right, or between 2 neovim splits
-- vim.api.nvim_create_autocmd({ "FocusGained", "FocusLost", "WinEnter", "WinLeave" }, {
--   callback = function(ev)
--     local active_bg = colors.linkarzu_color10 -- darker background
--     local inactive_bg = colors.linkarzu_color07 -- brighter background
--     if ev.event == "FocusGained" or ev.event == "WinEnter" then
--       -- Active window - darker background
--       vim.cmd("hi Normal guibg=" .. active_bg)
--       vim.cmd("hi NormalFloat guibg=" .. active_bg)
--       -- vim.cmd("hi NormalNC guibg=" .. active_bg)
--       -- vim.cmd("hi NormalFloatNC guibg=" .. active_bg)
--       vim.cmd("hi TreesitterContext guibg=" .. active_bg)
--       vim.cmd("hi TreesitterContextLineNumber guibg=" .. active_bg)
--     else
--       -- Inactive window - brighter background
--       vim.cmd("hi Normal guibg=" .. inactive_bg)
--       vim.cmd("hi NormalNC guibg=" .. inactive_bg)
--       vim.cmd("hi NormalFloat guibg=" .. inactive_bg)
--       vim.cmd("hi NormalFloatNC guibg=" .. inactive_bg)
--       vim.cmd("hi TreesitterContext guibg=" .. inactive_bg)
--       vim.cmd("hi TreesitterContextLineNumber guibg=" .. inactive_bg)
--     end
--   end,
-- })

-- -- -- This debounce prevents to see the color switch when switching betweeen 2
-- -- -- buffers. Remember that you'll see the color switch when switching between
-- -- -- tmux sessions, I haven't figured out how to add a delay there
-- local function update_background(event_type)
--   local active_bg = colors.linkarzu_color10 -- darker background
--   local inactive_bg = colors.linkarzu_color07 -- brighter background
--   if event_type == "FocusGained" or event_type == "WinEnter" then
--     -- Active window - darker background
--     vim.cmd("hi Normal guibg=" .. active_bg)
--     -- Commented so that when focus another pane inactive background changes
--     -- vim.cmd("hi NormalNC guibg=" .. active_bg)
--     vim.cmd("hi NormalFloat guibg=" .. active_bg)
--     vim.cmd("hi NormalFloatNC guibg=" .. active_bg)
--     vim.cmd("hi TreesitterContext guibg=" .. active_bg)
--     vim.cmd("hi TreesitterContextLineNumber guibg=" .. active_bg)
--     -- vim.cmd("hi MiniFilesTitleFocused guibg=" .. active_bg)
--     vim.cmd("hi MiniDiffSignChange guibg=" .. active_bg)
--     vim.cmd("hi MiniDiffSignAdd guibg=" .. active_bg)
--     vim.cmd("hi MiniDiffSignDelete guibg=" .. active_bg)
--     vim.cmd("hi NonText guibg=" .. active_bg)
--     vim.cmd("hi WinBar guibg=" .. active_bg)
--     -- These 2 statusline colors replace the lualine color when lualine is not
--     -- enabled
--     vim.cmd("hi StatusLine guibg=" .. active_bg)
--     vim.cmd("hi StatusLineNC guibg=" .. active_bg)
--     vim.cmd("hi CursorLine guibg=" .. colors.linkarzu_color13)
--     -- This is the background of the folded lines
--     vim.cmd("hi Folded guibg=" .. active_bg)
--   else
--     -- Inactive window - brighter background
--     vim.cmd("hi Normal guibg=" .. inactive_bg)
--     vim.cmd("hi NormalNC guibg=" .. inactive_bg)
--     vim.cmd("hi NormalFloat guibg=" .. inactive_bg)
--     vim.cmd("hi NormalFloatNC guibg=" .. inactive_bg)
--     vim.cmd("hi TreesitterContext guibg=" .. inactive_bg)
--     vim.cmd("hi TreesitterContextLineNumber guibg=" .. inactive_bg)
--     -- vim.cmd("hi MiniFilesTitle guibg=" .. inactive_bg)
--     vim.cmd("hi MiniDiffSignChange guibg=" .. inactive_bg)
--     vim.cmd("hi MiniDiffSignAdd guibg=" .. inactive_bg)
--     vim.cmd("hi MiniDiffSignDelete guibg=" .. inactive_bg)
--     vim.cmd("hi NonText guibg=" .. inactive_bg)
--     vim.cmd("hi WinBar guibg=" .. inactive_bg)
--     -- These 2 statusline colors replace the lualine color when lualine is not
--     -- enabled
--     vim.cmd("hi StatusLine guibg=" .. inactive_bg)
--     vim.cmd("hi StatusLineNC guibg=" .. inactive_bg)
--     -- I don't want to see the cursorline when window is unfocused
--     vim.cmd("hi CursorLine guibg=" .. inactive_bg)
--     -- This is the background of the folded lines
--     vim.cmd("hi Folded guibg=" .. inactive_bg)
--   end
-- end
-- -- Debounce function for Focus events
-- local debounce_timer = nil
-- local function debounced_update_background(ev)
--   local event_type = ev.event -- Capture the event type
--   -- Cancel any existing timer
--   if debounce_timer then
--     vim.fn.timer_stop(debounce_timer)
--     debounce_timer = nil
--   end
--   -- Start a new timer
--   debounce_timer = vim.fn.timer_start(50, function()
--     vim.schedule(function()
--       update_background(event_type)
--       debounce_timer = nil
--     end)
--   end)
-- end
-- -- Immediate function for Win events
-- local function immediate_update_background(ev)
--   update_background(ev.event)
-- end
-- -- Create autocmd for WinEnter and WinLeave with immediate update
-- vim.api.nvim_create_autocmd({ "WinEnter", "WinLeave" }, {
--   callback = immediate_update_background,
-- })
-- -- Create autocmd for FocusGained and FocusLost with debounce
-- vim.api.nvim_create_autocmd({ "FocusGained", "FocusLost" }, {
--   callback = debounced_update_background,
-- })

-- wrap and check for spell in text filetypes
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("wrap_spell"),
  pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
  callback = function()
    -- -- By default wrap is set to true regardless of what I chose in my options.lua file,
    -- -- This sets wrapping for my skitty-notes and I don't want to have
    -- -- wrapping there, I wanto to decide this in the options.lua file
    -- vim.opt_local.wrap = false
    vim.opt_local.spell = true
  end,
})

-- No sign column in markdown. The gutter is numberwidth 5 + 2 for signs, and
-- render-markdown's checkbox icon adds 2 cells Neovim counts when wrapping, so
-- a task line at prettier's printWidth 70 needs 72 columns. Dropping the
-- signs frees those 2 columns without breaking checkbox alignment.
vim.api.nvim_create_autocmd({ "FileType", "BufWinEnter" }, {
  group = augroup("markdown_no_signcolumn"),
  callback = function(args)
    if vim.bo[args.buf].filetype == "markdown" then
      vim.opt_local.signcolumn = "no"
    end
  end,
})

-- Spanish-only notes default to Spanish spelling.
local spanish_spell_root = vim.fn.fnamemodify(vim.fn.expand("~/github/obsidian_main/075-umg"), ":p"):gsub("/$", "")
local function set_spanish_spell_for_path(bufnr)
  local buf_name = vim.api.nvim_buf_get_name(bufnr)
  if buf_name == "" then
    return
  end

  local file_path = vim.fn.fnamemodify(buf_name, ":p")
  if file_path:find(spanish_spell_root .. "/", 1, true) == 1 then
    vim.opt_local.spell = true
    vim.opt_local.spelllang = "es"
  end
end

vim.api.nvim_create_autocmd({ "BufEnter", "BufReadPost", "BufNewFile" }, {
  group = augroup("spanish_spell_paths"),
  callback = function(event)
    set_spanish_spell_for_path(event.buf)
  end,
})
set_spanish_spell_for_path(0)

-- -- Show LSP diagnostics (inlay hints) in a hover window / popup lamw26wmal
-- -- https://github.com/neovim/nvim-lspconfig/wiki/UI-Customization#show-line-diagnostics-automatically-in-hover-window
-- -- https://www.reddit.com/r/neovim/comments/1168p97/how_can_i_make_lspconfig_wrap_around_these_hints/
-- -- If you want to increase the hover time, modify vim.o.updatetime = 200 in your
-- -- options.lua file
-- --
-- -- -- In case you want to use custom borders
-- -- local border = {
-- --   { "🭽", "FloatBorder" },
-- --   { "▔", "FloatBorder" },
-- --   { "🭾", "FloatBorder" },
-- --   { "▕", "FloatBorder" },
-- --   { "🭿", "FloatBorder" },
-- --   { "▁", "FloatBorder" },
-- --   { "🭼", "FloatBorder" },
-- --   { "▏", "FloatBorder" },
-- -- }
-- vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
--   group = vim.api.nvim_create_augroup("float_diagnostic", { clear = true }),
--   callback = function()
--     vim.diagnostic.open_float(nil, {
--       focus = false,
--       border = "rounded",
--     })
--   end,
-- })

-- Clear jumps when I open Neovim, otherwise there'a lot of crap that links to
-- different files, trying this and will see if it works out or not
vim.api.nvim_create_autocmd("BufWinEnter", {
  once = true,
  callback = function()
    vim.schedule(function()
      vim.cmd("clearjumps")
    end)
  end,
})

-- Disabled while testing the harper_ls root_dir exclusion in lua/plugins/nvim-lspconfig.lua.
-- This autocmd used LspStop, which stops the Harper client globally instead of only skipping
-- the current buffer.
-- -- Disable harper_ls when a markdown file inside ~/github/obsidian_main/075-umg is opened
-- local umg_root = vim.fn.expand("~/github/obsidian_main/075-umg")
-- -- Only register the autocmd if the target directory exists
-- if vim.fn.isdirectory(umg_root) == 1 then
--   vim.api.nvim_create_autocmd("BufRead", {
--     group = augroup("umg_markdown_disable_ls"),
--     pattern = "*.md",
--     callback = function()
--       local file_path = vim.fn.expand("%:p")
--       -- Check that the file resides inside umg_root
--       if vim.startswith(file_path, umg_root .. "/") then
--         -- Prevent running twice for the same buffer
--         if vim.b.harper_ls_disabled then
--           return
--         end
--         vim.b.harper_ls_disabled = true
--         vim.schedule(function()
--           pcall(vim.api.nvim_command, "LspStop harper_ls")
--         end)
--         vim.notify("UMG markdown opened: harper_ls disabled", vim.log.levels.INFO)
--       end
--     end,
--   })
-- end

local group = vim.api.nvim_create_augroup("MyQMK", {})

vim.api.nvim_create_autocmd("BufEnter", {
  desc = "Format glove80",
  group = group,
  pattern = "*/linkarzu-glove80/config/glove80.keymap", -- this is a pattern to match the filepath of whatever board you wish to target
  callback = function()
    require("qmk").setup({
      name = "LAYOUT_glove80",
      variant = "zmk",
      auto_format_pattern = "*/linkarzu-glove80/config/glove80.keymap",
      layout = {
        "x x x x x _ _ _ _ _ _ _ _ _ x x x x x",
        "x x x x x x _ _ _ _ _ _ _ x x x x x x",
        "x x x x x x _ _ _ _ _ _ _ x x x x x x",
        "x x x x x x _ _ _ _ _ _ _ x x x x x x",
        "x x x x x x x x x _ x x x x x x x x x",
        "x x x x x _ x x x _ x x x _ x x x x x",
      },
    })
  end,
})

vim.api.nvim_create_autocmd("BufEnter", {
  desc = "Format toucan",
  group = group,
  pattern = "*/zmk-keyboard-toucan/config/toucan.keymap", -- this is a pattern to match the filepath of whatever board you wish to target
  callback = function()
    require("qmk").setup({
      name = "LAYOUT_toucan",
      variant = "zmk",
      auto_format_pattern = "*/zmk-keyboard-toucan/config/toucan.keymap",
      layout = {
        "x x x x x x _ _ _ x x x x x x",
        "x x x x x x _ _ _ x x x x x x",
        "x x x x x x _ _ _ x x x x x x",
        "_ _ _ _ x x x _ x x x _ _ _ _",
      },
    })
  end,
})

vim.api.nvim_create_autocmd("BufEnter", {
  desc = "Format corne-min",
  group = group,
  pattern = "*/zmk-corne-min/config/corne_min.keymap", -- this is a pattern to match the filepath of whatever board you wish to target
  callback = function()
    require("qmk").setup({
      name = "LAYOUT_cornemin",
      variant = "zmk",
      auto_format_pattern = "*/zmk-corne-min/config/corne_min.keymap",
      layout = {
        "x x x x x x _ _ _ x x x x x x",
        "x x x x x x _ _ _ x x x x x x",
        "x x x x x x _ _ _ x x x x x x",
        "_ _ _ _ x x x _ x x x _ _ _ _",
      },
    })
  end,
})

-- -- In case you want to disable spell
-- vim.api.nvim_create_autocmd("FileType", {
--   group = augroup("wrap_spell"),
--   pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
--   callback = function()
--     vim.opt_local.spell = false
--   end,
-- })

-- Render markdown codelens on the same line.
-- Nvim 0.12 built-in codelens renders above the target line.
-- To switch back to built-in rendering:
-- vim.lsp.codelens.enable(true, { bufnr = bufnr })
local markdown_codelens_ns = vim.api.nvim_create_namespace("markdown_codelens_inline")
local code_lens_method = vim.lsp.protocol.Methods.textDocument_codeLens or "textDocument/codeLens"
local function refresh_markdown_codelens(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end
  if vim.bo[bufnr].buftype ~= "" or vim.bo[bufnr].filetype ~= "markdown" then
    vim.api.nvim_buf_clear_namespace(bufnr, markdown_codelens_ns, 0, -1)
    return
  end
  if #vim.lsp.get_clients({ bufnr = bufnr, method = code_lens_method }) == 0 then
    return
  end
  vim.lsp.codelens.enable(false, { bufnr = bufnr })
  vim.api.nvim_buf_clear_namespace(bufnr, markdown_codelens_ns, 0, -1)
  local params = { textDocument = vim.lsp.util.make_text_document_params(bufnr) }
  vim.lsp.buf_request_all(bufnr, code_lens_method, params, function(results)
    if not vim.api.nvim_buf_is_valid(bufnr) then
      return
    end
    vim.api.nvim_buf_clear_namespace(bufnr, markdown_codelens_ns, 0, -1)
    local by_line = {}
    local line_count = vim.api.nvim_buf_line_count(bufnr)
    for _, response in pairs(results) do
      for _, lens in ipairs(response.result or {}) do
        local title = lens.command and lens.command.title
        local row = lens.range and lens.range.start.line
        if title and row and row >= 0 and row < line_count then
          by_line[row] = by_line[row] or {}
          table.insert(by_line[row], title)
        end
      end
    end
    for row, titles in pairs(by_line) do
      vim.api.nvim_buf_set_extmark(bufnr, markdown_codelens_ns, row, 0, {
        virt_text = { { " " .. table.concat(titles, " | "), "LspCodeLens" } },
        virt_text_pos = "eol",
        hl_mode = "combine",
      })
    end
  end)
end
vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave", "LspAttach" }, {
  callback = function(args)
    refresh_markdown_codelens(args.buf)
  end,
})

-- Reload files changed outside Neovim while it stays focused, like a
-- voice-inbox task or a Meeting Manager livestream block added to the daily
-- note. LazyVim only runs checktime on FocusGained/TermClose/TermLeave, so an
-- already focused buffer never noticed. Only in normal mode, so it never
-- interrupts typing; auto-save keeps buffers saved, and autoread then reloads
-- them silently
--
-- A reload fires FileType again, and the heading folding in keymaps.lua resets
-- folds with zX, so the open/closed state of each heading is saved before the
-- reload and restored after it. Headings are matched by their text, not their
-- line number, because the external change usually adds lines above them
local heading_patterns = { markdown = "^#+%s", typst = "^=+%s" }

local function heading_lines(win)
  local buf = vim.api.nvim_win_get_buf(win)
  local pattern = heading_patterns[vim.bo[buf].filetype]
  local headings, seen = {}, {}
  if not pattern then
    return headings
  end
  for lnum, text in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
    if text:match(pattern) then
      seen[text] = (seen[text] or 0) + 1
      table.insert(headings, { lnum = lnum, key = text .. "\0" .. seen[text] })
    end
  end
  return headings
end

local function save_heading_folds(win)
  return vim.api.nvim_win_call(win, function()
    local state = { view = vim.fn.winsaveview(), folds = {} }
    for _, heading in ipairs(heading_lines(win)) do
      local closed_at = vim.fn.foldclosed(heading.lnum)
      -- Inside a closed parent the heading's own state is unknown, skip it
      if closed_at == -1 or closed_at == heading.lnum then
        state.folds[heading.key] = closed_at == heading.lnum
      end
    end
    return state
  end)
end

local function restore_heading_folds(win, state)
  vim.api.nvim_win_call(win, function()
    local headings = heading_lines(win)
    -- Open top-down so parents open before their children are checked, then
    -- close bottom-up so children close before a parent hides them
    for _, heading in ipairs(headings) do
      if state.folds[heading.key] == false and vim.fn.foldclosed(heading.lnum) ~= -1 then
        pcall(vim.cmd, heading.lnum .. "foldopen")
      end
    end
    for index = #headings, 1, -1 do
      local heading = headings[index]
      if state.folds[heading.key] == true and vim.fn.foldclosed(heading.lnum) == -1 then
        pcall(vim.cmd, heading.lnum .. "foldclose")
      end
    end
    vim.fn.winrestview(state.view)
  end)
end

-- mtime of each buffer's file as last seen, to only do the fold work when the
-- file really changed on disk
local known_mtime = {}

local function file_mtime(buf)
  local name = vim.api.nvim_buf_get_name(buf)
  local stat = name ~= "" and vim.uv.fs_stat(name) or nil
  return stat and (stat.mtime.sec .. "." .. stat.mtime.nsec) or nil
end

vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "FileChangedShellPost" }, {
  group = augroup("external_reload_mtime"),
  callback = function(args)
    known_mtime[args.buf] = file_mtime(args.buf)
  end,
})

-- Daily notes reloaded after an outside change are saved right away, so the
-- format-on-save chain (prettier wrapping, boundary newlines) also applies to
-- lines that voice-inbox or the Meeting Manager wrote. Limited to daily notes
-- so files changed by git or other tools are never written behind my back
local format_on_reload_dirs = {
  vim.fs.normalize(vim.fn.expand("~/github/notes/250-daily")),
  vim.fs.normalize(vim.fn.expand("~/github/obsidian_main/250-daily")),
}

local function formats_on_reload(buf)
  local path = vim.fs.normalize(vim.api.nvim_buf_get_name(buf))
  for _, dir in ipairs(format_on_reload_dirs) do
    if vim.startswith(path, dir .. "/") then
      return true
    end
  end
  return false
end

local function reload_changed_buffers()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buftype == "" then
      local mtime = file_mtime(buf)
      if mtime and known_mtime[buf] and mtime ~= known_mtime[buf] then
        local saved = {}
        for _, win in ipairs(vim.fn.win_findbuf(buf)) do
          saved[win] = save_heading_folds(win)
        end
        local tick = vim.api.nvim_buf_get_changedtick(buf)
        pcall(vim.cmd.checktime, tostring(buf))
        local reloaded = vim.api.nvim_buf_get_changedtick(buf) ~= tick
        if reloaded and not vim.bo[buf].modified and formats_on_reload(buf) then
          vim.api.nvim_buf_call(buf, function()
            pcall(vim.cmd, "silent write")
          end)
        end
        known_mtime[buf] = file_mtime(buf)
        for win, state in pairs(saved) do
          if vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) == buf then
            restore_heading_folds(win, state)
          end
        end
      elseif mtime and not known_mtime[buf] then
        known_mtime[buf] = mtime
      end
    end
  end
end

local checktime_timer = vim.uv.new_timer()
checktime_timer:start(
  2000,
  2000,
  vim.schedule_wrap(function()
    if vim.api.nvim_get_mode().mode == "n" and vim.fn.getcmdwintype() == "" then
      reload_changed_buffers()
    end
  end)
)

-- After a save in ~/github/notes, run the voice-inbox LaunchAgent right away,
-- so the phone task page shows the change within seconds instead of on the
-- next minute. Debounced because auto-save writes often. Only with a UI, the
-- headless Neovim that voice-inbox uses for toggle_done never triggers it
-- ~/github/voice-inbox/mac/voice_inbox_pull.py
local voice_inbox_notes_dir = vim.fs.normalize(vim.fn.expand("~/github/notes"))
local voice_inbox_timer = vim.uv.new_timer()
vim.api.nvim_create_autocmd("BufWritePost", {
  group = augroup("voice_inbox_sync"),
  pattern = "*.md",
  callback = function(args)
    if #vim.api.nvim_list_uis() == 0 then
      return
    end
    local path = vim.fs.normalize(vim.api.nvim_buf_get_name(args.buf))
    if not vim.startswith(path, voice_inbox_notes_dir .. "/") then
      return
    end
    voice_inbox_timer:stop()
    voice_inbox_timer:start(
      3000,
      0,
      vim.schedule_wrap(function()
        vim.system({ "/bin/launchctl", "kickstart", "gui/" .. vim.uv.getuid() .. "/com.linkarzu.voice-inbox-pull" })
      end)
    )
  end,
})

-- Watchdog so an exiting Neovim with no UI can never hang. In 0.12 the TUI
-- spawns an `nvim --embed` server, when kitty closes the server starts its
-- exit, and if anything raised an error on the way out it stops at a "Press
-- ENTER" prompt nobody can answer. Those orphans kept up to 6 GB each for
-- days. Only armed on exit with no UI attached, so `:detach` and a normal
-- `:qa` with a visible prompt are untouched. Swap files are already
-- preserved at this point. The libuv timer still fires inside that prompt's
-- input loop, so the kill gets through
vim.api.nvim_create_autocmd("VimLeavePre", {
  group = augroup("exit_watchdog"),
  callback = function()
    if #vim.api.nvim_list_uis() > 0 then
      return
    end
    local exit_timer = vim.uv.new_timer()
    exit_timer:start(10000, 0, function()
      vim.uv.kill(vim.uv.os_getpid(), "sigkill")
    end)
  end,
})

-- Neovim writes ShaDa through main.shada.tmp.a to .tmp.z and never removes
-- one left by an exit that was killed mid-write. Once all 26 exist every
-- exit fails with E138, and that error is what made the watchdog above
-- necessary. Leftovers older than a day are removed at startup, fresh ones
-- may belong to another Neovim exiting right now
local shada_dir = vim.fn.stdpath("state") .. "/shada"
local day_ago = os.time() - 86400
for name, kind in vim.fs.dir(shada_dir) do
  if kind == "file" and name:match("%.shada%.tmp%.%a$") then
    local path = shada_dir .. "/" .. name
    local stat = vim.uv.fs_stat(path)
    if stat and stat.mtime.sec < day_ago then
      os.remove(path)
    end
  end
end
