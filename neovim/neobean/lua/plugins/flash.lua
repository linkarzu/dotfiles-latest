-------------------------------------------------------------------------------
--                            Remote operations
-------------------------------------------------------------------------------

-- The following are used in all the remote motions
-- r - remote flash
-- {text} - stuff to search with flash
-- {flash_char} - character used to jump in flash

-- Surround in "", 4 words in a remote location
-- gsar{text}{flash_char}4e"
-- gsa - surround add (leaves you in pending mode)
-- 4e - select 4 words
-- " - surround in quotes

-- Paste text in '' in another line where my cursor is at
-- Mind blowing trick shared by Maria Solano
-- https://youtu.be/0DNC3uRPBwc?si=kHMTyvpEP6j8q9eD&t=3214
-- yr{text}{flash_char}a'p
-- y - copy mode (leaves you in pending)
-- a' - around ' (select the text around '')
-- p - paste

-- Bold a remote location
-- gsar{text}{flash_char}4e?**<CR>**<CR>
-- gsa - surround add (leaves you in pending mode)
-- 4e - select 4 words
-- ? - mini.surround interactive. Prompts user to enter left and right parts.

-------------------------------------------------------------------------------
--                         End of Remote operations
-------------------------------------------------------------------------------

return {
  "folke/flash.nvim",
  opts = {
    -- I don't want aiorx as options when in flash, not sure why, but I don't
    -- labels = "asdfghjklqwertyuiopzxcvbnm",
    labels = "fghjklqwetyupzcvbnm",
    search = {
      -- If mode is set to the default "exact" if you mistype a word, it will
      -- exit flash, and if then you type "i" for example, you will start
      -- inserting text and fuck up your file outside
      --
      -- Search for me adds a protection layer, so if you mistype a word, it
      -- doesn't exit
      mode = "search",
    },
    -- jump = {
    --   pos = "end",
    -- },
    modes = {
      char = {
        -- f, t, F, T motions:
        -- After typing f{char} or F{char}, you can repeat the motion with f or go to the previous match with F to undo a jump.
        -- Similarly, after typing t{char} or T{char}, you can repeat the motion with t or go to the previous match with T.
        -- You can also go to the next match with ; or previous match with ,
        -- Any highlights clear automatically when moving, changing buffers, or pressing <esc>.
        --
        -- Useful if you do `vtf` or `vff` and then keep pressing f to jump to
        -- the next `f`s
        enabled = false,
      },
    },
  },
}
