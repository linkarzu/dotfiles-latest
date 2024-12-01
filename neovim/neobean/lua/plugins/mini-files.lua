-- Filename: ~/github/dotfiles-latest/neovim/neobean/lua/plugins/mini-files.lua
-- ~/github/dotfiles-latest/neovim/neobean/lua/plugins/mini-files.lua
--
-- https://github.com/echasnovski/mini.files
--
-- I got this configuration from LazyVim.org
-- http://www.lazyvim.org/extras/editor/mini-files

-- I migrated my custom keymaps config and also the git status config to
-- separate files, as this file was growing too big
-- I also use this file as a centralized place for all the different keymaps,
-- including my custom ones
--
-- Load external modules first
local mini_files_km = require("config.modules.mini-files-km")
local mini_files_git = require("config.modules.mini-files-git")

return {
  "echasnovski/mini.files",
  opts = function(_, opts)
    -- I didn't like the default mappings, so I modified them
    -- Module mappings created only inside explorer.
    -- Use `''` (empty string) to not create one.
    opts.mappings = vim.tbl_deep_extend("force", opts.mappings or {}, {
      close = "<esc>",
      -- Use this if you want to open several files
      go_in = "l",
      -- This opens the file, but quits out of mini.files (default L)
      go_in_plus = "<CR>",
      -- I swapped the following 2 (default go_out: h)
      -- go_out_plus: when you go out, it shows you only 1 item to the right
      -- go_out: shows you all the items to the right
      go_out = "H",
      go_out_plus = "h",
      -- Default <BS>
      reset = "<BS>",
      -- Default @
      reveal_cwd = ".",
      show_help = "g?",
      -- Default =
      synchronize = "s",
      trim_left = "<",
      trim_right = ">",

      -- Below I created an autocmd with the "," keymap to open the highlighted
      -- directory in a tmux pane on the right
    })

    opts.custom_keymaps = {
      open_tmux_pane = ",",
      copy_to_clipboard = "<space>yy",
      zip_and_copy = "<space>yz",
      paste_from_clipboard = "<space>p",
      copy_path = "<M-c>",
      -- Don't use "i" as it conflicts wit insert mode
      preview_image = "<space>i",
      preview_image_popup = "<M-i>",
    }

    opts.windows = vim.tbl_deep_extend("force", opts.windows or {}, {
      preview = true,
      width_focus = 30,
      width_preview = 50,
    })

    opts.options = vim.tbl_deep_extend("force", opts.options or {}, {
      -- Whether to use for editing directories
      -- Disabled by default in LazyVim because neo-tree is used for that
      use_as_default_explorer = true,
      -- If set to false, files are moved to the trash directory
      -- To get this dir run :echo stdpath('data')
      -- ~/.local/share/neobean/mini.files/trash
      permanent_delete = false,
    })
    return opts
  end,

  keys = {
    {
      "<leader>e",
      function()
        require("mini.files").open(vim.api.nvim_buf_get_name(0), true)
      end,
      desc = "Open mini.files (Directory of Current File)",
    },
    {
      "<leader>E",
      function()
        require("mini.files").open(vim.uv.cwd(), true)
      end,
      desc = "Open mini.files (cwd)",
    },
  },

  config = function(_, opts)
    -- Set up mini.files
    require("mini.files").setup(opts)
    -- Load custom keymaps
    mini_files_km.setup(opts)
    -- Load Git integration
    mini_files_git.setup()
  end,
}
