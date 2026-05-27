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

-- When I open markdown files I want to fold the markdown headings
-- Originally I thought about using it only for skitty-notes, but I think I want
-- it in all markdown files
--
-- if vim.g.neovim_mode == "skitty" then
vim.api.nvim_create_autocmd("BufRead", {
  pattern = "*.md",
  callback = function()
    -- Get the full path of the current file
    local file_path = vim.fn.expand("%:p")
    -- Ignore files in my daily note directory
    if file_path:match(os.getenv("HOME") .. "/github/obsidian_main/250%-daily/") then
      return
    end -- Avoid running zk multiple times for the same buffer
    if vim.b.zk_executed then
      return
    end
    vim.b.zk_executed = true -- Mark as executed
    -- Use `vim.defer_fn` to add a slight delay before executing `zk`
    vim.defer_fn(function()
      vim.cmd("normal zk")
      -- This write was disabling my inlay hints
      -- vim.cmd("silent write")
      vim.notify("Folded keymaps", vim.log.levels.INFO)
    end, 100) -- Delay in milliseconds (100ms should be enough)
  end,
})

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
