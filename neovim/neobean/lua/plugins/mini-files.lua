-- Filename: ~/github/dotfiles-latest/neovim/neobean/lua/plugins/mini-files.lua
-- ~/github/dotfiles-latest/neovim/neobean/lua/plugins/mini-files.lua
--
-- https://github.com/echasnovski/mini.files
--
-- I got this configuration from LazyVim.org
-- http://www.lazyvim.org/extras/editor/mini-files

return {
  "echasnovski/mini.files",
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

    opts.windows = vim.tbl_deep_extend("force", opts.windows or {}, {
      preview = true,
      width_focus = 30,
      width_preview = 50,
    })

    opts.options = vim.tbl_deep_extend("force", opts.options or {}, {
      -- Whether to use for editing directories
      -- Disabled by default in LazyVim because neo-tree is used for that
      use_as_default_explorer = true,
      -- If set to false, files are moved to the trash directory
      -- To get this dir run :echo stdpath('data')
      -- ~/.local/share/neobean/mini.files/trash
      permanent_delete = false,
    })
    return opts
  end,

  keys = {
    {
      "<leader>e",
      function()
        require("mini.files").open(vim.api.nvim_buf_get_name(0), true)
      end,
      desc = "Open mini.files (Directory of Current File)",
    },
    {
      "<leader>E",
      function()
        require("mini.files").open(vim.uv.cwd(), true)
      end,
      desc = "Open mini.files (cwd)",
    },
  },

  config = function(_, opts)
    require("mini.files").setup(opts)

    -- Create an autocmd to set buffer-local mappings when a `mini.files` buffer is opened
    -- I use this to open the highlighted directory in a tmux pane on the right
    -- I call the `tmux_pane_functiontmux_pane_function` I defined in my
    -- keympaps.lua file
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "minifiles",
      callback = function()
        -- Import 'mini.files' module
        local mini_files = require("mini.files")

        -- Set buffer-local mapping for ',' in normal mode
        vim.keymap.set("n", ",", function()
          -- Get the current entry using 'get_fs_entry()'
          local curr_entry = mini_files.get_fs_entry()
          if curr_entry and curr_entry.fs_type == "directory" then
            -- Call tmux pane function with the directory path
            require("config.keymaps").tmux_pane_function(curr_entry.path)
          else
            -- Notify if not a directory or no entry is selected
            vim.notify("Not a directory or no entry selected", vim.log.levels.WARN)
          end
        end, { buffer = true, noremap = true, silent = true })

        -- Copy the current file or directory to the lamw25wmal system clipboard
        -- NOTE: This works only on macOS
        vim.keymap.set("n", "yy", function()
          -- Get the current entry (file or directory)
          local curr_entry = mini_files.get_fs_entry()
          if curr_entry then
            local path = curr_entry.path
            -- Escape the path for shell command
            local escaped_path = vim.fn.fnameescape(path)
            -- Build the osascript command to copy the file or directory to the clipboard
            local cmd = string.format([[osascript -e 'set the clipboard to POSIX file "%s"' ]], escaped_path)
            local result = vim.fn.system(cmd)
            if vim.v.shell_error ~= 0 then
              vim.notify("Copy failed: " .. result, vim.log.levels.ERROR)
            else
              vim.notify(path, vim.log.levels.INFO)
              vim.notify("Copied to system clipboard", vim.log.levels.INFO)
            end
          else
            vim.notify("No file or directory selected", vim.log.levels.WARN)
          end
        end, { buffer = true, noremap = true, silent = true, desc = "Copy file/directory to clipboard" })

        vim.keymap.set("n", "yz", function()
          local curr_entry = require("mini.files").get_fs_entry()
          if curr_entry then
            local path = curr_entry.path
            local name = vim.fn.fnamemodify(path, ":t") -- Extract the file or directory name
            local parent_dir = vim.fn.fnamemodify(path, ":h") -- Get the parent directory
            local timestamp = os.date("%y%m%d%H%M%S") -- Append timestamp to avoid duplicates
            local zip_path = string.format("/tmp/%s_%s.zip", name, timestamp) -- Path in macOS's tmp directory
            -- Create the zip file
            local zip_cmd = string.format(
              "cd %s && zip -r %s %s",
              vim.fn.shellescape(parent_dir),
              vim.fn.shellescape(zip_path),
              vim.fn.shellescape(name)
            )
            local result = vim.fn.system(zip_cmd)
            if vim.v.shell_error ~= 0 then
              vim.notify("Failed to create zip file: " .. result, vim.log.levels.ERROR)
              return
            end
            -- Copy the zip file to the system clipboard
            local copy_cmd =
              string.format([[osascript -e 'set the clipboard to POSIX file "%s"' ]], vim.fn.fnameescape(zip_path))
            local copy_result = vim.fn.system(copy_cmd)
            if vim.v.shell_error ~= 0 then
              vim.notify("Failed to copy zip file to clipboard: " .. copy_result, vim.log.levels.ERROR)
              return
            end
            vim.notify(zip_path, vim.log.levels.INFO)
            vim.notify("Zipped and copied to clipboard: ", vim.log.levels.INFO)
          else
            vim.notify("No file or directory selected", vim.log.levels.WARN)
          end
        end, { buffer = true, noremap = true, silent = true, desc = "Zip and copy to clipboard" })

        -- Paste the current file or directory from the system clipboard into the current directory in mini.files
        -- NOTE: This works only on macOS
        vim.keymap.set("n", "P", function()
          vim.notify("Starting the paste operation...", vim.log.levels.INFO)
          if not mini_files then
            vim.notify("mini.files module not loaded.", vim.log.levels.ERROR)
            return
          end
          local curr_entry = mini_files.get_fs_entry() -- Get the current file system entry
          if not curr_entry then
            vim.notify("Failed to retrieve current entry in mini.files.", vim.log.levels.ERROR)
            return
          end
          local curr_dir = curr_entry.fs_type == "directory" and curr_entry.path
            or vim.fn.fnamemodify(curr_entry.path, ":h") -- Use parent directory if entry is a file
          vim.notify("Current directory: " .. curr_dir, vim.log.levels.INFO)
          local script = [[
            tell application "System Events"
              try
                set theFile to the clipboard as alias
                set posixPath to POSIX path of theFile
                return posixPath
              on error
                return "error"
              end try
            end tell
          ]]
          local output = vim.fn.system("osascript -e " .. vim.fn.shellescape(script)) -- Execute AppleScript command
          if vim.v.shell_error ~= 0 or output:find("error") then
            vim.notify("Clipboard does not contain a valid file or directory.", vim.log.levels.WARN)
            return
          end
          local source_path = output:gsub("%s+$", "") -- Trim whitespace from clipboard output
          if source_path == "" then
            vim.notify("Clipboard is empty or invalid.", vim.log.levels.WARN)
            return
          end
          local dest_path = curr_dir .. "/" .. vim.fn.fnamemodify(source_path, ":t") -- Destination path in current directory
          local copy_cmd = vim.fn.isdirectory(source_path) == 1 and { "cp", "-R", source_path, dest_path }
            or { "cp", source_path, dest_path } -- Construct copy command
          local result = vim.fn.system(copy_cmd) -- Execute the copy command
          if vim.v.shell_error ~= 0 then
            vim.notify("Paste operation failed: " .. result, vim.log.levels.ERROR)
            return
          end
          vim.notify("Pasted " .. source_path .. " to " .. dest_path, vim.log.levels.INFO)
          mini_files.synchronize() -- Refresh mini.files to show updated directory content
          vim.notify("Paste operation completed successfully.", vim.log.levels.INFO)
        end, { buffer = true, noremap = true, silent = true, desc = "Paste from clipboard" })
      end,
    })

    ---------------------------------------------------------------------------
    ---------------------------------------------------------------------------

    -- -- All of the section below is to show the git status on files found here
    -- -- https://www.reddit.com/r/neovim/comments/1c37m7c/is_there_a_way_to_get_the_minifiles_plugin_to/
    -- -- Which points to
    -- -- https://gist.github.com/bassamsdata/eec0a3065152226581f8d4244cce9051#file-notes-md
    local nsMiniFiles = vim.api.nvim_create_namespace("mini_files_git")
    local autocmd = vim.api.nvim_create_autocmd
    local _, MiniFiles = pcall(require, "mini.files")

    -- Cache for git status
    local gitStatusCache = {}
    local cacheTimeout = 2000 -- Cache timeout in milliseconds

    local function isSymlink(path)
      local stat = vim.loop.fs_lstat(path)
      return stat and stat.type == "link"
    end

    ---@type table<string, {symbol: string, hlGroup: string}>
    ---@param status string
    ---@return string symbol, string hlGroup
    local function mapSymbols(status, is_symlink)
      local statusMap = {
    -- stylua: ignore start 
        [" M"] = { symbol = "✹", hlGroup  = "MiniDiffSignChange"}, -- Modified in the working directory
        ["M "] = { symbol = "•", hlGroup  = "MiniDiffSignChange"}, -- modified in index
        ["MM"] = { symbol = "≠", hlGroup  = "MiniDiffSignChange"}, -- modified in both working tree and index
        ["A "] = { symbol = "+", hlGroup  = "MiniDiffSignAdd"   }, -- Added to the staging area, new file
        ["AA"] = { symbol = "≈", hlGroup  = "MiniDiffSignAdd"   }, -- file is added in both working tree and index
        ["D "] = { symbol = "-", hlGroup  = "MiniDiffSignDelete"}, -- Deleted from the staging area
        ["AM"] = { symbol = "⊕", hlGroup  = "MiniDiffSignChange"}, -- added in working tree, modified in index
        ["AD"] = { symbol = "-•", hlGroup = "MiniDiffSignChange"}, -- Added in the index and deleted in the working directory
        ["R "] = { symbol = "→", hlGroup  = "MiniDiffSignChange"}, -- Renamed in the index
        ["U "] = { symbol = "‖", hlGroup  = "MiniDiffSignChange"}, -- Unmerged path
        ["UU"] = { symbol = "⇄", hlGroup  = "MiniDiffSignAdd"   }, -- file is unmerged
        ["UA"] = { symbol = "⊕", hlGroup  = "MiniDiffSignAdd"   }, -- file is unmerged and added in working tree
        ["??"] = { symbol = "?", hlGroup  = "MiniDiffSignDelete"}, -- Untracked files
        ["!!"] = { symbol = "!", hlGroup  = "MiniDiffSignChange"}, -- Ignored files
        -- stylua: ignore end
      }

      local result = statusMap[status] or { symbol = "?", hlGroup = "NonText" }
      local gitSymbol = result.symbol
      local gitHlGroup = result.hlGroup

      local symlinkSymbol = is_symlink and "↩" or ""

      -- Combine symlink symbol with Git status if both exist
      local combinedSymbol = (symlinkSymbol .. gitSymbol):gsub("^%s+", ""):gsub("%s+$", "")
      -- Change the color of the symlink icon from "MiniDiffSignDelete" to something else
      local combinedHlGroup = is_symlink and "MiniDiffSignDelete" or gitHlGroup

      return combinedSymbol, combinedHlGroup
    end

    ---@param cwd string
    ---@param callback function
    ---@return nil
    local function fetchGitStatus(cwd, callback)
      local function on_exit(content)
        if content.code == 0 then
          callback(content.stdout)
          vim.g.content = content.stdout
        end
      end
      vim.system({ "git", "status", "--ignored", "--porcelain" }, { text = true, cwd = cwd }, on_exit)
    end

    ---@param str string|nil
    ---@return string
    local function escapePattern(str)
      if not str then
        return ""
      end
      return (str:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1"))
    end

    ---@param buf_id integer
    ---@param gitStatusMap table
    ---@return nil
    local function updateMiniWithGit(buf_id, gitStatusMap)
      vim.schedule(function()
        local nlines = vim.api.nvim_buf_line_count(buf_id)
        local cwd = vim.fs.root(buf_id, ".git")
        local escapedcwd = escapePattern(cwd)
        if vim.fn.has("win32") == 1 then
          escapedcwd = escapedcwd:gsub("\\", "/")
        end

        for i = 1, nlines do
          local entry = MiniFiles.get_fs_entry(buf_id, i)
          if not entry then
            break
          end
          local relativePath = entry.path:gsub("^" .. escapedcwd .. "/", "")
          local status = gitStatusMap[relativePath]

          if status then
            local is_symlink = isSymlink(entry.path)
            local symbol, hlGroup = mapSymbols(status, is_symlink)
            vim.api.nvim_buf_set_extmark(buf_id, nsMiniFiles, i - 1, 0, {
              -- NOTE: if you want the signs on the right uncomment those and comment
              -- the 3 lines after
              -- virt_text = { { symbol, hlGroup } },
              -- virt_text_pos = "right_align",
              sign_text = symbol,
              sign_hl_group = hlGroup,
              priority = 2,
            })
          else
          end
        end
      end)
    end

    -- Thanks for the idea of gettings https://github.com/refractalize/oil-git-status.nvim signs for dirs
    ---@param content string
    ---@return table
    local function parseGitStatus(content)
      local gitStatusMap = {}
      -- lua match is faster than vim.split (in my experience )
      for line in content:gmatch("[^\r\n]+") do
        local status, filePath = string.match(line, "^(..)%s+(.*)")
        -- Split the file path into parts
        local parts = {}
        for part in filePath:gmatch("[^/]+") do
          table.insert(parts, part)
        end
        -- Start with the root directory
        local currentKey = ""
        for i, part in ipairs(parts) do
          if i > 1 then
            -- Concatenate parts with a separator to create a unique key
            currentKey = currentKey .. "/" .. part
          else
            currentKey = part
          end
          -- If it's the last part, it's a file, so add it with its status
          if i == #parts then
            gitStatusMap[currentKey] = status
          else
            -- If it's not the last part, it's a directory. Check if it exists, if not, add it.
            if not gitStatusMap[currentKey] then
              gitStatusMap[currentKey] = status
            end
          end
        end
      end
      return gitStatusMap
    end

    ---@param buf_id integer
    ---@return nil
    local function updateGitStatus(buf_id)
      local cwd = vim.uv.cwd()
      if not cwd or not vim.fs.root(cwd, ".git") then
        return
      end

      local currentTime = os.time()
      if gitStatusCache[cwd] and currentTime - gitStatusCache[cwd].time < cacheTimeout then
        updateMiniWithGit(buf_id, gitStatusCache[cwd].statusMap)
      else
        fetchGitStatus(cwd, function(content)
          local gitStatusMap = parseGitStatus(content)
          gitStatusCache[cwd] = {
            time = currentTime,
            statusMap = gitStatusMap,
          }
          updateMiniWithGit(buf_id, gitStatusMap)
        end)
      end
    end

    ---@return nil
    local function clearCache()
      gitStatusCache = {}
    end

    local function augroup(name)
      return vim.api.nvim_create_augroup("MiniFiles_" .. name, { clear = true })
    end

    autocmd("User", {
      group = augroup("start"),
      pattern = "MiniFilesExplorerOpen",
      -- pattern = { "minifiles" },
      callback = function()
        local bufnr = vim.api.nvim_get_current_buf()
        updateGitStatus(bufnr)
      end,
    })

    autocmd("User", {
      group = augroup("close"),
      pattern = "MiniFilesExplorerClose",
      callback = function()
        clearCache()
      end,
    })

    autocmd("User", {
      group = augroup("update"),
      pattern = "MiniFilesBufferUpdate",
      callback = function(sii)
        local bufnr = sii.data.buf_id
        local cwd = vim.fn.expand("%:p:h")
        if gitStatusCache[cwd] then
          updateMiniWithGit(bufnr, gitStatusCache[cwd].statusMap)
        end
      end,
    })
  end,
}
