local M = {}
local width = 2
local color = { hex = "#37f499" } -- Fallback until a valid palette is loaded.
local lastFrame

function M.reloadPalette()
  local file = io.open(os.getenv("HOME") .. "/github/dotfiles-latest/colorscheme/active/active-colorscheme.sh", "r")
  if not file then return false end
  local hex
  for line in file:lines() do
    -- SketchyBar's GREEN and JankyBorders both use this palette slot.
    local value = line:match("^%s*linkarzu_color02=(.-)%s*$")
    if value then
      hex = value:match('^"(.-)"$') or value
      break
    end
  end
  file:close()
  if not hex or not hex:match("^#%x%x%x%x%x%x$") then return false end
  if hex ~= color.hex then
    color = { hex = hex }
    lastFrame = nil
    if M.timer then M.refresh() end
  end
  return true
end

function M.refresh()
  local ok, err = pcall(function()
    -- QAT windows have AXUnknown subroles, so bypass the normal window filter.
    local window = hs.window.focusedWindow()
    local app = window and window:application()
    local target
    if app and app:bundleID() == "net.kovidgoyal.kitty-quick-access" then
      local id, pid = window:id(), app:pid()
      -- A persistent QAT process is not proof that its window is still shown.
      for _, candidate in ipairs(hs.window.list(true)) do
        if candidate.kCGWindowNumber == id and candidate.kCGWindowOwnerPID == pid
          and candidate.kCGWindowIsOnscreen and candidate.kCGWindowAlpha > 0 then
          target = candidate
          break
        end
      end
    end

    if not target then
      if M.canvas then M.canvas:hide() end
      lastFrame = nil
      return
    end

    local bounds = target.kCGWindowBounds
    local level = assert(math.tointeger(target.kCGWindowLayer)) + 1
    local frameKey = table.concat({
      target.kCGWindowOwnerPID, target.kCGWindowNumber, level,
      bounds.X, bounds.Y, bounds.Width, bounds.Height,
    }, ":")
    if frameKey == lastFrame then return end

    local frame = {
      x = bounds.X - width, y = bounds.Y - width,
      w = bounds.Width + 2 * width, h = bounds.Height + 2 * width,
    }
    if not M.canvas then
      M.canvas = assert(hs.canvas.new(frame))
      M.canvas
        :behavior({ "canJoinAllSpaces", "fullScreenAuxiliary", "transient" })
        :clickActivating(false)
        :mouseCallback(nil)
    end

    -- The stroke is centered on its path; keep it entirely outside the QAT.
    M.canvas:frame(frame):level(level):replaceElements({
      type = "rectangle",
      action = "stroke",
      strokeWidth = width,
      strokeColor = color,
      frame = {
        x = width / 2, y = width / 2,
        w = bounds.Width + width, h = bounds.Height + width,
      },
    }):show()
    lastFrame = frameKey
  end)
  if not ok then
    M.stop()
    hs.printf("QAT border stopped: %s", tostring(err))
  end
end

function M.start()
  if not M.timer then
    M.reloadPalette()
    M.timer = hs.timer.doEvery(0.1, M.refresh)
    M.refresh()
  end
  return M
end

function M.stop()
  if M.timer then
    M.timer:stop()
    M.timer = nil
  end
  if M.canvas then
    M.canvas:delete()
    M.canvas = nil
  end
  lastFrame = nil
  return M
end

return M
