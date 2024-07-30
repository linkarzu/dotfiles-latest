-- Filename: ~/github/dotfiles-latest/neovim/neobean/lua/plugins/snipe.lua
-- ~/github/dotfiles-latest/neovim/neobean/lua/plugins/snipe.lua
--
-- https://github.com/leath-dub/snipe.nvim
return {
  "linkarzu/snipe.nvim",
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
        -- cancel_snipe = "<esc>",
        cancel_snipe = "q",

        -- Close the buffer under the cursor
        -- Remove "j" and "k" from your dictionary to navigate easier to delete
        -- NOTE: Make sure you don't use the character below on your dictionary
        close_buffer = "d",
      },
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
