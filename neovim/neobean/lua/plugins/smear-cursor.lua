return {
  "sphamba/smear-cursor.nvim",
  -- enabled = vim.g.neovim_mode ~= "skitty", -- Disable plugin for skitty mode
  enabled = false,
  cond = vim.g.neovide == nil,
  opts = {
    stiffness = 0.8, -- 0.6      [0, 1]
    trailing_stiffness = 0.4, -- 0.4      [0, 1]
    stiffness_insert_mode = 0.6, -- 0.4      [0, 1]
    trailing_stiffness_insert_mode = 0.6, -- 0.4      [0, 1]
    distance_stop_animating = 0.5, -- 0.1      > 0
  },
}
