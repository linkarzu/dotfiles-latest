-- Filename: ~/github/dotfiles-latest/neovim/neobean/lua/plugins/telescope-frecency.lua
-- ~/github/dotfiles-latest/neovim/neobean/lua/plugins/telescope-frecency.lua

--[=====[
https://github.com/nvim-telescope/telescope-frecency.nvim

This plugins keeps a score of my recently access files through telescope, and 
shows the ones I se the most at the top of the list

It requires telescope, so don't uninstall telescope

For questions read the docs
https://github.com/nvim-telescope/telescope-frecency.nvim/blob/master/doc/telescope-frecency.txt

You can delete entries from DB by this command. This command does not remove
the file itself, only from DB.
- delete the current opened file 
  - :FrecencyDelete
- delete the supplied path 
  - :FrecencyDelete /full/path/to/the/file
--]=====]

return {
  "nvim-telescope/telescope-frecency.nvim",
  enabled = false,
  config = function()
    require("telescope").setup({
      extensions = {
        frecency = {
          show_scores = false, -- Default: false
          -- If `true`, it shows confirmation dialog before any entries are removed from the DB
          -- If you want not to be bothered with such things and to remove stale results silently
          -- set db_safe_mode=false and auto_validate=true
          --
          -- This fixes an issue I had in which I couldn't close the floating
          -- window because I couldn't focus it
          db_safe_mode = false, -- Default: true
          -- If `true`, it removes stale entries count over than db_validate_threshold
          auto_validate = true, -- Default: true
          -- It will remove entries when stale ones exist more than this count
          db_validate_threshold = 10, -- Default: 10
          -- Show the path of the active filter before file paths.
          -- So if I'm in the `dotfiles-latest` directory it will show me that
          -- before the name of the file
          show_filter_column = false, -- Default: true
          -- I declare a workspace which I will use when calling frecency if I
          -- want to search for files in a specific path
          workspaces = {
            ["neobean_plugins"] = "$HOME/github/dotfiles-latest/neovim/neobean/lua/plugins",
          },
        },
      },
    })
    require("telescope").load_extension("frecency")
  end,
}
