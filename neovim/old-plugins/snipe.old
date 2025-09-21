-- Filename: ~/github/dotfiles-latest/neovim/neobean/lua/plugins/snipe.lua
-- ~/github/dotfiles-latest/neovim/neobean/lua/plugins/snipe.lua
--
-- https://github.com/leath-dub/snipe.nvim
return {
  -- "linkarzu/snipe.nvim",
  "leath-dub/snipe.nvim",
  keys = {
    {
      "<S-l>",
      function()
        require("snipe").open_buffer_menu()
      end,
      desc = "Open Snipe buffer menu",
    },
  },
  config = function()
    local snipe = require("snipe")
    snipe.setup({
      hints = {
        -- Charaters to use for hints
        -- make sure they don't collide with the navigation keymaps
        -- If you remove `j` and `k` from below, you can navigate in the plugin
        -- dictionary = "sadflewcmpghio",
        dictionary = "asfghl;wertyuiop",
      },
      navigate = {
        -- In case you changed your mind, provide a keybind that lets you
        -- cancel the snipe and close the window.
        cancel_snipe = "<esc>",
        -- cancel_snipe = "q",

        -- Remove "j" and "k" from your dictionary to navigate easier to delete
        -- Close the buffer under the cursor
        -- NOTE: Make sure you don't use the character below on your dictionary
        close_buffer = "d",
      },
      -- Define the way buffers are sorted by default
      -- Can be any of "default" (sort buffers by their number) or "last" (sort buffers by last accessed)
      -- If you choose "last", it will be modifying sorting the boffers by last
      -- accessed, so the "a" will always be assigned to your latest accessed
      -- buffer
      -- If you want the letters not to change, leave the sorting at default
      sort = "default",
    })
    -- vim.keymap.set(
    --   "n",
    --   "gba",
    --   snipe.create_buffer_menu_toggler({
    --     -- Limit the width of path buffer names
    --     max_path_width = 2,
    --   }),
    --   { desc = "[P]Snipe" }
    -- )
  end,
}
