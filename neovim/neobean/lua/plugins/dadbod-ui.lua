-- I use 3 plugins for this to work properly, but I only add a single file,
-- which is the current one, and the other 2 plugins are listed under dependencies
-- These dependencies will be automatically installed

--[=====[

https://github.com/tpope/vim-dadbod
Vim plugin for interacting with databases
Connections are specified with a single URL
:DB mysql://root:pass@mysql.home.linkarzu.com:3310 SHOW DATABASES;

https://github.com/kristijanhusak/vim-dadbod-ui
To add a new dtabase, toggle DBUI, then hit capital `A` to add a new connection
mysql://root:pass@mysql.home.linkarzu.com:3310
mysql://root:pass@mariadb.home.linkarzu.com:3309/
postgres://postgres:pass@postgres.home.linkarzu.com:5432/
Then you will be asked for the name of the database that will show in the toogle

https://github.com/kristijanhusak/vim-dadbod-completion

-------------------------------------------------------------------------------

postgres
- Lets say I'm on macOS and I want to connect to a postgres DB
- I need to have psql installed, otherwise I won't be able to connect to the databases
- So install it with
  - `brew install postgresql@15`
  - Installation command found in `https://www.postgresql.org/download/macosx/`
- Then you can check the version with 
  - `psql --version`

-------------------------------------------------------------------------------

- I found the below file in this thread that helped me solve the autocompletion
  issue I has having.
- I had to add the cmp configg to `config/autocmds.lua`
  `https://github.com/kristijanhusak/vim-dadbod-completion/issues/53#issuecomment-1705335855`
- This thread also pointed me to the plugin's creator dotfiles
- The file below is the one that the dadbod-ui creator uses, so that's the config I'm using
  `https://github.com/kristijanhusak/neovim-config/blob/master/nvim/lua/partials/plugins/db.lua`

-------------------------------------------------------------------------------

How to's
- When dadbod is open press `?` to look at the help
- <Leader>W - (sql) Save currently opened query
  - That is an uppercase `W`
  - This will save the query in the `vim.g.db_ui_save_location` location configured below

--]=====]

return {
  "kristijanhusak/vim-dadbod-ui",
  dependencies = {
    { "tpope/vim-dadbod" },
    { "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" } },
  },
  keys = { -- Mapping to toggle DBUI
    { "<leader>d", "<cmd>DBUIToggle<CR>", desc = "Toggle DBUI" },
  },
  cmd = {
    "DBUI",
    "DBUIToggle",
    "DBUIAddConnection",
    "DBUIFindBuffer",
  },
  init = function()
    vim.g.db_ui_show_help = 0
    vim.g.db_ui_win_position = "right"
    vim.g.db_ui_use_nerd_fonts = 1
    vim.g.db_ui_use_nvim_notify = 1

    -- This sets the location of the `connections.json` file, which includes the
    -- DB conection strings (includes passwords in plaintext, so do not track
    -- this file. Storing it in iCloud but this is only for my homelab)
    -- The default location for this is `~/.local/share/db_ui`
    vim.g.db_ui_save_location = "~/Library/Mobile Documents/com~apple~CloudDocs/db-ui"
    -- vim.g.db_ui_save_location = "~/.ssh/dbui"
    -- vim.g.db_ui_tmp_query_location = "~/github/dotfiles-latest/neovim/neobean/dadbod/queries"

    vim.g.db_ui_hide_schemas = { "pg_toast_temp.*" }
  end,
}
