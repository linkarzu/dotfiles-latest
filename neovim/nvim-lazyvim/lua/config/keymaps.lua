-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- use kj to exit insert mode
vim.keymap.set("i", "kj", "<ESC>", { desc = "Exit insert mode with kj" })

-- use gh to move to the beginning of the line in normal mode
-- use gl to move to the end of the line in normal mode
vim.keymap.set("n", "gh", "^", { desc = "Go to the beginning of the line" })
vim.keymap.set("n", "gl", "$", { desc = "go to the end of the line" })
vim.keymap.set("v", "gh", "^", { desc = "Go to the beginning of the line in visual mode" })
vim.keymap.set("v", "gl", "$", { desc = "Go to the end of the line in visual mode" })

-- yank/copy to end of line
vim.keymap.set("n", "Y", "y$", { desc = "Yank to end of line" })

-- Disabled this because I use these keymaps to navigate markdown headers
-- Ctrl+d and u are used to move up or down a half screen
-- but I don't like to use ctrl, so enabled this as well, both options work
-- zz makes the cursor to stay in the middle
-- If you want to return back to ctrl+d and ctrl+u
-- vim.keymap.set("n", "gk", "<C-u>zz", { desc = "Go up a half screen" })
-- vim.keymap.set("n", "gj", "<C-d>zz", { desc = "Go down a half screen" })

-- When jumping with ctrl+d and u the cursors stays in the middle
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<c-u>", "<c-u>zz")

-- Move lines up and down in visual mode
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move line down in visual mode" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move line up in visual mode" })

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
  { desc = "Replace word I'm currently on GLOBALLY" }
)

-- Quickly alternate between the last 2 files
-- LazyVim comes with the default shortcut <leader>bb for this, but I navigate
-- between alternate files way too often, so this more useful for me
-- By default, in LazyVim, With leader<space> you usually find files in the root directory
vim.keymap.set("n", "<leader><space>", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })

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
    -- vim.cmd("silent !tmux split-window -h -l 70 'bash -c \"" .. escaped_file .. "; exec bash\"'")
    vim.cmd(
      "silent !tmux split-window -h -l 70 'bash -c \""
        .. escaped_file
        .. "; echo; echo Press any key to exit...; read -n 1; exit\"'"
    )
  else
    vim.cmd("echo 'Not a script. Shebang line not found.'")
  end
end, { desc = "BASH, execute file" })

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
-- end, { desc = "Execute bash script in pane on the right" })

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
    local cmd = "silent !tmux split-window -h -l 70 'cd "
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
end, { desc = "GOLANG, execute file" })

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
-- end, { desc = "Execute Go file in pane on the right" })

-- Open a tmux pane on the right in bash, in the same directory as the current file
-- Opening it in bash because it's faster, I don't have to run my .zshrc file,
-- which pulls from my repo and a lot of other stuff
vim.keymap.set("n", "<leader>c.", function()
  local file_dir = vim.fn.expand("%:p:h") -- Get the directory of the current file
  -- `-l 70` specifies the size of the tmux pane, in this case 70 columns
  local cmd = "silent !tmux split-window -h -l 70 'cd " .. file_dir .. " && bash'"
  vim.cmd(cmd)
end, { desc = "BASH, current dir in right tmux pane" })

-- This will add 3 lines:
-- 1. File path with the wordname Filename: first, then the path, and Go project name
-- 2. Just the filepath
-- 3. Name that I will use for with `go mod init`
vim.keymap.set({ "n", "v" }, "<leader>fp", function()
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
end, { desc = "Insert filename with path and go project name at cursor" })

-- -- Paste file path with the wordname Filename: first
-- vim.keymap.set("n", "<leader>fp", function()
--   local filePath = vim.fn.expand("%:~") -- Gets the file path relative to the home directory
--   local lineToInsert = "Filename: " .. filePath
--   local row, _ = unpack(vim.api.nvim_win_get_cursor(0)) -- Get the current row number
--   -- Insert line, leave cursor current position
--   vim.api.nvim_buf_set_lines(0, row - 1, row - 0, false, { lineToInsert })
--   -- Comment out the newly inserted line using the plugin's 'gcc' command
--   vim.cmd("normal gcc")
--   -- Insert a blank line below the current line
--   vim.api.nvim_buf_set_lines(0, row, row, false, { "" })
-- end, { desc = "Insert filename with path at cursor" })

-- Paste file path by itself
vim.keymap.set("n", "<leader>fo", function()
  local filePath = vim.fn.expand("%:~") -- Gets the file path relative to the home directory
  local lineToInsert = filePath
  local row, _ = unpack(vim.api.nvim_win_get_cursor(0)) -- Get the current row number
  -- Insert line, leave cursor current position
  vim.api.nvim_buf_set_lines(0, row - 1, row - 0, false, { lineToInsert })
  -- Comment out the newly inserted line using the plugin's 'gcc' command
  vim.cmd("normal gcc")
  -- Insert a blank line below the current line
  vim.api.nvim_buf_set_lines(0, row, row, false, { "" })
end, { desc = "Insert filename with path at cursor" })

-- ############################################################################
--                         Begin of markdown section
-- ############################################################################

-- When I press leader, I want 'm' to show me 'markdown'
-- https://github.com/folke/which-key.nvim?tab=readme-ov-file#%EF%B8%8F-mappings
local wk = require("which-key")
wk.register({
  ["<leader>"] = {
    m = {
      name = "+markdown",
    },
  },
})

-- Generate/update a Markdown TOC
-- To generate the TOC I use the markdown-toc plugin
-- https://github.com/jonschlinkert/markdown-toc
-- I install it with mason, go see my 'mason-nvim' plugin file
vim.keymap.set("n", "<leader>mt", function()
  local path = vim.fn.expand("%") -- Expands the current file name to a full path
  local bufnr = 0 -- The current buffer number, 0 references the current active buffer
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
      vim.api.nvim_buf_set_lines(
        bufnr,
        frontmatter_end + 1,
        frontmatter_end + 1,
        false,
        { "", "# Contents", "<!-- toc -->" }
      )
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
end, { desc = "Insert/update Markdown TOC" })

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
end, { desc = "Jump to the first line of the TOC" })

-- Mapping to return to the previously saved cursor position
vim.keymap.set("n", "<leader>mf", function()
  local pos = _G.saved_positions["toc_return"]
  if pos then
    vim.api.nvim_win_set_cursor(0, pos)
  end
end, { desc = "Return to position before jumping" })

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
-- end, { desc = "Go to previous markdown header" })
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
-- end, { desc = "Go to next markdown header" })

-- Search UP for a markdown header
-- Make sure to follow proper markdown convention, and you have a single H1
-- heading at the very top of the file
-- This will only search for H2 headings and above
vim.keymap.set("n", "gk", function()
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
end, { desc = "Go to previous markdown header" })

-- Search DOWN for a markdown header
-- Make sure to follow proper markdown convention, and you have a single H1
-- heading at the very top of the file
-- This will only search for H2 headings and above
vim.keymap.set("n", "gj", function()
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
end, { desc = "Go to next markdown header" })

vim.keymap.set("n", "<leader>jj", function()
  local date = os.date("%Y-%m-%d-%A")
  local heading = "# " -- Heading with space for the cursor
  local dateLine = "[[" .. date .. "]]" -- Formatted date line
  local row, _ = unpack(vim.api.nvim_win_get_cursor(0)) -- Get the current row number
  -- Insert both lines: heading and dateLine
  vim.api.nvim_buf_set_lines(0, row, row, false, { heading, dateLine })
  -- Move the cursor to the end of the heading
  vim.api.nvim_win_set_cursor(0, { row + 1, 0 })
  -- Enter insert mode at the end of the current line
  vim.cmd("startinsert!")
  -- vim.api.nvim_win_set_cursor(0, { row, #heading })
end, { desc = "H1 heading and date" })

vim.keymap.set("n", "<leader>kk", function()
  local date = os.date("%Y-%m-%d-%A")
  local heading = "## " -- Heading with space for the cursor
  local dateLine = "[[" .. date .. "]]" -- Formatted date line
  local row, _ = unpack(vim.api.nvim_win_get_cursor(0)) -- Get the current row number
  -- Insert both lines: heading and dateLine
  vim.api.nvim_buf_set_lines(0, row, row, false, { heading, dateLine })
  -- Move the cursor to the end of the heading
  vim.api.nvim_win_set_cursor(0, { row + 1, 0 })
  -- Enter insert mode at the end of the current line
  vim.cmd("startinsert!")
  -- vim.api.nvim_win_set_cursor(0, { row, #heading })
end, { desc = "H2 heading and date" })

vim.keymap.set("n", "<leader>ll", function()
  local date = os.date("%Y-%m-%d-%A")
  local heading = "### " -- Heading with space for the cursor
  local dateLine = "[[" .. date .. "]]" -- Formatted date line
  local row, _ = unpack(vim.api.nvim_win_get_cursor(0)) -- Get the current row number
  -- Insert both lines: heading and dateLine
  vim.api.nvim_buf_set_lines(0, row, row, false, { heading, dateLine })
  -- Move the cursor to the end of the heading
  vim.api.nvim_win_set_cursor(0, { row + 1, 0 })
  -- Enter insert mode at the end of the current line
  vim.cmd("startinsert!")
  -- vim.api.nvim_win_set_cursor(0, { row, #heading })
end, { desc = "H3 heading and date" })

vim.keymap.set("n", "<leader>;;", function()
  local date = os.date("%Y-%m-%d-%A")
  local heading = "#### " -- Heading with space for the cursor
  local dateLine = "[[" .. date .. "]]" -- Formatted date line
  local row, _ = unpack(vim.api.nvim_win_get_cursor(0)) -- Get the current row number
  -- Insert both lines: heading and dateLine
  vim.api.nvim_buf_set_lines(0, row, row, false, { heading, dateLine })
  -- Move the cursor to the end of the heading
  vim.api.nvim_win_set_cursor(0, { row + 1, 0 })
  -- Enter insert mode at the end of the current line
  vim.cmd("startinsert!")
  -- vim.api.nvim_win_set_cursor(0, { row, #heading })
end, { desc = "H4 heading and date" })

vim.keymap.set("n", "<leader>uu", function()
  local date = os.date("%Y-%m-%d-%A")
  local heading = "##### " -- Heading with space for the cursor
  local dateLine = "[[" .. date .. "]]" -- Formatted date line
  local row, _ = unpack(vim.api.nvim_win_get_cursor(0)) -- Get the current row number
  -- Insert both lines: heading and dateLine
  vim.api.nvim_buf_set_lines(0, row, row, false, { heading, dateLine })
  -- Move the cursor to the end of the heading
  vim.api.nvim_win_set_cursor(0, { row + 1, 0 })
  -- Enter insert mode at the end of the current line
  vim.cmd("startinsert!")
  -- vim.api.nvim_win_set_cursor(0, { row, #heading })
end, { desc = "H5 heading and date" })

vim.keymap.set("n", "<leader>ii", function()
  local date = os.date("%Y-%m-%d-%A")
  local heading = "###### " -- Heading with space for the cursor
  local dateLine = "[[" .. date .. "]]" -- Formatted date line
  local row, _ = unpack(vim.api.nvim_win_get_cursor(0)) -- Get the current row number
  -- Insert both lines: heading and dateLine
  vim.api.nvim_buf_set_lines(0, row, row, false, { heading, dateLine })
  -- Move the cursor to the end of the heading
  vim.api.nvim_win_set_cursor(0, { row + 1, 0 })
  -- Enter insert mode at the end of the current line
  vim.cmd("startinsert!")
  -- vim.api.nvim_win_set_cursor(0, { row, #heading })
end, { desc = "H6 heading and date" })

-- ############################################################################
--                       End of markdown section
-- ############################################################################

-- Marks keep coming back even after deleting them, this deletes them all
-- This deletes all marks in the current buffer, including lowercase, uppercase, and numbered marks
-- Fix should be applied on April 2024
-- https://github.com/chentoast/marks.nvim/issues/13
vim.keymap.set("n", "<leader>md", function()
  -- Delete all marks in the current buffer
  vim.cmd("delmarks!")
  print("All marks deleted.")
end, { desc = "Delete all marks" })

-- -- From Primeagen's tmux-sessionizer
-- -- ctrl+f in normal mode will silently run a command to create a new tmux window and execute the tmux-sessionizer.
-- -- Allowing quick creation and navigation of tmux sessions directly from the editor.
-- vim.keymap.set(
--   "n",
--   "<C-f>",
--   "<cmd>silent !tmux neww ~/github/dotfiles-latest/tmux/tools/prime/tmux-sessionizer.sh<CR>"
-- )
