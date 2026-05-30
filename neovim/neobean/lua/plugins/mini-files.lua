-- Filename: ~/github/dotfiles-latest/neovim/neobean/lua/plugins/mini-files.lua
-- ~/github/dotfiles-latest/neovim/neobean/lua/plugins/mini-files.lua
--
-- https://github.com/echasnovski/mini.files
--
-- I got this configuration from LazyVim.org
-- http://www.lazyvim.org/extras/editor/mini-files

-- I migrated my custom keymaps config and also the git status config to
-- separate files, as this file was growing too big
-- I also use this file as a centralized place for all the different keymaps,
-- including my custom ones
--
-- Load external modules first
local mini_files_km = require("config.modules.mini-files-km")

-- -- git config is slowing mini.files too much, so disabling it
local mini_files_git = require("config.modules.mini-files-git")

-- Disable preview on the following file extensions
-- When in a huge work related folder that has hundreds of excel files all over
-- the place, mini.files would lag when I hovered over .xlsx files, weird thing
-- is that it also happened with .txt files, so disavling preview for those as well
-- Problematic files live in a cloud service, like onedrive, could that be it?
local preview_blocklist_exts = {
  ods = true,
  xls = true,
  xlsb = true,
  xlsm = true,
  xlsx = true,
  txt = true,
  env = true,
}
local function is_preview_blocked_path(path)
  if type(path) ~= "string" then
    return false
  end
  local ext = vim.fn.fnamemodify(path, ":e"):lower()
  return preview_blocklist_exts[ext] == true
end
local function is_preview_blocked_file(entry)
  if not entry or entry.fs_type ~= "file" then
    return false
  end
  return is_preview_blocked_path(entry.path)
end
local function setup_conditional_preview(opts)
  local mini_files = require("mini.files")
  local group = vim.api.nvim_create_augroup("MiniFilesConditionalPreview", { clear = true })
  local disabled_preview = {
    buf = nil,
    win = nil,
  }
  local original_fs_open = vim.loop.fs_open
  local fs_open_guard_enabled = false
  local opening = false
  local function enable_fs_open_guard()
    if fs_open_guard_enabled then
      return
    end
    fs_open_guard_enabled = true
    vim.loop.fs_open = function(path, flags, mode, callback)
      if is_preview_blocked_path(path) then
        return nil
      end
      return original_fs_open(path, flags, mode, callback)
    end
  end
  local function disable_fs_open_guard()
    if not fs_open_guard_enabled then
      return
    end
    vim.loop.fs_open = original_fs_open
    fs_open_guard_enabled = false
  end
  local function close_disabled_preview()
    if disabled_preview.win and vim.api.nvim_win_is_valid(disabled_preview.win) then
      pcall(vim.api.nvim_win_close, disabled_preview.win, true)
    end
    if disabled_preview.buf and vim.api.nvim_buf_is_valid(disabled_preview.buf) then
      pcall(vim.api.nvim_buf_delete, disabled_preview.buf, { force = true })
    end
    disabled_preview.buf = nil
    disabled_preview.win = nil
  end
  local function center_line(text, width)
    local padding = math.max(math.floor((width - vim.fn.strdisplaywidth(text)) / 2), 0)
    return string.rep(" ", padding) .. text
  end
  local function disabled_preview_lines(entry, width, height)
    local name = entry.name or vim.fn.fnamemodify(entry.path, ":t")
    local content = height <= 1 and { center_line("PREVIEW DISABLED", width) }
      or height == 2 and { center_line("PREVIEW DISABLED", width), center_line(name, width) }
      or {
        "",
        center_line("PREVIEW DISABLED", width),
        "",
        center_line(name, width),
      }
    local lines = {}
    for _ = 1, math.max(math.floor((height - #content) / 2), 0) do
      table.insert(lines, "")
    end
    vim.list_extend(lines, content)
    while #lines < height do
      table.insert(lines, "")
    end
    return lines
  end
  local function get_native_preview_win(entry)
    local ok, state = pcall(mini_files.get_explorer_state)
    if not ok or not state then
      return nil
    end
    for _, win in ipairs(state.windows or {}) do
      if win.path == entry.path and vim.api.nvim_win_is_valid(win.win_id) then
        return win.win_id
      end
    end
  end
  local function show_disabled_preview(entry)
    local preview_win = get_native_preview_win(entry)
    if not preview_win then
      return close_disabled_preview()
    end
    local preview_config = vim.api.nvim_win_get_config(preview_win)
    local width = vim.api.nvim_win_get_width(preview_win)
    local height = vim.api.nvim_win_get_height(preview_win)
    if not disabled_preview.buf or not vim.api.nvim_buf_is_valid(disabled_preview.buf) then
      disabled_preview.buf = vim.api.nvim_create_buf(false, true)
      vim.bo[disabled_preview.buf].bufhidden = "wipe"
      vim.bo[disabled_preview.buf].buftype = "nofile"
      vim.bo[disabled_preview.buf].filetype = "minifiles-disabled-preview"
      vim.bo[disabled_preview.buf].swapfile = false
    end
    vim.bo[disabled_preview.buf].modifiable = true
    vim.api.nvim_buf_set_lines(disabled_preview.buf, 0, -1, false, disabled_preview_lines(entry, width, height))
    vim.bo[disabled_preview.buf].modifiable = false
    local win_config = vim.tbl_deep_extend("force", preview_config, {
      focusable = false,
      height = height,
      title = " PREVIEW DISABLED ",
      width = width,
      zindex = (preview_config.zindex or 99) + 1,
    })
    if disabled_preview.win and vim.api.nvim_win_is_valid(disabled_preview.win) then
      vim.api.nvim_win_set_config(disabled_preview.win, win_config)
    else
      disabled_preview.win = vim.api.nvim_open_win(disabled_preview.buf, false, win_config)
    end
    vim.wo[disabled_preview.win].conceallevel = 3
    vim.wo[disabled_preview.win].cursorline = false
    vim.wo[disabled_preview.win].fillchars = "eob: "
    vim.wo[disabled_preview.win].foldenable = false
    vim.wo[disabled_preview.win].number = false
    vim.wo[disabled_preview.win].relativenumber = false
    vim.wo[disabled_preview.win].signcolumn = "no"
    vim.wo[disabled_preview.win].wrap = false
    vim.wo[disabled_preview.win].winhighlight = table.concat({
      "NormalFloat:MiniFilesNormal",
      "FloatBorder:MiniFilesBorder",
      "FloatTitle:MiniFilesTitle",
    }, ",")
  end
  local function sync_preview()
    local ok, entry = pcall(mini_files.get_fs_entry)
    if not ok or not entry then
      return
    end
    if is_preview_blocked_file(entry) then
      show_disabled_preview(entry)
    else
      close_disabled_preview()
    end
  end
  local function with_preview_guard(action)
    return function()
      close_disabled_preview()
      action()
      sync_preview()
    end
  end
  local function repeat_count(action)
    for _ = 1, vim.v.count1 do
      action()
    end
  end
  local function map(buf_id, lhs, rhs, desc)
    if not lhs or lhs == "" then
      return
    end
    vim.keymap.set("n", lhs, rhs, {
      buffer = buf_id,
      desc = desc,
      noremap = true,
      nowait = true,
      silent = true,
    })
  end
  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "MiniFilesExplorerOpen",
    callback = function()
      enable_fs_open_guard()
      vim.schedule(sync_preview)
    end,
  })
  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "MiniFilesExplorerClose",
    callback = function()
      close_disabled_preview()
      if not opening then
        disable_fs_open_guard()
      end
    end,
  })
  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "MiniFilesWindowUpdate",
    callback = function()
      vim.schedule(sync_preview)
    end,
  })
  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "MiniFilesWindowOpen",
    callback = function(args)
      local win_id = args.data and args.data.win_id
      if win_id and vim.api.nvim_win_is_valid(win_id) then
        vim.wo[win_id].spell = false
      end
    end,
  })
  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "MiniFilesBufferCreate",
    callback = function(args)
      local buf_id = args.data and args.data.buf_id
      if not buf_id then
        return
      end
      vim.api.nvim_create_autocmd("CursorMoved", {
        group = group,
        buffer = buf_id,
        callback = function()
          vim.schedule(sync_preview)
        end,
      })
      local mappings = opts.mappings or {}
      map(
        buf_id,
        mappings.go_in,
        with_preview_guard(function()
          repeat_count(function()
            mini_files.go_in()
          end)
        end),
        "Go in entry"
      )
      map(
        buf_id,
        mappings.go_in_plus,
        with_preview_guard(function()
          repeat_count(function()
            mini_files.go_in({ close_on_file = true })
          end)
        end),
        "Go in entry plus"
      )
      map(
        buf_id,
        mappings.go_out,
        with_preview_guard(function()
          repeat_count(function()
            mini_files.go_out()
          end)
        end),
        "Go out of directory"
      )
      map(
        buf_id,
        mappings.go_out_plus,
        with_preview_guard(function()
          repeat_count(function()
            mini_files.go_out()
          end)
          mini_files.trim_right()
        end),
        "Go out of directory plus"
      )
      map(buf_id, mappings.reset, with_preview_guard(mini_files.reset), "Reset")
      map(buf_id, mappings.reveal_cwd, with_preview_guard(mini_files.reveal_cwd), "Reveal cwd")
      map(buf_id, mappings.synchronize, with_preview_guard(mini_files.synchronize), "Synchronize")
      map(buf_id, mappings.trim_left, with_preview_guard(mini_files.trim_left), "Trim branch left")
      map(buf_id, mappings.trim_right, with_preview_guard(mini_files.trim_right), "Trim branch right")
    end,
  })
  if not mini_files._linkarzu_preview_blocklist_open_wrapped then
    local original_open = mini_files.open
    mini_files.open = function(...)
      opening = true
      enable_fs_open_guard()
      local results = { pcall(original_open, ...) }
      opening = false
      if not results[1] then
        disable_fs_open_guard()
        error(results[2], 0)
      end
      table.remove(results, 1)
      return unpack(results)
    end
    mini_files._linkarzu_preview_blocklist_open_wrapped = true
  end
end

return {
  "nvim-mini/mini.files",
  opts = function(_, opts)
    -- I didn't like the default mappings, so I modified them
    -- Module mappings created only inside explorer.
    -- Use `''` (empty string) to not create one.
    opts.mappings = vim.tbl_deep_extend("force", opts.mappings or {}, {
      close = "<esc>",
      -- Use this if you want to open several files
      go_in = "l",
      -- This opens the file, but quits out of mini.files (default L)
      go_in_plus = "<CR>",
      -- I swapped the following 2 (default go_out: h)
      -- go_out_plus: when you go out, it shows you only 1 item to the right
      -- go_out: shows you all the items to the right
      go_out = "H",
      go_out_plus = "h",
      -- Default <BS>
      reset = "<BS>",
      -- Default @
      reveal_cwd = ".",
      show_help = "g?",
      -- Default =
      synchronize = "s",
      trim_left = "<",
      trim_right = ">",

      -- Below I created an autocmd with the "," keymap to open the highlighted
      -- directory in a tmux pane on the right
    })

    -- Here I define my custom keymaps in a centralized place
    opts.custom_keymaps = {
      open_tmux_pane = "<M-t>",
      copy_to_clipboard = "<space>Y",
      zip_and_copy = "<space>yz",
      paste_from_clipboard = "<space>p",
      copy_path = "<M-c>",
      open_with_default_app = "O",
      -- Don't use "i" as it conflicts wit insert mode
      preview_image = "<space>i",
      preview_image_popup = "<M-i>",
    }

    opts.windows = vim.tbl_deep_extend("force", opts.windows or {}, {
      preview = true,
      width_focus = 20,
      width_preview = 53,
    })

    opts.options = vim.tbl_deep_extend("force", opts.options or {}, {
      -- Whether to use for editing directories
      -- Disabled by default in LazyVim because neo-tree is used for that
      use_as_default_explorer = true,
      -- If set to false, files are moved to the trash directory
      -- To get this dir run :echo stdpath('data')
      -- ~/.local/share/neobean/mini.files/trash
      permanent_delete = false,
      -- markdown-oxide v0.25.10 advertises file-operation filters with
      -- `scheme = null`; Neovim decodes that as vim.NIL and mini.files crashes
      -- while checking the scheme during synchronize().
      lsp_timeout = 0,
    })
    return opts
  end,

  keys = {
    {
      -- Open the directory of the file currently being edited
      -- If the file doesn't exist because you maybe switched to a new git branch
      -- open the current working directory
      "<leader>e",
      function()
        local buf_name = vim.api.nvim_buf_get_name(0)
        local dir_name = vim.fn.fnamemodify(buf_name, ":p:h")
        if vim.fn.filereadable(buf_name) == 1 then
          -- Pass the full file path to highlight the file
          require("mini.files").open(buf_name, true)
        elseif vim.fn.isdirectory(dir_name) == 1 then
          -- If the directory exists but the file doesn't, open the directory
          require("mini.files").open(dir_name, true)
        else
          -- If neither exists, fallback to the current working directory
          require("mini.files").open(vim.uv.cwd(), true)
        end
      end,
      desc = "Open mini.files (Directory of Current File or CWD if not exists)",
    },
    -- Open the current working directory
    {
      "<leader>E",
      function()
        require("mini.files").open(vim.uv.cwd(), true)
      end,
      desc = "Open mini.files (cwd)",
    },
  },

  config = function(_, opts)
    -- Set up mini.files
    require("mini.files").setup(opts)
    setup_conditional_preview(opts)
    -- Load custom keymaps
    mini_files_km.setup(opts)

    -- Load Git integration
    -- git config is slowing mini.files too much, so disabling it
    mini_files_git.setup()
  end,
}
