return {
  "m4xshen/hardtime.nvim",
  enabled = true,
  dependencies = { "MunifTanjim/nui.nvim" },
  -- Was told to use this event by m4xshen himself, in discord
  -- https://discord.com/channels/1323810827220029441/1371572869838012487/1371660878344097832
  event = "BufEnter",
  keys = {
    -- { "j", "v:count == 0 ? 'gj' : 'j'", mode = { "n", "x" }, expr = true, silent = true, desc = "Down" },
    -- { "k", "v:count == 0 ? 'gk' : 'k'", mode = { "n", "x" }, expr = true, silent = true, desc = "Up" },
  },
  opts = function(_, opts)
    -- make sure the default table exists
    opts.restricted_keys = opts.restricted_keys or {}
    -- do NOT restrict gj / gk
    opts.restricted_keys["gj"] = false
    opts.restricted_keys["gk"] = false
    opts.max_count = 12
  end,
}
