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
        enabled = true,
      },
    },
  },
}
