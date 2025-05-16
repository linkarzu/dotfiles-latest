return {
  "m4xshen/hardtime.nvim",
  dependencies = { "MunifTanjim/nui.nvim" },
  -- Was told to use this event by m4xshen himself, in discord
  -- https://discord.com/channels/1323810827220029441/1371572869838012487/1371660878344097832
  event = "BufEnter",
  keys = {
    { "j", "v:count == 0 ? 'gj' : 'j'", mode = { "n", "x" }, expr = true, silent = true, desc = "Down" },
    { "k", "v:count == 0 ? 'gk' : 'k'", mode = { "n", "x" }, expr = true, silent = true, desc = "Up" },
  },
  opts = {},
}
