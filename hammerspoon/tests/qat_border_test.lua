-- Standalone Lua 5.4+ test; all Hammerspoon APIs below are inert mocks.
local palette = '# linkarzu_color02="#ffffff"\nlinkarzu_color04="#987afb"\n'
  .. 'linkarzu_color020=#ffffff\nother_linkarzu_color02=#ffffff\n  linkarzu_color02="#01aB09"  \n'
local expectedColor, opens, closes = "#01aB09", 0, 0
local savedOpen, savedHs = io.open, hs
local function openPalette(path, mode)
  assert(path == os.getenv("HOME") .. "/github/dotfiles-latest/colorscheme/active/active-colorscheme.sh")
  assert(mode == "r")
  opens = opens + 1
  if not palette then return nil, "mock missing palette" end
  local contents, closed = palette, false
  return {
    lines = function()
      assert(not closed)
      return (contents .. "\n"):gmatch("([^\n]*)\n")
    end,
    close = function()
      assert(not closed)
      closed, closes = true, closes + 1
      return true
    end,
  }
end
local qat = "net.kovidgoyal.kitty-quick-access"
local bundle, id, pid, focused = qat, 7, 42, true
local bounds = { X = 100, Y = 80, Width = 640, Height = 420 }
local target = {
  kCGWindowNumber = id, kCGWindowOwnerPID = pid, kCGWindowBounds = bounds,
  kCGWindowLayer = 8.0, kCGWindowIsOnscreen = true, kCGWindowAlpha = 1,
}
local windows, failure, enumerations, creations, timers, logs = { target }, nil, 0, 0, 0, {}
local app = { bundleID = function() return bundle end, pid = function() return pid end }
local window = {
  application = function() return app end, id = function() return id end,
  subrole = function() return "AXUnknown" end,
  -- Give AX a different frame to prove drawing uses the full CG bounds instead.
  frame = function() return { x = 100, y = 108, w = 640, h = 392 } end,
}
hs = {
  window = {
    focusedWindow = function()
      if failure == "focus" then error("focus unavailable") end
      return focused and window or nil
    end,
    list = function(onscreen)
      assert(onscreen == true)
      enumerations = enumerations + 1
      if failure == "list" then error("CG list unavailable") end
      return windows
    end,
  },
  canvas = { new = function(frame)
    creations = creations + 1
    local c = { geometry = frame, draws = 0 }
    function c:behavior(value) self.behaviors = value; return self end
    function c:clickActivating(value) self.activating = value; return self end
    function c:mouseCallback(value) assert(value == nil); self.callbackCleared = true; return self end
    function c:frame(value) self.geometry = value; self.draws = self.draws + 1; return self end
    function c:level(value)
      assert(type(value) == "number" and math.type(value) == "integer")
      self.layer = value; self.draws = self.draws + 1; return self
    end
    function c:replaceElements(value, ...)
      assert(select("#", ...) == 0)
      self.element = value; self.draws = self.draws + 1; return self
    end
    function c:show() self.visible = true; self.draws = self.draws + 1; return self end
    function c:hide() self.visible = false; return self end
    function c:delete() assert(not self.deleted); self.deleted = true; self.visible = false end
    return c
  end },
  timer = { doEvery = function(interval, callback)
    assert(interval == 0.1)
    timers = timers + 1
    local t = { running = true, paletteOpens = opens }
    function t.callback()
      local reads = opens
      callback()
      assert(opens == reads, "ordinary refresh ticks must not read the palette")
    end
    function t:stop() assert(self.running); self.running = false end
    return t
  end },
  printf = function(format, ...) logs[#logs + 1] = string.format(format, ...) end,
}
local source = (arg[0]:match("^(.*[/])") or "./") .. "../qat_border.lua"
local M

local function reload(value, valid)
  palette = value
  local reads, closed = opens, closes
  assert(M.reloadPalette() == valid)
  assert(opens == reads + 1 and closes == closed + (value and 1 or 0))
end

local function checkFrame()
  local c, b = assert(M.canvas), bounds
  local f, e = c.geometry, c.element
  local r, half = e.frame, e.strokeWidth / 2
  assert(c.visible and c.layer == target.kCGWindowLayer + 1)
  assert(f.x == b.X - 2 and f.y == b.Y - 2 and f.w == b.Width + 4 and f.h == b.Height + 4)
  assert(e.type == "rectangle" and e.action == "stroke" and e.fillColor == nil)
  assert(e.strokeWidth == 2 and e.strokeColor.hex == expectedColor)
  assert(r.x == 1 and r.y == 1 and r.w == b.Width + 2 and r.h == b.Height + 2)
  -- Inner stroke edges coincide with the native frame; outer edges are 2pt out.
  assert(f.x + r.x + half == b.X and f.y + r.y + half == b.Y)
  assert(f.x + r.x + r.w - half == b.X + b.Width and f.y + r.y + r.h - half == b.Y + b.Height)
  assert(f.x + r.x - half == b.X - 2 and f.y + r.y - half == b.Y - 2)
  assert(f.x + r.x + r.w + half == b.X + b.Width + 2 and f.y + r.y + r.h + half == b.Y + b.Height + 2)
  assert(c.activating == false and c.callbackCleared)
  assert(table.concat(c.behaviors, ",") == "canJoinAllSpaces,fullScreenAuxiliary,transient")
end

local ok, err = xpcall(function()
  io.open = openPalette
  M = dofile(source)
  assert(creations == 0 and timers == 0 and enumerations == 0 and opens == 0)

  -- Startup reads GREEN (not slot04 or the fallback) before creating its timer.
  assert(M.start() == M)
  local c, t = M.canvas, M.timer
  checkFrame()
  assert(c.draws == 4 and creations == 1 and timers == 1)
  assert(opens == 1 and closes == 1 and t.paletteOpens == 1)
  palette = "linkarzu_color02=#ffffff"
  assert(M.start() == M and M.canvas == c and M.timer == t and timers == 1)
  t.callback()
  checkFrame()
  assert(opens == 1 and closes == 1 and c.draws == 4 and creations == 1 and #logs == 0)

  -- Both literal forms preserve leading zeroes and recolor unchanged geometry immediately.
  for _, case in ipairs({
    { "linkarzu_color02=#001aB2", "#001aB2" },
    { 'linkarzu_color02="#0C0203"', "#0C0203" },
  }) do
    local previous, oldHex, draws = c.element.strokeColor, expectedColor, c.draws
    expectedColor = case[2]
    reload(case[1], true)
    checkFrame()
    assert(M.canvas == c and creations == 1 and M.timer == t and timers == 1 and c.draws == draws + 4)
    assert(c.element.strokeColor ~= previous and previous.hex == oldHex)
    local current, count = c.element.strokeColor, enumerations
    reload(palette, true)
    assert(c.draws == draws + 4 and c.element.strokeColor == current and enumerations == count)
    t.callback()
    assert(c.draws == draws + 4)
  end

  -- Invalid/missing palettes retain the last valid color, including on the next redraw.
  for _, value in ipairs({
    false, -- Missing file.
    "",
    '# linkarzu_color02="#123456"\nlinkarzu_color04=#123456\n'
      .. 'linkarzu_color020=#123456\nother_linkarzu_color02=#123456',
    "linkarzu_color02=#12g456", "linkarzu_color02=#12345", "linkarzu_color02=#1234567",
    'linkarzu_color02="#123456', 'linkarzu_color02=#123456"',
    "linkarzu_color02=#123456 # comment", 'linkarzu_color02="#123456" # comment',
  }) do
    local previous, draws = c.element.strokeColor, c.draws
    reload(value, false)
    t.callback()
    assert(c.draws == draws and c.element.strokeColor == previous and M.canvas == c)
    assert(creations == 1 and timers == 1 and M.timer == t and t.running)
    bounds.X = bounds.X + 1
    t.callback()
    checkFrame()
  end

  -- Non-QAT focus and absent focus hide without any CG enumeration.
  local count = enumerations
  bundle = "com.apple.Terminal"
  t.callback()
  assert(not c.visible and enumerations == count and t.running)
  bundle = qat
  t.callback()
  checkFrame()
  count, focused = enumerations, false
  t.callback()
  assert(not c.visible and enumerations == count and t.running)
  focused = true
  t.callback()
  checkFrame()

  -- Stale AX focus cannot keep an absent, hidden, transparent, or mismatched CG window visible.
  windows = {}
  t.callback()
  assert(not c.visible and t.running)
  -- A palette notification while QAT is hidden recolors only on the next show.
  local draws, previous = c.draws, c.element.strokeColor
  expectedColor = "#00Aa10"
  reload('linkarzu_color02="#00Aa10"', true)
  assert(not c.visible and c.draws == draws and c.element.strokeColor == previous)
  assert(M.canvas == c and creations == 1 and M.timer == t and timers == 1)
  windows = { target }
  t.callback()
  checkFrame()
  for _, case in ipairs({
    { "kCGWindowIsOnscreen", false }, { "kCGWindowAlpha", 0 },
    { "kCGWindowNumber", id + 1 }, { "kCGWindowOwnerPID", pid + 1 },
  }) do
    local key, saved = case[1], target[case[1]]
    target[key] = case[2]
    t.callback()
    assert(not c.visible and t.running and M.canvas == c)
    target[key] = saved
    t.callback()
    checkFrame()
  end

  -- Reuse the canvas across negative coordinates and each independent cache-key change.
  bounds.X, bounds.Y = -1300, -800
  t.callback()
  checkFrame()
  for _, key in ipairs({ "X", "Y", "Width", "Height", "id", "pid", "layer" }) do
    local draws = c.draws
    if key == "id" then id = id + 1; target.kCGWindowNumber = id
    elseif key == "pid" then pid = pid + 1; target.kCGWindowOwnerPID = pid
    elseif key == "layer" then target.kCGWindowLayer = 19.0
    else bounds[key] = bounds[key] + 10 end
    t.callback()
    checkFrame()
    assert(M.canvas == c and c.draws == draws + 4 and creations == 1)
    t.callback()
    assert(c.visible and c.draws == draws + 4)
  end

  -- Invalid CG data and resolver exceptions must stop polling and delete stale drawings.
  for _, fault in ipairs({ "layer", "bounds", "focus", "list" }) do
    c, t = M.canvas, M.timer
    local logged = #logs
    if fault == "layer" then target.kCGWindowLayer = 1.5
    elseif fault == "bounds" then target.kCGWindowBounds = nil
    else failure = fault end
    t.callback()
    assert(not t.running and c.deleted and not c.visible and M.timer == nil and M.canvas == nil)
    assert(#logs == logged + 1 and logs[#logs]:match("^QAT border stopped: "))
    failure, target.kCGWindowLayer, target.kCGWindowBounds = nil, 19.0, bounds
    assert(M.stop() == M)
    assert(M.start() == M and M.canvas ~= c and M.timer ~= t and M.timer.running)
    checkFrame()
  end

  -- Stopped notifications may cache a color, but cannot recreate resources or resolve windows.
  c, t = M.canvas, M.timer
  assert(M.stop() == M and M.stop() == M)
  assert(c.deleted and not t.running and M.canvas == nil and M.timer == nil)
  local made, started = creations, timers
  count = enumerations
  expectedColor = "#000A10"
  reload("linkarzu_color02=#000A10", true)
  reload(false, false)
  assert(M.canvas == nil and M.timer == nil and creations == made and timers == started and enumerations == count)
  local reads, closed = opens, closes
  assert(M.start() == M and M.canvas ~= c and M.timer ~= t)
  assert(opens == reads + 1 and closes == closed and M.timer.paletteOpens == opens)
  checkFrame() -- Missing startup file keeps the color cached while stopped.

  -- A later restart reads the current palette, not the previously cached color.
  c, t = M.canvas, M.timer
  M.stop()
  palette, expectedColor = 'linkarzu_color02="#00bb22"', "#00bb22"
  reads, closed = opens, closes
  assert(M.start() == M and M.canvas ~= c and M.timer ~= t)
  assert(opens == reads + 1 and closes == closed + 1 and M.timer.paletteOpens == opens)
  checkFrame()
  M.stop()
  assert(creations == 7 and timers == 7 and #logs == 4)

  -- A fresh module falls back only when no valid palette has ever been loaded.
  M = dofile(source)
  palette, expectedColor = false, "#37f499"
  M.start()
  checkFrame()
  M.stop()
end, debug.traceback)
io.open, hs = savedOpen, savedHs
assert(ok, err)
print("qat_border_test: all scenarios passed")
