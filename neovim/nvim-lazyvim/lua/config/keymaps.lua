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

-- Ctrl+d and u are used to move up or down a half screen
-- but I don't like to use ctrl, so enabled this as well, both options work
-- zz makes the cursor to stay in the middle
-- If you want to return back to ctrl+d and ctrl+u
vim.keymap.set("n", "gk", "<C-u>zz", { desc = "Go up a half screen" })
vim.keymap.set("n", "gj", "<C-d>zz", { desc = "Go down a half screen" })

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

-- Make the file you run the command on, executable, so you don't have to go out to the command line
vim.keymap.set("n", "<leader>fx", "<cmd>!chmod +x %<CR>", { silent = true, desc = "Make file executable" })
vim.keymap.set("n", "<leader>fX", "<cmd>!chmod -x %<CR>", { silent = true, desc = "Remove executable flag" })

-- If this is a script, make it executable, and execute it in a split pane on the right
vim.keymap.set("n", "<leader>f.", function()
  vim.cmd("!chmod +x %") -- Make the file executable
  vim.cmd("vsplit") -- Split the window vertically
  vim.cmd("terminal " .. vim.fn.expand("%")) -- Open terminal and execute the file
  vim.api.nvim_feedkeys("i", "n", false) -- Enter insert mode, moves to end of prompt if there's one
end, { desc = "Execute current file in terminal" })

-- Primeagen uses this, leaving it here, but not using it for now
-- ctrl+f in normal mode will silently run a command to create a new tmux window and execute the tmux-sessionizer.
-- Allowing quick creation and navigation of tmux sessions directly from the editor.
vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")
