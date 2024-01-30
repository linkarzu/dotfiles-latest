-- https://github.com/mg979/vim-visual-multi

-- In macos disable Settings - Keyboard - Keyboard Shortcuts
-- Disable both 'Mission Control' shortcuts that use ctrl+down and ctrl+up
-- As those are used to create multiple cursors

-- select words with Ctrl-N
-- create cursors vertically with Ctrl-Down/Ctrl-Up
-- select one character at a time with Shift-Arrows
-- press n/N to get next/previous occurrence
-- press [/] to select next/previous cursor
-- press q to skip current and get next occurrence
-- press Q to remove current cursor/selection
-- start insert mode with i,a,I,

-- INSTRUCTIONS:
-- Put yourself on the 1st letter of the word you want to edit, press ctrl+n
-- keep pressing 'n' again to select the word on the below lines
-- to skip the current word press 'q' and will continue to next
-- Then press 'e' or 'w' to move to the right to select the entire word
-- Hit C to change the word, type the new word, hit escape

return {
  -- add gruvbox
  { "mg979/vim-visual-multi" },
}
