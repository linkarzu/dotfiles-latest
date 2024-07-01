-- https://github.com/mg979/vim-visual-multi

-- In macos disable Settings - Keyboard - Keyboard Shortcuts
-- Disable both 'Mission Control' shortcuts that use ctrl+down and ctrl+up
-- As those are used by the plugin to create vertical cursors

-- select words with Ctrl-N
-- create cursors vertically with Ctrl-Down/Ctrl-Up
-- select one character at a time with Shift-Arrows
-- press n/N to get next/previous occurrence
-- press [/] to select next/previous cursor
-- press q to skip current and get next occurrence
-- press Q to remove current cursor/selection
-- start insert mode with i,a,I,

-- INSTRUCTIONS:

-- Help:
-- :help visual-multi

-- To select up to a word in multiple lines (similar to vfd)
-- Place on the first word and do 'ctrl+down' to create vertical cursors
-- Then change to extend mode with 'tab'
-- Then type 'g/' and enter what you want to match, a word or symbol
-- Press enter and your text will be selected

-- I wanted to insert an "i" between a ' and a ; in multiple lines
-- I put the cursor in the '
-- Pressed ctrl+n, then "n" to select the next words
-- Then the letter "i" to insert
-- Then the right arrow and then letter "i" to insert the "i" and escape

-- Put yourself on the 1st letter of the word you want to edit, press ctrl+n
-- keep pressing 'n' again to select the word on the below lines
-- to skip the current word press 'q' and will continue to next
-- Then press 'e' or 'w' to move to the right to select the entire word
-- Hit C to change the word, type the new word, hit escape

-- You can also first select a word in visual mode, then do ctrl+n and keep
-- pressing 'n' to select the same words
-- press 'q' to skip workds

return {
  { "mg979/vim-visual-multi" },
}
