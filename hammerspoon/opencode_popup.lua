local M = {}

local stateFile = "/tmp/sketchybar-opencode-popup.json"
local sketchybar = "/opt/homebrew/bin/sketchybar"
local popupWidth = 248
local rowHeight = 24
local borderWidth = 2
local fallbackTopOffset = 40
local fallbackRightOffset = 10
local font = "MesloLGM Nerd Font"
local canvases = {}
local rowActions = {}
local runningTasks = {}
local screenRefreshTimer
local currentState = {}

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

local function targetScreens(target)
	if target == "all" then
		return hs.screen.allScreens()
	end

	if target == "primary" or target == nil or target == "" then
		return { hs.screen.primaryScreen() }
	end

	local ok, screen = pcall(hs.screen.find, target)
	return { ok and screen or hs.screen.primaryScreen() }
end

local function popupFrame(screen, anchors, height)
	local screenFrame = screen:fullFrame()
	local x = screenFrame.x + screenFrame.w - popupWidth - fallbackRightOffset
	local y = screenFrame.y + fallbackTopOffset

	for _, anchor in pairs(anchors or {}) do
		local origin = anchor.origin
		local size = anchor.size
		if
			type(origin) == "table"
			and type(size) == "table"
			and type(origin[1]) == "number"
			and type(origin[2]) == "number"
			and type(size[1]) == "number"
			and type(size[2]) == "number"
		then
			local centerX = origin[1] + size[1] / 2
			local centerY = origin[2] + size[2] / 2
			if
				centerX >= screenFrame.x
				and centerX < screenFrame.x + screenFrame.w
				and centerY >= screenFrame.y
				and centerY < screenFrame.y + screenFrame.h
			then
				x = origin[1] + size[1] - popupWidth
				y = origin[2] + size[2]
				break
			end
		end
	end

	x = math.max(screenFrame.x, math.min(x, screenFrame.x + screenFrame.w - popupWidth))
	return { x = x, y = y, w = popupWidth, h = height }
end

local function runTask(path, arguments)
	local task
	local function complete(_, _, _)
		runningTasks[task] = nil
	end

	task = hs.task.new(path, complete, arguments)
	if task then
		runningTasks[task] = true
		if not task:start() then
			runningTasks[task] = nil
		end
	end
end

local function focusSession(state, id)
	local persistedState = hs.json.read(stateFile)
	if type(persistedState) == "table" then
		persistedState.visible = false
		hs.json.write(persistedState, stateFile, false, true)
	end
	M.hide()
	if type(state.popup_open_file) == "string" then
		os.remove(state.popup_open_file)
	end
	if type(state.focus_pending_file) == "string" then
		os.remove(state.focus_pending_file)
	end
	runTask(sketchybar, { "--trigger", "opencode_update" })
	if type(state.selector) == "string" and id then
		runTask(state.selector, { "--focus", tostring(id) })
	end
end

local function elementsFor(state, canvasKey)
	local colors = type(state.colors) == "table" and state.colors or {}
	local background = parseColor(colors.background, { red = 0, green = 0, blue = 0, alpha = 0.8 })
	local border = parseColor(colors.border, { white = 1 })
	local label = parseColor(colors.label, { white = 1 })
	local green = parseColor(colors.green, { red = 0.4, green = 1, blue = 0.6 })
	local blue = parseColor(colors.blue, { red = 0.4, green = 0.7, blue = 1 })
	local grey = parseColor(colors.grey, { white = 0.5 })
	local rows = type(state.rows) == "table" and state.rows or {}
	local height = math.max(#rows, 1) * rowHeight + borderWidth * 2
	local actions = {}
	local elements = {
		{
			type = "rectangle",
			action = "strokeAndFill",
			frame = { x = 0, y = 0, w = popupWidth, h = height },
			fillColor = background,
			strokeColor = border,
			strokeWidth = borderWidth,
			roundedRectRadii = { xRadius = 9, yRadius = 9 },
		},
	}

	for index, row in ipairs(rows) do
		if type(row) ~= "table" then
			row = { icon = "-", label = tostring(row), status = "idle" }
		end
		local top = borderWidth + (index - 1) * rowHeight
		local rowID = "row:" .. index
		local statusColor = row.status == "attention" and green or row.status == "running" and blue or grey
		local labelColor = row.status == "attention" and green or label

		elements[#elements + 1] = {
			type = "text",
			text = tostring(row.icon or "-"),
			frame = { x = 0, y = top + 3, w = 24, h = rowHeight - 3 },
			textAlignment = "center",
			textColor = statusColor,
			textFont = font,
			textSize = 13,
		}
		elements[#elements + 1] = {
			type = "text",
			text = tostring(row.label or ""),
			frame = { x = 24, y = top + 3, w = popupWidth - 32, h = rowHeight - 3 },
			textColor = labelColor,
			textFont = font,
			textSize = 13,
			textLineBreak = "truncateTail",
		}

		if row.id then
			actions[rowID] = row.id
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
	end

	rowActions[canvasKey] = actions
	return elements, height
end

local function renderOnScreen(state, screen)
	local canvasKey = screen:getUUID()
	local elements, height = elementsFor(state, canvasKey)
	local canvas = canvases[canvasKey]

	if not canvas then
		canvas = hs.canvas.new(popupFrame(screen, state.anchors, height))
		if not canvas then
			return
		end
		canvas
			:level("popUpMenu")
			:behavior({ "canJoinAllSpaces", "transient", "stationary" })
			:clickActivating(false)
			:mouseCallback(function(_, message, elementID)
				if message == "mouseUp" then
					local id = rowActions[canvasKey] and rowActions[canvasKey][elementID]
					if id then
						focusSession(currentState, id)
					end
				end
			end)
		canvases[canvasKey] = canvas
	else
		canvas:frame(popupFrame(screen, state.anchors, height))
	end

	canvas:replaceElements(elements):show()
end

function M.hide()
	for key, canvas in pairs(canvases) do
		canvas:delete()
		canvases[key] = nil
		rowActions[key] = nil
	end
end

function M.refresh()
	local state = hs.json.read(stateFile)
	if type(state) ~= "table" or state.visible ~= true or state.target == "active" or state.target == "off" then
		currentState = {}
		M.hide()
		return
	end
	state.target = type(state.target) == "string" and state.target or "primary"
	state.anchors = type(state.anchors) == "table" and state.anchors or {}
	currentState = state

	local wanted = {}
	for _, screen in ipairs(targetScreens(state.target)) do
		if screen then
			local key = screen:getUUID()
			wanted[key] = true
			renderOnScreen(state, screen)
		end
	end

	for key, canvas in pairs(canvases) do
		if not wanted[key] then
			canvas:delete()
			canvases[key] = nil
			rowActions[key] = nil
		end
	end
end

M.screenWatcher = hs.screen.watcher.new(function()
	if screenRefreshTimer then
		screenRefreshTimer:stop()
	end
	runTask(sketchybar, { "--trigger", "opencode_update" })
	screenRefreshTimer = hs.timer.doAfter(1, M.refresh)
end):start()

M.refresh()

return M
