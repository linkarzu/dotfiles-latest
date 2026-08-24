local M = {}

local sketchybar = "/opt/homebrew/bin/sketchybar"
local popupWidth = 170
local rowHeight = 35
local borderWidth = 2
local font = "MesloLGM Nerd Font"
local canvas
local canvasScreenUUID
local hostRects = {}
local outsideWatcher
local runningTasks = {}

local rows = {
	{ icon = "􀺽", label = "Preferences", action = { "/usr/bin/open", "-a", "System Preferences" } },
	{ icon = "􀒓", label = "Activity", action = { "/usr/bin/open", "-a", "Activity Monitor" } },
	{ icon = "􀒳", label = "Lock Screen", action = { "/usr/bin/pmset", "displaysleepnow" } },
	{
		icon = "",
		label = "BT Restart",
		action = {
			"/usr/bin/open",
			"btt://execute_assigned_actions_for_trigger/?uuid=A85489BC-14EE-4332-9985-EF0C39F97389",
		},
	},
	{
		icon = "",
		label = "Restart",
		action = { os.getenv("HOME") .. "/github/dotfiles-latest/scripts/macos/mac/misc/220-restartConfirm.sh" },
	},
}

local function parseColor(value, fallback)
	if type(value) ~= "string" then
		return fallback
	end

	local alpha, red, green, blue = value:match("^0x(%x%x)(%x%x)(%x%x)(%x%x)$")
	if not alpha then
		return fallback
	end

	return {
		alpha = tonumber(alpha, 16) / 255,
		red = tonumber(red, 16) / 255,
		green = tonumber(green, 16) / 255,
		blue = tonumber(blue, 16) / 255,
	}
end

local function queryItem(name)
	local output = hs.execute(string.format("%s --query %q", sketchybar, name), true)
	local ok, item = pcall(hs.json.decode, output or "")
	return ok and type(item) == "table" and item or nil
end

local function contains(frame, point)
	return point.x >= frame.x
		and point.x < frame.x + frame.w
		and point.y >= frame.y
		and point.y < frame.y + frame.h
end

local function rectFromBounds(bounds)
	local origin = type(bounds) == "table" and bounds.origin or nil
	local size = type(bounds) == "table" and bounds.size or nil
	if type(origin) ~= "table" or type(size) ~= "table" then
		return nil
	end
	if type(origin[1]) ~= "number" or type(origin[2]) ~= "number" then
		return nil
	end
	if type(size[1]) ~= "number" or type(size[2]) ~= "number" then
		return nil
	end
	return { x = origin[1], y = origin[2], w = size[1], h = size[2] }
end

local function hostRectFor(screen, bounds, mouse)
	local screenFrame = screen:fullFrame()
	local fallback
	hostRects = {}

	for _, value in pairs(bounds or {}) do
		local rect = rectFromBounds(value)
		if rect then
			hostRects[#hostRects + 1] = rect
			if contains(rect, mouse) then
				return rect
			end
			local center = { x = rect.x + rect.w / 2, y = rect.y + rect.h / 2 }
			if contains(screenFrame, center) then
				fallback = rect
			end
		end
	end

	return fallback
end

local function runAction(action)
	M.hide()
	local path = action[1]
	local arguments = {}
	for index = 2, #action do
		arguments[#arguments + 1] = action[index]
	end

	local task
	task = hs.task.new(path, function()
		runningTasks[task] = nil
	end, arguments)
	if task then
		runningTasks[task] = true
		if not task:start() then
			runningTasks[task] = nil
		end
	end
end

local function buildElements(host)
	local elements = {}
	local background = parseColor(host.popup and host.popup.background and host.popup.background.color, {
		red = 0,
		green = 0,
		blue = 0,
		alpha = 0.8,
	})
	local border = parseColor(host.popup and host.popup.background and host.popup.background.border_color, {
		white = 1,
	})
	local textColor = parseColor(host.label and host.label.color, { white = 1 })
	local height = #rows * rowHeight + borderWidth * 2

	elements[#elements + 1] = {
		type = "rectangle",
		action = "strokeAndFill",
		frame = { x = 0, y = 0, w = popupWidth, h = height },
		fillColor = background,
		strokeColor = border,
		strokeWidth = borderWidth,
		roundedRectRadii = { xRadius = 9, yRadius = 9 },
	}

	for index, row in ipairs(rows) do
		local top = borderWidth + (index - 1) * rowHeight
		local rowID = "row:" .. index

		elements[#elements + 1] = {
			type = "text",
			text = row.icon,
			frame = { x = 4, y = top + 8, w = 30, h = rowHeight - 8 },
			textAlignment = "center",
			textColor = textColor,
			textFont = font,
			textSize = 13,
		}
		elements[#elements + 1] = {
			type = "text",
			text = row.label,
			frame = { x = 40, y = top + 8, w = popupWidth - 48, h = rowHeight - 8 },
			textColor = textColor,
			textFont = font,
			textSize = 13,
			textLineBreak = "truncateTail",
		}
		elements[#elements + 1] = {
			type = "rectangle",
			id = rowID,
			action = "fill",
			frame = { x = borderWidth, y = top, w = popupWidth - borderWidth * 2, h = rowHeight },
			fillColor = { alpha = 0 },
			trackMouseByBounds = true,
			trackMouseUp = true,
		}
	end

	return elements, height
end

local function startOutsideWatcher()
	if outsideWatcher then
		outsideWatcher:stop()
	end
	outsideWatcher = hs.eventtap.new({ hs.eventtap.event.types.leftMouseDown, hs.eventtap.event.types.rightMouseDown }, function(event)
		local point = event:location()
		if canvas and contains(canvas:frame(), point) then
			return false
		end
		for _, rect in ipairs(hostRects) do
			if contains(rect, point) then
				return false
			end
		end
		hs.timer.doAfter(0, M.hide)
		return false
	end):start()
end

function M.hide()
	if canvas then
		canvas:delete()
		canvas = nil
	end
	canvasScreenUUID = nil
	hostRects = {}
	if outsideWatcher then
		outsideWatcher:stop()
		outsideWatcher = nil
	end
end

function M.toggle()
	local mouse = hs.mouse.absolutePosition()
	local screen = hs.mouse.getCurrentScreen()
	if not screen then
		return
	end

	local screenUUID = screen:getUUID()
	if canvas and canvasScreenUUID == screenUUID then
		M.hide()
		return
	end

	local host = queryItem("apple.logo")
	if not host then
		return
	end
	M.hide()
	local hostRect = hostRectFor(screen, host.bounding_rects, mouse)
	if not hostRect then
		return
	end

	local elements, height = buildElements(host)
	local screenFrame = screen:fullFrame()
	local x = math.max(screenFrame.x, math.min(hostRect.x, screenFrame.x + screenFrame.w - popupWidth))
	local y = hostRect.y + hostRect.h
	if y + height > screenFrame.y + screenFrame.h then
		y = hostRect.y - height
	end

	canvas = hs.canvas.new({ x = x, y = y, w = popupWidth, h = height })
	if not canvas then
		return
	end
	canvasScreenUUID = screenUUID
	canvas
		:level("popUpMenu")
		:behavior({ "canJoinAllSpaces", "transient", "stationary" })
		:clickActivating(false)
		:mouseCallback(function(_, message, elementID)
			if message ~= "mouseUp" then
				return
			end
			local index = tonumber(tostring(elementID):match("^row:(%d+)$"))
			if index and rows[index] then
				runAction(rows[index].action)
			end
		end)
		:replaceElements(elements)
		:show()
	startOutsideWatcher()
end

M.screenWatcher = hs.screen.watcher.new(M.hide):start()

return M
