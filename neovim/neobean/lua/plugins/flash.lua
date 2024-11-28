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
  },
}
