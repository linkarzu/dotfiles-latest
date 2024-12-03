-- Filename: ~/github/dotfiles-latest/neovim/neobean/lua/config/modules/mini-files-km.lua
-- ~/github/dotfiles-latest/neovim/neobean/lua/config/modules/mini-files-km.lua

local M = {}

M.setup = function(opts)
  -- Create an autocmd to set buffer-local mappings when a `mini.files` buffer is opened
  -- I use this to open the highlighted directory in a tmux pane on the right
  -- I call the `tmux_pane_functiontmux_pane_function` I defined in my
  -- keympaps.lua file
  vim.api.nvim_create_autocmd("User", {
    -- Updated pattern to match what Echasnovski has in the documentation
    -- https://github.com/echasnovski/mini.nvim/blob/c6eede272cfdb9b804e40dc43bb9bff53f38ed8a/doc/mini-files.txt#L508-L529
    pattern = "MiniFilesBufferCreate",
    callback = function(args)
      local buf_id = args.data.buf_id
      -- Import 'mini.files' module
      local mini_files = require("mini.files")
      -- Ensure opts.custom_keymaps exists
      local keymaps = opts.custom_keymaps or {}

      -- Open the highlighted directory in a tmux pane on the right
      vim.keymap.set("n", keymaps.open_tmux_pane, function()
        -- vim.keymap.set("n", ",", function()
        -- Get the current entry using 'get_fs_entry()'
        local curr_entry = mini_files.get_fs_entry()
        if curr_entry and curr_entry.fs_type == "directory" then
          -- Call tmux pane function with the directory path
          require("config.keymaps").tmux_pane_function(curr_entry.path)
        else
          -- Notify if not a directory or no entry is selected
          vim.notify("Not a directory or no entry selected", vim.log.levels.WARN)
        end
      end, { buffer = buf_id, noremap = true, silent = true })

      -- Copy the current file or directory to the lamw25wmal system clipboard
      -- NOTE: This works only on macOS
      vim.keymap.set("n", keymaps.copy_to_clipboard, function()
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
            vim.notify(vim.fn.fnamemodify(path, ":t"), vim.log.levels.INFO)
            vim.notify("Copied to system clipboard", vim.log.levels.INFO)
          end
        else
          vim.notify("No file or directory selected", vim.log.levels.WARN)
        end
      end, { buffer = buf_id, noremap = true, silent = true, desc = "Copy file/directory to clipboard" })

      -- ZIP current file or directory and copy to the system clipboard
      vim.keymap.set("n", keymaps.zip_and_copy, function()
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
      end, { buffer = buf_id, noremap = true, silent = true, desc = "Zip and copy to clipboard" })

      -- Paste the current file or directory from the system clipboard into the current directory in mini.files
      -- NOTE: This works only on macOS
      vim.keymap.set("n", keymaps.paste_from_clipboard, function()
        -- vim.notify("Starting the paste operation...", vim.log.levels.INFO)
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
        -- vim.notify("Current directory: " .. curr_dir, vim.log.levels.INFO)
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
        -- vim.notify("Pasted " .. source_path .. " to " .. dest_path, vim.log.levels.INFO)
        mini_files.synchronize() -- Refresh mini.files to show updated directory content
        vim.notify("Pasted successfully.", vim.log.levels.INFO)
      end, { buffer = buf_id, noremap = true, silent = true, desc = "Paste from clipboard" })

      -- Copy the current file or directory path (relative to home) to clipboard
      vim.keymap.set("n", keymaps.copy_path, function()
        -- Get the current entry (file or directory)
        local curr_entry = mini_files.get_fs_entry()
        if curr_entry then
          -- Convert path to be relative to home directory
          local home_dir = vim.fn.expand("~")
          local relative_path = curr_entry.path:gsub("^" .. home_dir, "~")
          vim.fn.setreg("+", relative_path) -- Copy the relative path to the clipboard register
          vim.notify(vim.fn.fnamemodify(relative_path, ":t"), vim.log.levels.INFO)
          vim.notify("Path copied to clipboard: ", vim.log.levels.INFO)
        else
          vim.notify("No file or directory selected", vim.log.levels.WARN)
        end
      end, { buffer = buf_id, noremap = true, silent = true, desc = "Copy relative path to clipboard" })

      -- Preview the selected image in macOS Quick Look
      --
      -- NOTE: This is for macOS, to preview in a neovim popup see below
      --
      -- This wonderful Idea was suggested by @iduran in my youtube video:
      -- https://youtu.be/BzblG2eV8dU
      --
      -- Don't use "i" as it conflicts wit "insert"
      vim.keymap.set("n", keymaps.preview_image, function()
        local curr_entry = mini_files.get_fs_entry()
        if curr_entry then
          -- Preview the file using Quick Look
          vim.system({ "qlmanage", "-p", curr_entry.path }, {
            stdout = false,
            stderr = false,
          })
          -- Activate Quick Look window after a small delay
          vim.defer_fn(function()
            vim.system({ "osascript", "-e", 'tell application "qlmanage" to activate' })
          end, 200)
        else
          vim.notify("No file selected", vim.log.levels.WARN)
        end
      end, { buffer = buf_id, noremap = true, silent = true, desc = "Preview with macOS Quick Look" })

      -- Preview the selected image in a neovim popup window
      vim.keymap.set("n", keymaps.preview_image_popup, function()
        -- Clear any existing images before rendering the new one
        require("image").clear()
        local curr_entry = mini_files.get_fs_entry()
        if curr_entry and curr_entry.fs_type == "file" then
          local ext = vim.fn.fnamemodify(curr_entry.path, ":e"):lower()
          local supported_image_exts = { "png", "jpg", "jpeg", "gif", "bmp", "webp", "avif" }
          -- Check if the file has a supported image extension
          if vim.tbl_contains(supported_image_exts, ext) then
            -- Save mini.files state (current path and focused entry)
            local current_dir = vim.fn.fnamemodify(curr_entry.path, ":h")
            local focused_entry = vim.fn.fnamemodify(curr_entry.path, ":t") -- Extract filename
            -- Create a floating window for the image preview
            local popup_width = math.floor(vim.o.columns * 0.6)
            local popup_height = math.floor(vim.o.lines * 0.6)
            local col = math.floor((vim.o.columns - popup_width) / 2)
            local row = math.floor((vim.o.lines - popup_height) / 2)
            local buf = vim.api.nvim_create_buf(false, true) -- Create a scratch buffer
            local win = vim.api.nvim_open_win(buf, true, {
              relative = "editor",
              row = row,
              col = col,
              width = popup_width,
              height = popup_height,
              style = "minimal",
              border = "rounded",
            })
            -- Declare img_width and img_height at the top
            local img_width, img_height
            -- Get image dimensions using ImageMagick's identify command
            local dimensions =
              vim.fn.systemlist(string.format("identify -format '%%w %%h' %s", vim.fn.shellescape(curr_entry.path)))
            if #dimensions > 0 then
              img_width, img_height = dimensions[1]:match("(%d+) (%d+)")
              img_width = tonumber(img_width)
              img_height = tonumber(img_height)
            end
            -- Calculate image display size while maintaining aspect ratio
            local display_width = popup_width
            local display_height = popup_height
            if img_width and img_height then
              local aspect_ratio = img_width / img_height
              if aspect_ratio > (popup_width / popup_height) then
                -- Image is wider than the popup window
                display_height = math.floor(popup_width / aspect_ratio)
              else
                -- Image is taller than the popup window
                display_width = math.floor(popup_height * aspect_ratio)
              end
            end
            -- Center the image within the popup window
            local image_x = math.floor((popup_width - display_width) / 2)
            local image_y = math.floor((popup_height - display_height) / 2)
            -- Use image.nvim to render the image
            local img = require("image").from_file(curr_entry.path, {
              id = curr_entry.path, -- Unique ID
              window = win, -- Bind the image to the popup window
              buffer = buf, -- Bind the image to the popup buffer
              x = image_x,
              y = image_y,
              width = display_width,
              height = display_height,
              with_virtual_padding = true,
            })
            -- Render the image
            if img ~= nil then
              img:render()
            end
            -- Use `stat` or `ls` to get the file size in bytes
            local file_size_bytes = ""
            if vim.fn.has("mac") == 1 or vim.fn.has("unix") == 1 then
              -- For macOS or Linux systems
              local handle = io.popen(
                "stat -f%z "
                  .. vim.fn.shellescape(curr_entry.path)
                  .. " || ls -l "
                  .. vim.fn.shellescape(curr_entry.path)
                  .. " | awk '{print $5}'"
              )
              if handle then
                file_size_bytes = handle:read("*a"):gsub("%s+$", "") -- Trim trailing whitespace
                handle:close()
              end
            else
              -- Fallback message if the command isn't available
              file_size_bytes = "0"
            end
            -- Convert the size to MB (if valid)
            local file_size_mb = tonumber(file_size_bytes) and tonumber(file_size_bytes) / (1024 * 1024) or 0
            local file_size_mb_str = string.format("%.2f", file_size_mb) -- Format to 2 decimal places as a string
            -- Add image information (filename, size, resolution)
            local image_info = {}
            table.insert(image_info, "Image File: " .. focused_entry) -- Add only the filename
            if tonumber(file_size_bytes) > 0 then
              table.insert(image_info, "Size: " .. file_size_mb_str .. " MB") -- Use the formatted string
            else
              table.insert(image_info, "Size: Unable to detect") -- Fallback if size isn't found
            end
            if img_width and img_height then
              table.insert(image_info, "Resolution: " .. img_width .. " x " .. img_height)
            else
              table.insert(image_info, "Resolution: Unable to detect")
            end
            -- Append the image information after the image
            local line_count = vim.api.nvim_buf_line_count(buf)
            vim.api.nvim_buf_set_lines(buf, line_count, -1, false, { "", "", "" }) -- Add 3 empty lines
            vim.api.nvim_buf_set_lines(buf, -1, -1, false, image_info)
            -- Keymap for closing the popup and reopening mini.files
            local function reopen_mini_files()
              if img ~= nil then
                img:clear()
              end
              vim.api.nvim_win_close(win, true)
              -- Reopen mini.files in the same directory
              require("mini.files").open(current_dir, true)
              vim.defer_fn(function()
                -- Simulate navigation to the file by searching for the line matching the file
                local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false) -- Get all lines in the buffer
                for i, line in ipairs(lines) do
                  if line:match(focused_entry) then
                    vim.api.nvim_win_set_cursor(0, { i, 0 }) -- Move cursor to the matching line
                    break
                  end
                end
              end, 50) -- Small delay to ensure mini.files is initialized
            end
            vim.keymap.set("n", "<esc>", reopen_mini_files, { buffer = buf, noremap = true, silent = true })
          else
            vim.notify("Not an image file.", vim.log.levels.WARN)
          end
        else
          vim.notify("No file selected or not a file.", vim.log.levels.WARN)
        end
      end, { buffer = buf_id, noremap = true, silent = true, desc = "Preview image in popup" })

      -- End of keymaps
    end,
  })
end

return M
