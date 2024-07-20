-- Filename: ~/github/dotfiles-latest/neovim/neobean/lua/config/keymaps.lua
-- ~/github/dotfiles-latest/neovim/neobean/lua/config/keymaps.lua

-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- -- Leaving this here as an example in case you want to delete default keymaps
-- -- delete default buffer navigation keymaps
-- vim.keymap.del("n", "<S-h>")
-- vim.keymap.del("n", "<S-l>")

-- I don't want to switch between buffers anymore, instead I'll use BufExplorer
-- For this to work, make sure you have the plugin installed
vim.keymap.set("n", "<S-h>", "<cmd>BufExplorer<cr>", { desc = "[P]Open bufexplorer" })
vim.keymap.set("n", "<S-l>", "<cmd>BufExplorer<cr>", { desc = "[P]Open bufexplorer" })

-- -- use kj to exit insert mode
-- -- I auto save with
-- --  ~/github/dotfiles-latest/neovim/neobean/lua/plugins/auto-save.lua
vim.keymap.set("i", "kj", "<ESC>", { desc = "[P]Exit insert mode with kj" })

-- -- An alternative way of saving (autosave)
-- -- Auto saving when exiting insert mode with `kj`
-- -- Disabling this because switched over to
-- --  ~/github/dotfiles-latest/neovim/neobean/lua/plugins/auto-save.lua
-- -- And it works :muacks:, beautifully
-- vim.keymap.set("i", "kj", function()
--   -- "Write" saves regardless of whether the buffer has been modified or not
--   -- vim.cmd("write")
--   -- "Update" saves only if the buffer has been modified since the last save
--   -- Suggested in reddit by user @SeoCamo
--   vim.cmd("update")
--   -- Move to the right
--   vim.cmd("normal l")
--   -- Switch back to command mode after saving
--   vim.cmd("stopinsert")
--   -- Print the "File saved" message and the file path
--   -- print("FILE SAVED: " .. vim.fn.expand("%:p"))
-- end, { desc = "[P]Write current file and exit insert mode" })

-- use gh to move to the beginning of the line in normal mode
-- use gl to move to the end of the line in normal mode
vim.keymap.set({ "n", "v" }, "gh", "^", { desc = "[P]Go to the beginning line" })
vim.keymap.set({ "n", "v" }, "gl", "$", { desc = "[P]go to the end of the line" })
-- In visual mode, after going to the end of the line, come back 1 character
vim.keymap.set("v", "gl", "$h", { desc = "[P]Go to the end of the line" })

-- yank selected text into system clipboard
-- Vim/Neovim has two clipboards: unnamed register (default) and system clipboard.
--
-- Yanking with `y` goes to the unnamed register, accessible only within Vim.
-- The system clipboard allows sharing data between Vim and other applications.
-- Yanking with `"+y` copies text to both the unnamed register and system clipboard.
-- The `"+` register represents the system clipboard.
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]], { desc = "[P]Yank to system clipboard" })

-- yank/copy to end of line
vim.keymap.set("n", "Y", "y$", { desc = "[P]Yank to end of line" })

-- Disabled this because I use these keymaps to navigate markdown headers
-- Ctrl+d and u are used to move up or down a half screen
-- but I don't like to use ctrl, so enabled this as well, both options work
-- zz makes the cursor to stay in the middle
-- If you want to return back to ctrl+d and ctrl+u
-- vim.keymap.set("n", "gk", "<C-u>zz", { desc = "[P]Go up a half screen" })
-- vim.keymap.set("n", "gj", "<C-d>zz", { desc = "[P]Go down a half screen" })

-- When jumping with ctrl+d and u the cursors stays in the middle
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<c-u>", "<c-u>zz")

-- Move lines up and down in visual mode
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "[P]Move line down in visual mode" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "[P]Move line up in visual mode" })

-- When you do joins with J it will keep your cursor at the beginning instead of at the end
vim.keymap.set("n", "J", "mzJ`z")

-- When searching for stuff, search results show in the middle
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Replaces the word I'm currently on, opens a terminal so that I start typing the new word
-- It replaces the word globally across the entire file
vim.keymap.set(
  "n",
  "<leader>su",
  [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
  { desc = "[P]Replace word I'm currently on GLOBALLY" }
)

-- Replaces the current word with the same word in uppercase, globally
vim.keymap.set(
  "n",
  "<leader>sU",
  [[:%s/\<<C-r><C-w>\>/<C-r>=toupper(expand('<cword>'))<CR>/gI<Left><Left><Left>]],
  { desc = "[P]GLOBALLY replace word I'm on with UPPERCASE" }
)

-- Replaces the current word with the same word in lowercase, globally
vim.keymap.set(
  "n",
  "<leader>sL",
  [[:%s/\<<C-r><C-w>\>/<C-r>=tolower(expand('<cword>'))<CR>/gI<Left><Left><Left>]],
  { desc = "[P]GLOBALLY replace word I'm on with lowercase" }
)

-- Quickly alternate between the last 2 files
-- LazyVim comes with the default shortcut <leader>bb for this, but I navigate
-- between alternate files way too often, so doing leader<space> is more useful for me
--
-- By default, in LazyVim, With leader<space> you usually find files in the root directory
--
-- I tried disabling leader<space> in telescope.lua and setting it in this file but didn't work
-- So I set the command to alternate between files directly in the `telescope.lua` file
--
-- With `:help registers` you can see the register below
-- Alternate buffer register "#
-- The command to switch is `:e #`
-- `:e` is used to `edit-a-file`, see `help :e`

-- Make the file you run the command on, executable, so you don't have to go out to the command line
-- Had to include quotes around "%" because there are some apple dirs that contain spaces, like iCloud
vim.keymap.set("n", "<leader>fx", '<cmd>!chmod +x "%"<CR>', { silent = true, desc = "Make file executable" })
-- vim.keymap.set("n", "<leader>fx", "<cmd>!chmod +x %<CR>", { silent = true, desc = "Make file executable" })
vim.keymap.set("n", "<leader>fX", '<cmd>!chmod -x "%"<CR>', { silent = true, desc = "Remove executable flag" })
-- vim.keymap.set("n", "<leader>fX", "<cmd>!chmod -x %<CR>", { silent = true, desc = "Remove executable flag" })

-- If this is a bash script, make it executable, and execute it in a tmux pane on the right
-- Using a tmux pane allows me to easily select text
-- Had to include quotes around "%" because there are some apple dirs that contain spaces, like iCloud
vim.keymap.set("n", "<leader>cb", function()
  local file = vim.fn.expand("%") -- Get the current file name
  local first_line = vim.fn.getline(1) -- Get the first line of the file
  if string.match(first_line, "^#!/") then -- If first line contains shebang
    local escaped_file = vim.fn.shellescape(file) -- Properly escape the file name for shell commands

    -- Execute the script on a tmux pane on the right. On my mac I use zsh, so
    -- running this script with bash to not execute my zshrc file after
    -- vim.cmd("silent !tmux split-window -h -l 60 'bash -c \"" .. escaped_file .. "; exec bash\"'")
    -- `-l 60` specifies the size of the tmux pane, in this case 60 columns
    vim.cmd(
      "silent !tmux split-window -h -l 60 'bash -c \""
        .. escaped_file
        .. "; echo; echo Press any key to exit...; read -n 1; exit\"'"
    )
  else
    vim.cmd("echo 'Not a script. Shebang line not found.'")
  end
end, { desc = "[P]BASH, execute file" })

-- -- If this is a bash script, make it executable, and execute it in a split pane on the right
-- -- Had to include quotes around "%" because there are some apple dirs that contain spaces, like iCloud
-- vim.keymap.set("n", "<leader>cb", function()
--   local file = vim.fn.expand("%") -- Get the current file name
--   local first_line = vim.fn.getline(1) -- Get the first line of the file
--   if string.match(first_line, "^#!/") then -- If first line contains shebang
--     local escaped_file = vim.fn.shellescape(file) -- Properly escape the file name for shell commands
--     vim.cmd("!chmod +x " .. escaped_file) -- Make the file executable
--     vim.cmd("vsplit") -- Split the window vertically
--     vim.cmd("terminal " .. escaped_file) -- Open terminal and execute the file
--     vim.cmd("startinsert") -- Enter insert mode, recommended by echasnovski on Reddit
--   else
--     vim.cmd("echo 'Not a script. Shebang line not found.'")
--   end
-- end, { desc = "[P]Execute bash script in pane on the right" })

-- If this is a .go file, execute it in a tmux pane on the right
-- Using a tmux pane allows me to easily select text
-- Had to include quotes around "%" because there are some apple dirs that contain spaces, like iCloud
vim.keymap.set("n", "<leader>cg", function()
  local file = vim.fn.expand("%") -- Get the current file name
  if string.match(file, "%.go$") then -- Check if the file is a .go file
    local file_dir = vim.fn.expand("%:p:h") -- Get the directory of the current file
    -- local escaped_file = vim.fn.shellescape(file) -- Properly escape the file name for shell commands
    -- local command_to_run = "go run " .. escaped_file
    local command_to_run = "go run *.go"
    -- `-l 60` specifies the size of the tmux pane, in this case 60 columns
    local cmd = "silent !tmux split-window -h -l 60 'cd "
      .. file_dir
      .. ' && echo "'
      .. command_to_run
      .. '\\n" && bash -c "'
      .. command_to_run
      .. "; echo; echo Press enter to exit...; read _\"'"
    vim.cmd(cmd)
  else
    vim.cmd("echo 'Not a Go file.'") -- Notify the user if the file is not a Go file
  end
end, { desc = "[P]GOLANG, execute file" })

-- -- If this is a .go file, execute it in a split pane on the right
-- -- Had to include quotes around "%" because there are some apple dirs that contain spaces, like iCloud
-- vim.keymap.set("n", "<leader>cg", function()
--   local file = vim.fn.expand("%") -- Get the current file name
--   if string.match(file, "%.go$") then -- Check if the file is a .go file
--     local escaped_file = vim.fn.shellescape(file) -- Properly escape the file name for shell commands
--     vim.cmd("split") -- Split the window vertically
--     vim.cmd("terminal go run " .. escaped_file) -- Run the file in a terminal pane
--     vim.cmd("startinsert") -- Enter insert mode in the terminal
--   else
--     vim.cmd("echo 'Not a Go file.'") -- Notify the user if the file is not a Go file
--   end
-- end, { desc = "[P]Execute Go file in pane on the right" })

-- Toggle a tmux pane on the right in bash, in the same directory as the current file
-- Opening it in bash because it's faster, I don't have to run my .zshrc file,
-- which pulls from my repo and a lot of other stuff
vim.keymap.set("n", "<leader>f.", function()
  local file_dir = vim.fn.expand("%:p:h") -- Get the directory of the current file
  local pane_width = 60
  local right_pane_id =
    vim.fn.system("tmux list-panes -F '#{pane_id} #{pane_width}' | awk '$2 == " .. pane_width .. " {print $1}'")

  if right_pane_id ~= "" then
    -- If the right pane exists, close it
    vim.fn.system("tmux kill-pane -t " .. right_pane_id)
  else
    -- If the right pane doesn't exist, open it
    vim.fn.system("tmux split-window -h -l " .. pane_width .. " 'cd " .. file_dir .. " && bash'")
  end
end, { desc = "[P]Open (toggle) current dir in right tmux pane" })

-- -- Open a tmux pane on the right in bash, in the same directory as the current file
-- -- Opening it in bash because it's faster, I don't have to run my .zshrc file,
-- -- which pulls from my repo and a lot of other stuff
-- vim.keymap.set("n", "<leader>f.", function()
--   local file_dir = vim.fn.expand("%:p:h") -- Get the directory of the current file
--   -- `-l 60` specifies the size of the tmux pane, in this case 60 columns
--   local cmd = "silent !tmux split-window -h -l 60 'cd " .. file_dir .. " && bash'"
--   vim.cmd(cmd)
-- end, { desc = "[P]Open current dir in right tmux pane" })

-- This will add 3 lines:
-- 1. File path with the wordname Filename: first, then the path, and Go project name
-- 2. Just the filepath
-- 3. Name that I will use with `go mod init`
vim.keymap.set({ "n", "v", "i" }, "<C-z>", function()
  local filePath = vim.fn.expand("%:~") -- Gets the file path relative to the home directory
  local fileName = vim.fn.expand("%:t") -- Gets the name of the file
  local goProjectPath = filePath:gsub("^~/", ""):gsub("/[^/]+$", "") -- Removes the ~/ at the start and the filename at the end
  -- Add .com to github and insert username
  goProjectPath = goProjectPath:gsub("github", "github.com/linkarzu")
  -- Add "go mod init" to the beginning
  goProjectPath = "go mod init " .. goProjectPath
  local lineToInsert = "Filename: " .. filePath
  local row, _ = unpack(vim.api.nvim_win_get_cursor(0)) -- Get the current row number
  -- Insert line with 'Filename: ' and insert blank lines right after
  vim.api.nvim_buf_set_lines(0, row - 1, row - 0, false, { lineToInsert })
  vim.api.nvim_buf_set_lines(0, row, row, false, { "" }) -- blank line
  vim.api.nvim_buf_set_lines(0, row, row, false, { "" }) -- blank line
  vim.api.nvim_buf_set_lines(0, row, row, false, { "" }) -- blank line
  -- Insert second line with just the path
  vim.api.nvim_buf_set_lines(0, row, row + 1, false, { filePath })
  -- Check if the file is a main.go file
  if fileName == "main.go" then
    -- Insert third line with the Go project name
    vim.api.nvim_buf_set_lines(0, row + 1, row + 2, false, { goProjectPath })
    vim.cmd("normal! V2j")
    vim.cmd("normal gcc")
  else
    vim.cmd("normal! V1j")
    vim.cmd("normal gcc")
  end
end, { desc = "[P]Insert filename with path and go project name at cursor" })

-- -- Paste file path by itself
-- vim.keymap.set("n", "<leader>fp", function()
--   local filePath = vim.fn.expand("%:~") -- Gets the file path relative to the home directory
--   local lineToInsert = filePath
--   local row, _ = unpack(vim.api.nvim_win_get_cursor(0)) -- Get the current row number
--   -- Insert line, leave cursor current position
--   vim.api.nvim_buf_set_lines(0, row - 1, row - 0, false, { lineToInsert })
--   -- Comment out the newly inserted line using the plugin's 'gcc' command
--   vim.cmd("normal gcc")
--   -- Insert a blank line below the current line
--   vim.api.nvim_buf_set_lines(0, row, row, false, { "" })
-- end, { desc = "[P]Insert filename with path at cursor" })

-- Copy file path / filepath to the clipboard
vim.keymap.set("n", "<leader>fp", function()
  local filePath = vim.fn.expand("%:~") -- Gets the file path relative to the home directory
  vim.fn.setreg("+", filePath) -- Copy the file path to the clipboard register
  print("File path copied to clipboard: " .. filePath) -- Optional: print message to confirm
end, { desc = "[P]Copy file path to clipboard" })

-- -- Paste file path with the wordname Filename: first
-- vim.keymap.set("n", "<leader>fz", function()
--   local filePath = vim.fn.expand("%:~") -- Gets the file path relative to the home directory
--   local lineToInsert = "Filename: " .. filePath
--   local row, _ = unpack(vim.api.nvim_win_get_cursor(0)) -- Get the current row number
--   -- Insert line, leave cursor current position
--   vim.api.nvim_buf_set_lines(0, row - 1, row - 0, false, { lineToInsert })
--   -- Comment out the newly inserted line using the plugin's 'gcc' command
--   vim.cmd("normal gcc")
--   -- Insert a blank line below the current line
--   vim.api.nvim_buf_set_lines(0, row, row, false, { "" })
-- end, { desc = "[P]Insert filename with path at cursor" })

-- I save a lot, and normally do it with `:w<CR>`, but I guess this will be
-- easier on my fingers
-- Original lazyvim.org keymap for this was "Other Window", but I never used it
vim.keymap.set("n", "<leader>ww", function()
  vim.cmd("write")
end, { desc = "[P]Write current file" })

-- ############################################################################

-- Set up a keymap to refresh the current buffer
vim.keymap.set("n", "<leader>br", function()
  -- Reloads the file to reflect the changes
  vim.cmd("edit!")
  print("Buffer reloaded")
end, { desc = "[P]Reload current buffer" })

-- ############################################################################
--                             Image section
-- ############################################################################

-- Paste images
-- I use a Ctrl keymap so that I can paste images in insert mode
-- I tried using <C-v> but duh, that's used for visual block mode
-- so don't do it
vim.keymap.set({ "n", "v", "i" }, "<C-a>", function()
  -- Call the paste_image function from the Lua API
  -- Using the plugin's Lua API (require("img-clip").paste_image()) instead of the
  -- PasteImage command because the Lua API returns a boolean value indicating
  -- whether an image was pasted successfully or not.
  -- The PasteImage command does not
  -- https://github.com/HakonHarnes/img-clip.nvim/blob/main/README.md#api
  local pasted_image = require("img-clip").paste_image()
  if pasted_image then
    -- "Update" saves only if the buffer has been modified since the last save
    vim.cmd("update")
    print("Image pasted and file saved")
    -- Only if updated I'll refresh the images by clearing them first
    -- I'm using [[ ]] to escape the special characters in a command
    vim.cmd([[lua require("image").clear()]])
    -- Reloads the file to reflect the changes
    vim.cmd("edit!")
    -- Switch back to command mode or normal mode
    vim.cmd("stopinsert")
  else
    print("No image pasted. File not updated.")
  end
end, { desc = "[P]Paste image from system clipboard" })

-- ############################################################################

-- Open image under cursor in the Preview app (macOS)
vim.keymap.set("n", "<leader>io", function()
  local function get_image_path()
    -- Get the current line
    local line = vim.api.nvim_get_current_line()
    -- Pattern to match image path in Markdown
    local image_pattern = "%[.-%]%((.-)%)"
    -- Extract relative image path
    local _, _, image_path = string.find(line, image_pattern)

    return image_path
  end

  -- Get the image path
  local image_path = get_image_path()

  if image_path then
    -- Check if the image path starts with "http" or "https"
    if string.sub(image_path, 1, 4) == "http" then
      print("URL image, use 'gx' to open it in the default browser.")
    else
      -- Construct absolute image path
      local current_file_path = vim.fn.expand("%:p:h")
      local absolute_image_path = current_file_path .. "/" .. image_path

      -- Construct command to open image in Preview
      local command = "open -a Preview " .. vim.fn.shellescape(absolute_image_path)
      -- Execute the command
      local success = os.execute(command)

      if success then
        print("Opened image in Preview: " .. absolute_image_path)
      else
        print("Failed to open image in Preview: " .. absolute_image_path)
      end
    end
  else
    print("No image found under the cursor")
  end
end, { desc = "[P](macOS) Open image under cursor in Preview" })

-- ############################################################################

-- Open image under cursor in Finder (macOS)
--
-- THIS ONLY WORKS IF YOU'RE NNNNNOOOOOOTTTTT USING ABSOLUTE PATHS,
-- BUT INSTEAD YOURE USING RELATIVE PATHS
--
-- If using absolute paths, use the default `gx` to open the image instead
vim.keymap.set("n", "<leader>if", function()
  local function get_image_path()
    -- Get the current line
    local line = vim.api.nvim_get_current_line()
    -- Pattern to match image path in Markdown
    local image_pattern = "%[.-%]%((.-)%)"
    -- Extract relative image path
    local _, _, image_path = string.find(line, image_pattern)

    return image_path
  end

  -- Get the image path
  local image_path = get_image_path()

  if image_path then
    -- Check if the image path starts with "http" or "https"
    if string.sub(image_path, 1, 4) == "http" then
      print("URL image, use 'gx' to open it in the default browser.")
    else
      -- Construct absolute image path
      local current_file_path = vim.fn.expand("%:p:h")
      local absolute_image_path = current_file_path .. "/" .. image_path

      -- Open the containing folder in Finder and select the image file
      local command = "open -R " .. vim.fn.shellescape(absolute_image_path)
      local success = vim.fn.system(command)

      if success == 0 then
        print("Opened image in Finder: " .. absolute_image_path)
      else
        print("Failed to open image in Finder: " .. absolute_image_path)
      end
    end
  else
    print("No image found under the cursor")
  end
end, { desc = "[P](macOS) Open image under cursor in Finder" })

-- ############################################################################

-- Delete image file under cursor using trash app (macOS)
vim.keymap.set("n", "<leader>id", function()
  local function get_image_path()
    -- Get the current line
    local line = vim.api.nvim_get_current_line()
    -- Pattern to match image path in Markdown
    local image_pattern = "%[.-%]%((.-)%)"
    -- Extract relative image path
    local _, _, image_path = string.find(line, image_pattern)

    return image_path
  end
  -- Get the image path
  local image_path = get_image_path()
  if image_path then
    -- Check if the image path starts with "http" or "https"
    if string.sub(image_path, 1, 4) == "http" then
      vim.api.nvim_echo({
        { "URL image cannot be deleted from disk.", "WarningMsg" },
      }, false, {})
    else
      -- Construct absolute image path
      local current_file_path = vim.fn.expand("%:p:h")
      local absolute_image_path = current_file_path .. "/" .. image_path
      -- Check if trash utility is installed
      if vim.fn.executable("trash") == 0 then
        vim.api.nvim_echo({
          { "- Trash utility not installed. Make sure to install it first\n", "ErrorMsg" },
          { "- In macOS run `brew install trash`\n", nil },
        }, false, {})
        return
      end
      -- Prompt for confirmation before deleting the image
      vim.ui.input({
        prompt = "Delete image file? (y/n) ",
      }, function(input)
        if input == "y" or input == "Y" then
          -- Delete the image file using trash app
          local success, _ = pcall(function()
            vim.fn.system({ "trash", vim.fn.fnameescape(absolute_image_path) })
          end)
          if success then
            vim.api.nvim_echo({
              { "Image file deleted from disk:\n", "Normal" },
              { absolute_image_path, "Normal" },
            }, false, {})
            -- I'll refresh the images, but will clear them first
            -- I'm using [[ ]] to escape the special characters in a command
            vim.cmd([[lua require("image").clear()]])
            -- Reloads the file to reflect the changes
            vim.cmd("edit!")
          else
            vim.api.nvim_echo({
              { "Failed to delete image file:\n", "ErrorMsg" },
              { absolute_image_path, "ErrorMsg" },
            }, false, {})
          end
        else
          vim.api.nvim_echo({
            { "Image deletion canceled.", "Normal" },
          }, false, {})
        end
      end)
    end
  else
    vim.api.nvim_echo({
      { "No image found under the cursor", "WarningMsg" },
    }, false, {})
  end
end, { desc = "[P](macOS) Delete image file under cursor" })

-- ############################################################################

-- Refresh the images in the current buffer
-- Useful if you delete an actual image file and want to see the changes
-- without having to re-open neovim
vim.keymap.set("n", "<leader>ir", function()
  -- First I clear the images
  -- I'm using [[ ]] to escape the special characters in a command
  vim.cmd([[lua require("image").clear()]])
  -- Reloads the file to reflect the changes
  vim.cmd("edit!")
  print("Images refreshed")
end, { desc = "[P]Refresh images" })

-- ############################################################################

-- Set up a keymap to clear all images in the current buffer
vim.keymap.set("n", "<leader>ic", function()
  -- This is the command that clears the images
  -- I'm using [[ ]] to escape the special characters in a command
  vim.cmd([[lua require("image").clear()]])
  print("Images cleared")
end, { desc = "[P]Clear images" })

-- ############################################################################
--                         Begin of markdown section
-- ############################################################################

-- When I press leader, I want to modify the name of the options shown
-- "m" is for "markdown" and "t" is for "todo"
-- https://github.com/folke/which-key.nvim?tab=readme-ov-file#%EF%B8%8F-mappings
local wk = require("which-key")
wk.register({
  ["<leader>"] = {
    m = {
      mode = { "v", "n" },
      name = "+[P]markdown",
      h = {
        -- <leader>mh
        name = "+[P]headings increase/decrease",
      },
      l = {
        -- <leader>ml
        name = "+[P]links",
      },
      s = {
        -- <leader>ms
        name = "+[P]spell",
      },
      f = {
        -- <leader>mf
        name = "+[P]fold",
      },
    },
    t = {
      -- <leader>t
      mode = { "n" },
      name = "+[P]todo",
    },
  },
})

-- In visual mode, delete all newlines within selected text
-- I like keeping my bulletpoints one after the next, sometimes formatting gets
-- in the way and they mess up, so this allows me to select all of them and just
-- delete newlines in between lamw25wmal
vim.keymap.set("v", "<leader>mj", function()
  -- Get the visual selection range
  local start_row = vim.fn.line("v")
  local end_row = vim.fn.line(".")
  -- Ensure start_row is less than or equal to end_row
  if start_row > end_row then
    start_row, end_row = end_row, start_row
  end
  -- Loop through each line in the selection
  local current_row = start_row
  while current_row <= end_row do
    local line = vim.api.nvim_buf_get_lines(0, current_row - 1, current_row, false)[1]
    -- vim.notify("Checking line " .. current_row .. ": " .. (line or ""), vim.log.levels.INFO)
    -- If the line is empty, delete it and adjust end_row
    if line == "" then
      vim.cmd(current_row .. "delete")
      end_row = end_row - 1
    else
      current_row = current_row + 1
    end
  end
end, { desc = "[P]Delete newlines in selected text (join)" })

-- Toggle bullet point at the beginning of the current line in normal mode
-- If in a multiline paragraph, make sure the cursor is on the line at the top
-- "d" is for "dash" lamw25wmal
vim.keymap.set("n", "<leader>md", function()
  -- Get the current cursor position
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local current_buffer = vim.api.nvim_get_current_buf()
  local start_row = cursor_pos[1] - 1
  local col = cursor_pos[2]
  -- Get the current line
  local line = vim.api.nvim_buf_get_lines(current_buffer, start_row, start_row + 1, false)[1]
  -- Check if the line already starts with a bullet point
  if line:match("^%s*%-") then
    -- Remove the bullet point from the start of the line
    line = line:gsub("^%s*%-", "")
    vim.api.nvim_buf_set_lines(current_buffer, start_row, start_row + 1, false, { line })
    return
  end
  -- Search for newline to the left of the cursor position
  local left_text = line:sub(1, col)
  local bullet_start = left_text:reverse():find("\n")
  if bullet_start then
    bullet_start = col - bullet_start
  end
  -- Search for newline to the right of the cursor position and in following lines
  local right_text = line:sub(col + 1)
  local bullet_end = right_text:find("\n")
  local end_row = start_row
  while not bullet_end and end_row < vim.api.nvim_buf_line_count(current_buffer) - 1 do
    end_row = end_row + 1
    local next_line = vim.api.nvim_buf_get_lines(current_buffer, end_row, end_row + 1, false)[1]
    if next_line == "" then
      break
    end
    right_text = right_text .. "\n" .. next_line
    bullet_end = right_text:find("\n")
  end
  if bullet_end then
    bullet_end = col + bullet_end
  end
  -- Extract lines
  local text_lines = vim.api.nvim_buf_get_lines(current_buffer, start_row, end_row + 1, false)
  local text = table.concat(text_lines, "\n")
  -- Add bullet point at the start of the text
  local new_text = "- " .. text
  local new_lines = vim.split(new_text, "\n")
  -- Set new lines in buffer
  vim.api.nvim_buf_set_lines(current_buffer, start_row, end_row + 1, false, new_lines)
end, { desc = "[P]Toggle bullet point (dash)" })

-- -- Toggle bullet point at the beginning of the current line in normal mode
-- vim.keymap.set("n", "<leader>ml", function()
--   -- Notify that the function is being executed
--   vim.notify("Executing bullet point toggle function", vim.log.levels.INFO)
--   -- Get the current cursor position
--   local cursor_pos = vim.api.nvim_win_get_cursor(0)
--   vim.notify("Cursor position: row " .. cursor_pos[1] .. ", col " .. cursor_pos[2], vim.log.levels.INFO)
--   local current_buffer = vim.api.nvim_get_current_buf()
--   local row = cursor_pos[1] - 1
--   -- Get the current line
--   local line = vim.api.nvim_buf_get_lines(current_buffer, row, row + 1, false)[1]
--   vim.notify("Current line: " .. line, vim.log.levels.INFO)
--   if line:match("^%s*%-") then
--     -- If the line already starts with a bullet point, remove it
--     vim.notify("Bullet point detected, removing it", vim.log.levels.INFO)
--     line = line:gsub("^%s*%-", "", 1)
--     vim.api.nvim_buf_set_lines(current_buffer, row, row + 1, false, { line })
--   else
--     -- Otherwise, delete the line, add a bullet point, and paste the text
--     vim.notify("No bullet point detected, adding it", vim.log.levels.INFO)
--     line = "- " .. line
--     vim.api.nvim_buf_set_lines(current_buffer, row, row + 1, false, { line })
--   end
-- end, { desc = "Toggle bullet point at the beginning of the current line" })

-- Show spelling suggestions / spell suggestions
vim.keymap.set("n", "<leader>mss", function()
  -- Simulate pressing "z=" with "m" option using feedkeys
  -- vim.api.nvim_replace_termcodes ensures "z=" is correctly interpreted
  -- 'm' is the {mode}, which in this case is 'Remap keys'. This is default.
  -- If {mode} is absent, keys are remapped.
  --
  -- I tried this keymap as usually with
  -- vim.cmd("normal! z=")
  -- But didn't work, only with nvim_feedkeys
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("z=", true, false, true), "m", true)
end, { desc = "[P]Spelling suggestions" })

-- markdown good, accept spell suggestion
-- Add word under the cursor as a good word
vim.keymap.set("n", "<leader>msg", function()
  vim.cmd("normal! zg")
end, { desc = "[P]Spelling add word to spellfile" })

-- Undo zw, remove the word from the entry in 'spellfile'.
vim.keymap.set("n", "<leader>msu", function()
  vim.cmd("normal! zug")
end, { desc = "[P]Spelling undo, remove word from list" })

-- Repeat the replacement done by |z=| for all matches with the replaced word
-- in the current window.
vim.keymap.set("n", "<leader>msr", function()
  -- vim.cmd(":spellr")
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(":spellr\n", true, false, true), "m", true)
end, { desc = "[P]Spelling repeat" })

-- In visual mode, check if the selected text is already bold and show a message if it is
-- If not, surround it with double asterisks for bold
vim.keymap.set("v", "<leader>mb", function()
  -- Get the selected text range
  local start_row, start_col = unpack(vim.fn.getpos("'<"), 2, 3)
  local end_row, end_col = unpack(vim.fn.getpos("'>"), 2, 3)
  -- Get the selected lines
  local lines = vim.api.nvim_buf_get_lines(0, start_row - 1, end_row, false)
  local selected_text = table.concat(lines, "\n"):sub(start_col, #lines == 1 and end_col or -1)
  if selected_text:match("^%*%*.*%*%*$") then
    vim.notify("Text already bold", vim.log.levels.INFO)
  else
    vim.cmd("normal 2gsa*")
  end
end, { desc = "[P]BOLD current selection" })

-- -- Multiline unbold attempt
-- -- In normal mode, bold the current word under the cursor
-- -- If already bold, it will unbold the word under the cursor
-- -- If you're in a multiline bold, it will unbold it only if you're on the
-- -- first line
vim.keymap.set("n", "<leader>mb", function()
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local current_buffer = vim.api.nvim_get_current_buf()
  local start_row = cursor_pos[1] - 1
  local col = cursor_pos[2]
  -- Get the current line
  local line = vim.api.nvim_buf_get_lines(current_buffer, start_row, start_row + 1, false)[1]
  -- Check if the cursor is on an asterisk
  if line:sub(col + 1, col + 1):match("%*") then
    vim.notify("Cursor is on an asterisk, run inside the bold text", vim.log.levels.WARN)
    return
  end
  -- Search for '**' to the left of the cursor position
  local left_text = line:sub(1, col)
  local bold_start = left_text:reverse():find("%*%*")
  if bold_start then
    bold_start = col - bold_start
  end
  -- Search for '**' to the right of the cursor position and in following lines
  local right_text = line:sub(col + 1)
  local bold_end = right_text:find("%*%*")
  local end_row = start_row
  while not bold_end and end_row < vim.api.nvim_buf_line_count(current_buffer) - 1 do
    end_row = end_row + 1
    local next_line = vim.api.nvim_buf_get_lines(current_buffer, end_row, end_row + 1, false)[1]
    if next_line == "" then
      break
    end
    right_text = right_text .. "\n" .. next_line
    bold_end = right_text:find("%*%*")
  end
  if bold_end then
    bold_end = col + bold_end
  end
  -- Remove '**' markers if found, otherwise bold the word
  if bold_start and bold_end then
    -- Extract lines
    local text_lines = vim.api.nvim_buf_get_lines(current_buffer, start_row, end_row + 1, false)
    local text = table.concat(text_lines, "\n")
    -- Calculate positions to correctly remove '**'
    -- vim.notify("bold_start: " .. bold_start .. ", bold_end: " .. bold_end)
    local new_text = text:sub(1, bold_start - 1) .. text:sub(bold_start + 2, bold_end - 1) .. text:sub(bold_end + 2)
    local new_lines = vim.split(new_text, "\n")
    -- Set new lines in buffer
    vim.api.nvim_buf_set_lines(current_buffer, start_row, end_row + 1, false, new_lines)
    -- vim.notify("Unbolded text", vim.log.levels.INFO)
  else
    -- Bold the word at the cursor position if no bold markers are found
    local before = line:sub(1, col)
    local after = line:sub(col + 1)
    local inside_surround = before:match("%*%*[^%*]*$") and after:match("^[^%*]*%*%*")
    if inside_surround then
      vim.cmd("normal gsd*.")
    else
      vim.cmd("normal viw")
      vim.cmd("normal 2gsa*")
    end
    vim.notify("Bolded current word", vim.log.levels.INFO)
  end
end, { desc = "[P]BOLD toggle bold markers" })

-- -- Single word/line bold
-- -- In normal mode, bold the current word under the cursor
-- -- If already bold, it will unbold the word under the cursor
-- -- This does NOT unbold multilines
-- vim.keymap.set("n", "<leader>mb", function()
--   local cursor_pos = vim.api.nvim_win_get_cursor(0)
--   -- local row = cursor_pos[1] -- Removed the unused variable
--   local col = cursor_pos[2]
--   local line = vim.api.nvim_get_current_line()
--   -- Check if the cursor is on an asterisk
--   if line:sub(col + 1, col + 1):match("%*") then
--     vim.notify("Cursor is on an asterisk, run inside the bold text", vim.log.levels.WARN)
--     return
--   end
--   -- Check if the cursor is inside surrounded text
--   local before = line:sub(1, col)
--   local after = line:sub(col + 1)
--   local inside_surround = before:match("%*%*[^%*]*$") and after:match("^[^%*]*%*%*")
--   if inside_surround then
--     vim.cmd("normal gsd*.")
--   else
--     vim.cmd("normal viw")
--     vim.cmd("normal 2gsa*")
--   end
-- end, { desc = "[P]BOLD toggle on current word or selection" })

-- In visual mode, surround the selected text with markdown link syntax
vim.keymap.set("v", "<leader>mll", function()
  -- Copy what's currently in my clipboard to the register "a lamw25wmal
  vim.cmd("let @a = getreg('+')")
  -- delete selected text
  vim.cmd("normal d")
  -- Insert the following in insert mode
  vim.cmd("startinsert")
  vim.api.nvim_put({ "[]() " }, "c", true, true)
  -- Move to the left, paste, and then move to the right
  vim.cmd("normal F[pf(")
  -- Copy what's on the "a register back to the clipboard
  vim.cmd("call setreg('+', @a)")
  -- Paste what's on the clipboard
  vim.cmd("normal p")
  -- Leave me in normal mode or command mode
  vim.cmd("stopinsert")
  -- Leave me in insert mode to start typing
  -- vim.cmd("startinsert")
end, { desc = "[P]Convert to link" })

-- In visual mode, surround the selected text with markdown link syntax
vim.keymap.set("v", "<leader>mlt", function()
  -- Copy what's currently in my clipboard to the register "a lamw25wmal
  vim.cmd("let @a = getreg('+')")
  -- delete selected text
  vim.cmd("normal d")
  -- Insert the following in insert mode
  vim.cmd("startinsert")
  vim.api.nvim_put({ '[](){:target="_blank"} ' }, "c", true, true)
  vim.cmd("normal F[pf(")
  -- Copy what's on the "a register back to the clipboard
  vim.cmd("call setreg('+', @a)")
  -- Paste what's on the clipboard
  vim.cmd("normal p")
  -- Leave me in normal mode or command mode
  vim.cmd("stopinsert")
  -- Leave me in insert mode to start typing
  -- vim.cmd("startinsert")
end, { desc = "[P]Convert to link (new tab)" })

-- Paste a github link and add it in this format
-- [folke/noice.nvim](https://github.com/folke/noice.nvim){:target="\_blank"}
vim.keymap.set("i", "<C-g>", function()
  -- Insert the text in the desired format
  vim.cmd('normal! a[](){:target="_blank"} ')
  vim.cmd("normal! F(pv2F/lyF[p")
  -- Leave me in normal mode or command mode
  vim.cmd("stopinsert")
end, { desc = "[P]Paste Github link" })

-- -- The following are related to indentation with tab, may not work perfectly
-- -- but get the job done
-- -- To indent in insert mode use C-T and C-D and in normal mode >> and <<
-- --
-- -- I disabled these as they interfere when jumpting to different sections of
-- -- my snippets, and probably other stuff, not a good idea
-- -- Maybe look for a different key, but not tab
-- --
-- -- Increase indent with tab in normal mode
-- vim.keymap.set("n", "<Tab>", function()
--   vim.cmd("normal >>")
-- end, { desc = "[P]Increase Indent" })
--
-- -- Decrease indent with tab in normal mode
-- vim.keymap.set("n", "<S-Tab>", function()
--   vim.cmd("normal <<")
-- end, { desc = "[P]Decrease Indent" })
--
-- -- Increase indent with tab in insert mode
-- vim.keymap.set("i", "<Tab>", function()
--   vim.api.nvim_input("<C-T>")
-- end, { desc = "[P]Increase Indent" })
--
-- -- Decrease indent with tab in insert mode
-- vim.keymap.set("i", "<S-Tab>", function()
--   vim.api.nvim_input("<C-D>")
-- end, { desc = "[P]Decrease Indent" })

-------------------------------------------------------------------------------
--                           Folding section
-------------------------------------------------------------------------------

-- Use <CR> to fold when in normal mode
-- To see help about folds use `:help fold`
vim.keymap.set("n", "<CR>", function()
  -- Get the current line number
  local line = vim.fn.line(".")
  -- Get the fold level of the current line
  local foldlevel = vim.fn.foldlevel(line)
  if foldlevel == 0 then
    vim.notify("No fold found", vim.log.levels.INFO)
  else
    vim.cmd("normal! za")
  end
end, { desc = "[P]Toggle fold" })

local function set_foldmethod_expr()
  -- These are lazyvim.org defaults but setting them just in case a file
  -- doesn't have them set
  if vim.fn.has("nvim-0.10") == 1 then
    vim.opt.foldmethod = "expr"
    vim.opt.foldexpr = "v:lua.require'lazyvim.util'.ui.foldexpr()"
    vim.opt.foldtext = ""
  else
    vim.opt.foldmethod = "indent"
    vim.opt.foldtext = "v:lua.require'lazyvim.util'.ui.foldtext()"
  end
  vim.opt.foldlevel = 99
end

-- Function to fold all headings of a specific level
local function fold_headings_of_level(level)
  -- Move to the top of the file
  vim.cmd("normal! gg")
  -- Get the total number of lines
  local total_lines = vim.fn.line("$")
  for line = 1, total_lines do
    -- Get the content of the current line
    local line_content = vim.fn.getline(line)
    -- "^" -> Ensures the match is at the start of the line
    -- string.rep("#", level) -> Creates a string with 'level' number of "#" characters
    -- "%s" -> Matches any whitespace character after the "#" characters
    -- So this will match `## `, `### `, `#### ` for example, which are markdown headings
    if line_content:match("^" .. string.rep("#", level) .. "%s") then
      -- Move the cursor to the current line
      vim.fn.cursor(line, 1)
      -- Fold the heading if it matches the level
      if vim.fn.foldclosed(line) == -1 then
        vim.cmd("normal! za")
      end
    end
  end
end

local function fold_markdown_headings(levels)
  set_foldmethod_expr()
  -- I save the view to know where to jump back after folding
  local saved_view = vim.fn.winsaveview()
  for _, level in ipairs(levels) do
    fold_headings_of_level(level)
  end
  vim.cmd("nohlsearch")
  -- Restore the view to jump to where I was
  vim.fn.winrestview(saved_view)
end

-- Keymap for unfolding markdown headings of level 2 or above
vim.keymap.set("n", "<leader>mfu", function()
  -- Reloads the file to reflect the changes
  vim.cmd("edit!")
  vim.cmd("normal! zR") -- Unfold all headings
end, { desc = "[P]Unfold all headings level 2 or above" })

-- Keymap for folding markdown headings of level 1 or above
vim.keymap.set("n", "<leader>mfj", function()
  -- Reloads the file to refresh folds, otherwise you have to re-open neovim
  vim.cmd("edit!")
  -- Unfold everything first or I had issues
  vim.cmd("normal! zR")
  fold_markdown_headings({ 6, 5, 4, 3, 2, 1 })
end, { desc = "[P]Fold all headings level 1 or above" })

-- Keymap for folding markdown headings of level 2 or above
-- I know, it reads like "madafaka" but "k" for me means "2"
vim.keymap.set("n", "<leader>mfk", function()
  -- Reloads the file to refresh folds, otherwise you have to re-open neovim
  vim.cmd("edit!")
  -- Unfold everything first or I had issues
  vim.cmd("normal! zR")
  fold_markdown_headings({ 6, 5, 4, 3, 2 })
end, { desc = "[P]Fold all headings level 2 or above" })

-- Keymap for folding markdown headings of level 3 or above
vim.keymap.set("n", "<leader>mfl", function()
  -- Reloads the file to refresh folds, otherwise you have to re-open neovim
  vim.cmd("edit!")
  -- Unfold everything first or I had issues
  vim.cmd("normal! zR")
  fold_markdown_headings({ 6, 5, 4, 3 })
end, { desc = "[P]Fold all headings level 3 or above" })

-- Keymap for folding markdown headings of level 4 or above
vim.keymap.set("n", "<leader>mf;", function()
  -- Reloads the file to refresh folds, otherwise you have to re-open neovim
  vim.cmd("edit!")
  -- Unfold everything first or I had issues
  vim.cmd("normal! zR")
  fold_markdown_headings({ 6, 5, 4 })
end, { desc = "[P]Fold all headings level 4 or above" })

-------------------------------------------------------------------------------
--                         End Folding section
-------------------------------------------------------------------------------

-- Detect todos and toggle between ":" and ";", or show a message if not found
-- This is to "mark them as done"
vim.keymap.set("n", "<leader>td", function()
  -- Get the current line
  local current_line = vim.fn.getline(".")
  -- Get the current line number
  local line_number = vim.fn.line(".")
  if string.find(current_line, "TODO:") then
    -- Replace the first occurrence of ":" with ";"
    local new_line = current_line:gsub("TODO:", "TODO;")
    -- Set the modified line
    vim.fn.setline(line_number, new_line)
  elseif string.find(current_line, "TODO;") then
    -- Replace the first occurrence of ";" with ":"
    local new_line = current_line:gsub("TODO;", "TODO:")
    -- Set the modified line
    vim.fn.setline(line_number, new_line)
  else
    vim.cmd("echo 'todo item not detected'")
  end
end, { desc = "[P]TODO toggle item done or not" })

-- Generate/update a Markdown TOC
-- To generate the TOC I use the markdown-toc plugin
-- https://github.com/jonschlinkert/markdown-toc
-- And the markdown-toc plugin installed as a LazyExtra
vim.keymap.set("n", "<leader>mt", function()
  local path = vim.fn.expand("%") -- Expands the current file name to a full path
  local bufnr = 0 -- The current buffer number, 0 references the current active buffer
  -- Save the current view
  -- If I don't do this, my folds are lost when I run this keymap
  vim.cmd("mkview")
  -- Retrieves all lines from the current buffer
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local toc_exists = false -- Flag to check if TOC marker exists
  local frontmatter_end = 0 -- To store the end line number of frontmatter
  -- Check for frontmatter and TOC marker
  for i, line in ipairs(lines) do
    if i == 1 and line:match("^---$") then
      -- Frontmatter start detected, now find the end
      for j = i + 1, #lines do
        if lines[j]:match("^---$") then
          frontmatter_end = j -- Save the end line of the frontmatter
          break
        end
      end
    end
    -- Checks for the TOC marker
    if line:match("^%s*<!%-%-%s*toc%s*%-%->%s*$") then
      toc_exists = true -- Sets the flag if TOC marker is found
      break -- Stops the loop if TOC marker is found
    end
  end
  -- Inserts H1 heading and <!-- toc --> at the appropriate position
  if not toc_exists then
    if frontmatter_end > 0 then
      -- Insert after frontmatter
      vim.api.nvim_buf_set_lines(bufnr, frontmatter_end, frontmatter_end, false, { "", "# Contents", "<!-- toc -->" })
    else
      -- Insert at the top if no frontmatter
      vim.api.nvim_buf_set_lines(bufnr, 0, 0, false, { "# Contents", "<!-- toc -->" })
    end
  end
  -- Silently save the file, in case TOC being created for first time (yes, you need the 2 saves)
  vim.cmd("silent write")
  -- Silently run markdown-toc to update the TOC without displaying command output
  vim.fn.system("markdown-toc -i " .. path)
  vim.cmd("edit!") -- Reloads the file to reflect the changes made by markdown-toc
  vim.cmd("silent write") -- Silently save the file
  vim.notify("TOC updated and file saved", vim.log.levels.INFO)
  -- -- In case a cleanup is needed, leaving this old code here as a reference
  -- -- I used this code before I implemented the frontmatter check
  -- -- Moves the cursor to the top of the file
  -- vim.api.nvim_win_set_cursor(bufnr, { 1, 0 })
  -- -- Deletes leading blank lines from the top of the file
  -- while true do
  --   -- Retrieves the first line of the buffer
  --   local line = vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1]
  --   -- Checks if the line is empty
  --   if line == "" then
  --     -- Deletes the line if it's empty
  --     vim.api.nvim_buf_set_lines(bufnr, 0, 1, false, {})
  --   else
  --     -- Breaks the loop if the line is not empty, indicating content or TOC marker
  --     break
  --   end
  -- end
  -- Restore the saved view (including folds)
  vim.cmd("loadview")
end, { desc = "[P]Insert/update Markdown TOC" })

-- Save the cursor position globally to access it across different mappings
_G.saved_positions = {}

-- Mapping to jump to the first line of the TOC
vim.keymap.set("n", "<leader>mm", function()
  -- Save the current cursor position
  _G.saved_positions["toc_return"] = vim.api.nvim_win_get_cursor(0)
  -- Perform a silent search for the <!-- toc --> marker and move the cursor two lines below it
  vim.cmd("silent! /<!-- toc -->\\n\\n\\zs.*")
  -- Clear the search highlight without showing the "search hit BOTTOM, continuing at TOP" message
  vim.cmd("nohlsearch")
  -- Retrieve the current cursor position (after moving to the TOC)
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local row = cursor_pos[1]
  -- local col = cursor_pos[2]
  -- Move the cursor to column 15 (starts counting at 0)
  -- I like just going down on the TOC and press gd to go to a section
  vim.api.nvim_win_set_cursor(0, { row, 14 })
end, { desc = "[P]Jump to the first line of the TOC" })

-- Mapping to return to the previously saved cursor position
vim.keymap.set("n", "<leader>mn", function()
  local pos = _G.saved_positions["toc_return"]
  if pos then
    vim.api.nvim_win_set_cursor(0, pos)
  end
end, { desc = "[P]Return to position before jumping" })

-- -- Search UP for a markdown header
-- -- If you have comments inside a codeblock, they can start with `# ` but make
-- -- sure that the line either below or above of the comment is not empty
-- -- Headings are considered the ones that have both an empty line above and also below
-- -- My markdown headings are autoformatted, so I always make sure about that
-- vim.keymap.set("n", "gk", function()
--   local foundHeader = false
--   -- Function to check if the given line number is blank
--   local function isBlankLine(lineNum)
--     return vim.fn.getline(lineNum):match("^%s*$") ~= nil
--   end
--   -- Function to search up for a markdown header
--   local function searchBackwardForHeader()
--     vim.cmd("silent! ?^\\s*#\\+\\s.*$")
--     local currentLineNum = vim.fn.line(".")
--     local aboveIsBlank = isBlankLine(currentLineNum - 1)
--     local belowIsBlank = isBlankLine(currentLineNum + 1)
--     -- Check if both above and below lines are blank, indicating a markdown header
--     if aboveIsBlank and belowIsBlank then
--       foundHeader = true
--     end
--     return currentLineNum
--   end
--   -- Initial search
--   local lastLineNum = searchBackwardForHeader()
--   -- Continue searching if the initial search did not find a header
--   while not foundHeader and vim.fn.line(".") > 1 do
--     local currentLineNum = searchBackwardForHeader()
--     -- Break the loop if the search doesn't change line number to prevent infinite loop
--     if currentLineNum == lastLineNum then
--       break
--     else
--       lastLineNum = currentLineNum
--     end
--   end
--   -- Clear search highlighting after operation
--   vim.cmd("nohlsearch")
-- end, { desc = "[P]Go to previous markdown header" })
--
-- -- Search DOWN for a markdown header
-- -- If you have comments inside a codeblock, they can start with `# ` but make
-- -- sure that the line either below or above of the comment is not empty
-- -- Headings are considered the ones that have both an empty line above and also below
-- -- My markdown headings are autoformatted, so I always make sure about that
-- vim.keymap.set("n", "gj", function()
--   local foundHeader = false
--   -- Function to check if the given line number is blank
--   local function isBlankLine(lineNum)
--     return vim.fn.getline(lineNum):match("^%s*$") ~= nil
--   end
--   -- Function to search down for a markdown header
--   local function searchForwardForHeader()
--     vim.cmd("silent! /^\\s*#\\+\\s.*$")
--     local currentLineNum = vim.fn.line(".")
--     local aboveIsBlank = isBlankLine(currentLineNum - 1)
--     local belowIsBlank = isBlankLine(currentLineNum + 1)
--     -- Check if both above and below lines are blank, indicating a markdown header
--     if aboveIsBlank and belowIsBlank then
--       foundHeader = true
--     end
--     return currentLineNum
--   end
--   -- Initial search
--   local lastLineNum = searchForwardForHeader()
--   -- Continue searching if the initial search did not find a header
--   while not foundHeader and vim.fn.line(".") < vim.fn.line("$") do
--     local currentLineNum = searchForwardForHeader()
--     -- Break the loop if the search doesn't change line number to prevent infinite loop
--     if currentLineNum == lastLineNum then
--       break
--     else
--       lastLineNum = currentLineNum
--     end
--   end
--   -- Clear search highlighting after operation
--   vim.cmd("nohlsearch")
-- end, { desc = "[P]Go to next markdown header" })

-- Search UP for a markdown header
-- Make sure to follow proper markdown convention, and you have a single H1
-- heading at the very top of the file
-- This will only search for H2 headings and above
vim.keymap.set({ "n", "v" }, "gk", function()
  -- `?` - Start a search backwards from the current cursor position.
  -- `^` - Match the beginning of a line.
  -- `##` - Match 2 ## symbols
  -- `\\+` - Match one or more occurrences of prev element (#)
  -- `\\s` - Match exactly one whitespace character following the hashes
  -- `.*` - Match any characters (except newline) following the space
  -- `$` - Match extends to end of line
  vim.cmd("silent! ?^##\\+\\s.*$")
  -- Clear the search highlight
  vim.cmd("nohlsearch")
end, { desc = "[P]Go to previous markdown header" })

-- Search DOWN for a markdown header
-- Make sure to follow proper markdown convention, and you have a single H1
-- heading at the very top of the file
-- This will only search for H2 headings and above
vim.keymap.set({ "n", "v" }, "gj", function()
  -- `/` - Start a search forwards from the current cursor position.
  -- `^` - Match the beginning of a line.
  -- `##` - Match 2 ## symbols
  -- `\\+` - Match one or more occurrences of prev element (#)
  -- `\\s` - Match exactly one whitespace character following the hashes
  -- `.*` - Match any characters (except newline) following the space
  -- `$` - Match extends to end of line
  vim.cmd("silent! /^##\\+\\s.*$")
  -- Clear the search highlight
  vim.cmd("nohlsearch")
end, { desc = "[P]Go to next markdown header" })

-- Function to delete the current file with confirmation
local function delete_current_file()
  local current_file = vim.fn.expand("%:p")
  if current_file and current_file ~= "" then
    -- Check if trash utility is installed
    if vim.fn.executable("trash") == 0 then
      vim.api.nvim_echo({
        { "- Trash utility not installed. Make sure to install it first\n", "ErrorMsg" },
        { "- In macOS run `brew install trash`\n", nil },
      }, false, {})
      return
    end
    -- Prompt for confirmation before deleting the file
    vim.ui.input({
      prompt = "Type 'del' to delete the file '" .. current_file .. "': ",
    }, function(input)
      if input == "del" then
        -- Delete the file using trash app
        local success, _ = pcall(function()
          vim.fn.system({ "trash", vim.fn.fnameescape(current_file) })
        end)
        if success then
          vim.api.nvim_echo({
            { "File deleted from disk:\n", "Normal" },
            { current_file, "Normal" },
          }, false, {})
          -- Close the buffer after deleting the file
          vim.cmd("bd!")
        else
          vim.api.nvim_echo({
            { "Failed to delete file:\n", "ErrorMsg" },
            { current_file, "ErrorMsg" },
          }, false, {})
        end
      else
        vim.api.nvim_echo({
          { "File deletion canceled.", "Normal" },
        }, false, {})
      end
    end)
  else
    vim.api.nvim_echo({
      { "No file to delete", "WarningMsg" },
    }, false, {})
  end
end

-- Keymap to delete the current file
vim.keymap.set("n", "<leader>fD", function()
  delete_current_file()
end, { desc = "[P]Delete current file" })

-- These create the a markdown heading based on the level specified, and also
-- dynamically add the date below in the [[2024-03-01-Friday]] format
local function insert_heading_and_date(level)
  local date = os.date("%Y-%m-%d-%A")
  local heading = string.rep("#", level) .. " " -- Generate heading based on the level
  local dateLine = "[[" .. date .. "]]" -- Formatted date line
  local row, _ = unpack(vim.api.nvim_win_get_cursor(0)) -- Get the current row number
  -- Insert both lines: heading and dateLine
  vim.api.nvim_buf_set_lines(0, row, row, false, { heading, dateLine })
  -- Move the cursor to the end of the heading
  vim.api.nvim_win_set_cursor(0, { row + 1, 0 })
  -- Enter insert mode at the end of the current line
  vim.cmd("startinsert!")
  return dateLine
  -- vim.api.nvim_win_set_cursor(0, { row, #heading })
end

-- Create or find a daily note based on a date line format and open it in Neovim
-- This is used in obsidian markdown files that have the "Link to non-existent
-- document" warning
local function create_daily_note(date_line)
  local home = os.getenv("HOME")
  local year, month, day, weekday = date_line:match("%[%[(%d+)%-(%d+)%-(%d+)%-(%w+)%]%]")
  if not (year and month and day and weekday) then
    print("No valid date found in the line")
    return
  end
  local month_abbr = os.date("%b", os.time({ year = year, month = month, day = day }))
  local note_dir = string.format("%s/github/obsidian_main/250-daily/%s/%s-%s", home, year, month, month_abbr)
  local note_name = string.format("%s-%s-%s-%s.md", year, month, day, weekday)
  local full_path = note_dir .. "/" .. note_name
  -- Check if the directory exists, if not, create it
  vim.fn.mkdir(note_dir, "p")
  -- Check if the file exists and create it if not
  if vim.fn.filereadable(full_path) == 0 then
    local file = io.open(full_path, "w")
    if file then
      file:write("# Contents\n\n<!-- toc -->\n\n- [Daily note](#daily-note)\n\n<!-- tocstop -->\n\n## Daily note\n")
      file:close()
      -- Open the file and then close it to refresh the buffer
      -- I do this, because otherwise the current file does not recognize that
      -- the new file was created
      vim.cmd("edit " .. vim.fn.fnameescape(full_path))
      vim.cmd("bd!")
      vim.api.nvim_echo({
        { "CREATED DAILY NOTE\n", "WarningMsg" },
        { full_path, "WarningMsg" },
      }, false, {})
    else
      print("Failed to create file: " .. full_path)
    end
  else
    print("Daily note already exists: " .. full_path)
  end
end

-- These create the the markdown heading
-- H1
vim.keymap.set("n", "<leader>jj", function()
  local date_line = insert_heading_and_date(1)
  -- If you just want to add the heading, comment the line below
  create_daily_note(date_line)
end, { desc = "[P]H1 heading and date" })

-- H2
vim.keymap.set("n", "<leader>kk", function()
  local date_line = insert_heading_and_date(2)
  -- If you just want to add the heading, comment the line below
  create_daily_note(date_line)
end, { desc = "[P]H2 heading and date" })

-- H3
vim.keymap.set("n", "<leader>ll", function()
  local date_line = insert_heading_and_date(3)
  -- If you just want to add the heading, comment the line below
  create_daily_note(date_line)
end, { desc = "[P]H3 heading and date" })

-- H4
vim.keymap.set("n", "<leader>;;", function()
  local date_line = insert_heading_and_date(4)
  -- If you just want to add the heading, comment the line below
  create_daily_note(date_line)
end, { desc = "[P]H4 heading and date" })

-- H5
vim.keymap.set("n", "<leader>uu", function()
  local date_line = insert_heading_and_date(5)
  -- If you just want to add the heading, comment the line below
  create_daily_note(date_line)
end, { desc = "[P]H5 heading and date" })

-- H6
vim.keymap.set("n", "<leader>ii", function()
  local date_line = insert_heading_and_date(6)
  -- If you just want to add the heading, comment the line below
  create_daily_note(date_line)
end, { desc = "[P]H6 heading and date" })

-- Create or find a daily note
vim.keymap.set("n", "<leader>fC", function()
  -- Use the current line for date extraction
  local current_line = vim.api.nvim_get_current_line()
  create_daily_note(current_line)
end, { desc = "[P]Create daily note" })

-- Surround the http:// url that the cursor is currently in with ``
vim.keymap.set("n", "gsu", function()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2] + 1 -- Adjust for 0-index in Lua
  -- This makes the `s` optional so it matches both http and https
  local pattern = "https?://[^ ,;'\"<>%s)]*"
  -- Find the starting and ending positions of the URL
  local s, e = string.find(line, pattern)
  while s and e do
    if s <= col and e >= col then
      -- When the cursor is within the URL
      local url = string.sub(line, s, e)
      -- Update the line with backticks around the URL
      local new_line = string.sub(line, 1, s - 1) .. "`" .. url .. "`" .. string.sub(line, e + 1)
      vim.api.nvim_set_current_line(new_line)
      vim.cmd("silent write")
      return
    end
    -- Find the next URL in the line
    s, e = string.find(line, pattern, e + 1)
    -- Save the file to update trouble list
  end
  print("No URL found under cursor")
end, { desc = "[P]Add surrounding to URL" })

-- - I have several `.md` documents that do not follow markdown guidelines
-- - There are some old ones that have more than one H1 heading in them, so when I
--   open one of those old documents, I want to add one more `#` to each heading
--
--  This doesn't ask for confirmation and just increase all the headings
vim.keymap.set("n", "<leader>mhI", function()
  -- Save the current cursor position
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  -- I'm using [[ ]] to escape the special characters in a command
  vim.cmd([[:g/\(^$\n\s*#\+\s.*\n^$\)/ .+1 s/^#\+\s/#&/]])
  -- Restore the cursor position
  vim.api.nvim_win_set_cursor(0, cursor_pos)
  -- Clear search highlight
  vim.cmd("nohlsearch")
end, { desc = "[P]Increase headings without confirmation" })

vim.keymap.set("n", "<leader>mhD", function()
  -- Save the current cursor position
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  -- I'm using [[ ]] to escape the special characters in a command
  vim.cmd([[:g/^\s*#\{2,}\s/ s/^#\(#\+\s.*\)/\1/]])
  -- Restore the cursor position
  vim.api.nvim_win_set_cursor(0, cursor_pos)
  -- Clear search highlight
  vim.cmd("nohlsearch")
end, { desc = "[P]Decrease headings without confirmation" })

-- -- This goes 1 heading at a time and asks for **confirmation**
-- -- - keep pressing `n` to NOT increase, but you can see it detects headings
-- --  - `y` (yes): Replace this instance and continue to the next match.
-- --  - `n` (no): Do not replace this instance and continue to the next match.
-- --  - `a` (all): Replace all remaining instances without further prompting.
-- --  - `q` (quit): Quit without making any further replacements.
-- --  - `l` (last): Replace this instance and then quit
-- --  - `^E` (`Ctrl+E`): Scroll the text window down one line
-- --  - `^Y` (`Ctrl+Y`): Scroll the text window up one line
-- vim.keymap.set("n", "<leader>mhi", function()
--   -- Save the current cursor position
--   local cursor_pos = vim.api.nvim_win_get_cursor(0)
--   -- I'm using [[ ]] to escape the special characters in a command
--   vim.cmd([[:g/\(^$\n\s*#\+\s.*\n^$\)/ .+1 s/^#\+\s/#&/c]])
--   -- Restore the cursor position
--   vim.api.nvim_win_set_cursor(0, cursor_pos)
--   -- Clear search highlight
--   vim.cmd("nohlsearch")
-- end, { desc = "[P]Increase headings with confirmation" })

-- -- These are similar, but instead of adding an # they remove it
-- vim.keymap.set("n", "<leader>mhd", function()
--   -- Save the current cursor position
--   local cursor_pos = vim.api.nvim_win_get_cursor(0)
--   -- I'm using [[ ]] to escape the special characters in a command
--   vim.cmd([[:g/^\s*#\{2,}\s/ s/^#\(#\+\s.*\)/\1/c]])
--   -- Restore the cursor position
--   vim.api.nvim_win_set_cursor(0, cursor_pos)
--   -- Clear search highlight
--   vim.cmd("nohlsearch")
-- end, { desc = "[P]Decrease headings with confirmation" })

-- ############################################################################
--                       End of markdown section
-- ############################################################################

-- Marks keep coming back even after deleting them, this deletes them all
-- This deletes all marks in the current buffer, including lowercase, uppercase, and numbered marks
-- Fix should be applied on April 2024
-- https://github.com/chentoast/marks.nvim/issues/13
vim.keymap.set("n", "<leader>mD", function()
  -- Delete all marks in the current buffer
  vim.cmd("delmarks!")
  print("All marks deleted.")
end, { desc = "[P]Delete all marks" })

-- Open current file in finder
vim.keymap.set("n", "<leader>fO", function()
  local file_path = vim.fn.expand("%:p")
  if file_path ~= "" then
    local command = "open -R " .. vim.fn.shellescape(file_path)
    vim.fn.system(command)
    print("Opened file in Finder: " .. file_path)
  else
    print("No file is currently open")
  end
end, { desc = "[P]Open current file in Finder" })
-- Keymap to toggle the stay-centered plugin
vim.keymap.set({ "n", "v" }, "<leader>mc", require("stay-centered").toggle, { desc = "[P]Toggle stay-centered.nvim" })

-- Keymap to create a GitHub repository
-- It uses the github CLI, which in macOS is installed with:
-- brew install gh
vim.keymap.set("n", "<leader>gC", function()
  -- Check if GitHub CLI is installed
  local gh_installed = vim.fn.system("command -v gh")
  if gh_installed == "" then
    print("GitHub CLI is not installed. Please install it using 'brew install gh'.")
    return
  end
  -- Get the current working directory and extract the repository name
  local cwd = vim.fn.getcwd()
  local repo_name = vim.fn.fnamemodify(cwd, ":t")
  if repo_name == "" then
    print("Failed to extract repository name from the current directory.")
    return
  end
  -- Display the message and ask for confirmation
  local confirmation = vim.fn.input('The name of the repo will be: "' .. repo_name .. '"\nType "yes" to continue: ')
  if confirmation:lower() ~= "yes" then
    print("Operation canceled.")
    return
  end
  -- Check if the repository already exists on GitHub
  local check_repo_command =
    string.format("gh repo view %s/%s", vim.fn.system("gh api user --jq '.login'"):gsub("%s+", ""), repo_name)
  local check_repo_result = vim.fn.systemlist(check_repo_command)
  if not string.find(table.concat(check_repo_result), "Could not resolve to a Repository") then
    print("Repository '" .. repo_name .. "' already exists on GitHub.")
    return
  end
  -- Prompt for repository type
  local repo_type = vim.fn.input("Enter the repository type (private/public): "):lower()
  if repo_type ~= "private" and repo_type ~= "public" then
    print("Invalid repository type. Please enter 'private' or 'public'.")
    return
  end
  -- Set the repository type flag
  local repo_type_flag = repo_type == "private" and "--private" or "--public"
  -- Initialize the git repository and create the GitHub repository
  local init_command = string.format("cd %s && git init", vim.fn.shellescape(cwd))
  vim.fn.system(init_command)
  local create_command =
    string.format("cd %s && gh repo create %s %s --source=.", vim.fn.shellescape(cwd), repo_name, repo_type_flag)
  local create_result = vim.fn.system(create_command)
  -- Print the result of the repository creation command
  if string.find(create_result, "https://github.com") then
    print("Repository '" .. repo_name .. "' created successfully.")
  else
    print("Failed to create the repository: " .. create_result)
  end
end, { desc = "[P]Create GitHub repository" })

-- -- From Primeagen's tmux-sessionizer
-- -- ctrl+f in normal mode will silently run a command to create a new tmux window and execute the tmux-sessionizer.
-- -- Allowing quick creation and navigation of tmux sessions directly from the editor.
-- vim.keymap.set(
--   "n",
--   "<C-f>",
--   "<cmd>silent !tmux neww ~/github/dotfiles-latest/tmux/tools/prime/tmux-sessionizer.sh<CR>"
-- )
