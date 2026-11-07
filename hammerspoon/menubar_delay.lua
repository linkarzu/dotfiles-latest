-- macOS has no autohide-delay for the menu bar like the Dock has, it shows up
-- the moment the cursor touches the top edge. This holds the cursor 1pt below
-- the top edge, and only lets it touch the edge after it has rested there for
-- M.delay seconds.
local M = {}
M.delay = 2
-- The cursor has to go this far down before the menu bar counts as hidden again.
M.releaseDistance = 50
-- Left free so the top hot corners still work.
M.cornerSize = 5

local released = false
local edges = {}

-- Top edges that have no screen above them, the only ones the menu bar shows on.
local function refreshEdges()
  edges = {}
  local frames = {}
  for _, screen in ipairs(hs.screen.allScreens()) do
    table.insert(frames, screen:fullFrame())
  end
  for _, f in ipairs(frames) do
    local covered = false
    for _, other in ipairs(frames) do
      if math.abs(other.y + other.h - f.y) < 1 and other.x < f.x + f.w and other.x + other.w > f.x then
        covered = true
      end
    end
    if not covered then table.insert(edges, f) end
  end
end

local function edgeAt(pos)
  for _, f in ipairs(edges) do
    if pos.x >= f.x and pos.x < f.x + f.w and pos.y >= f.y and pos.y < f.y + f.h then return f end
  end
end

local function stopTimer()
  if M.timer then
    M.timer:stop()
    M.timer = nil
  end
end

local function onMove(event)
  local pos = event:location()
  local f = edgeAt(pos)
  if not f then return false end
  local dy = pos.y - f.y
  if released then
    if dy > M.releaseDistance then released = false end
    return false
  end
  local inCorner = pos.x < f.x + M.cornerSize or pos.x > f.x + f.w - M.cornerSize
  if dy < 1 and not inCorner then
    hs.mouse.absolutePosition({ x = pos.x, y = f.y + 1 })
    if not M.timer then
      M.timer = hs.timer.doAfter(M.delay, function()
        M.timer = nil
        local p = hs.mouse.absolutePosition()
        if p.y - f.y <= 2 then
          released = true
          hs.mouse.absolutePosition({ x = p.x, y = f.y })
        end
      end)
    end
  elseif dy > 2 then
    stopTimer()
  end
  return false
end

function M.start()
  if not M.tap then
    refreshEdges()
    M.screenWatcher = hs.screen.watcher.new(refreshEdges):start()
    M.tap = hs.eventtap.new({ hs.eventtap.event.types.mouseMoved }, onMove):start()
  end
  return M
end

function M.stop()
  stopTimer()
  if M.tap then
    M.tap:stop()
    M.tap = nil
  end
  if M.screenWatcher then
    M.screenWatcher:stop()
    M.screenWatcher = nil
  end
  released = false
  return M
end

return M
