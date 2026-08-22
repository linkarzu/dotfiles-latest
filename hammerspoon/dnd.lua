local M = {}

local log = hs.logger.new("dnd", "info")
local RESULT_PATH = "/tmp/dnd-hammerspoon-result"
local CONTROL_CENTER_ITEM = "com.apple.menuextra.controlcenter"
local FOCUS_TILE = "controlcenter-focus-modes"
local MAX_NODES = 300

local function attribute(element, name)
	local ok, value = pcall(function()
		return element:attributeValue(name)
	end)
	return ok and value or nil
end

local function descendants(root, maxDepth)
	local results = {}
	local visited = 0

	local function visit(element, depth)
		if depth > maxDepth or visited >= MAX_NODES then
			return
		end
		visited = visited + 1
		table.insert(results, element)
		for _, child in ipairs(attribute(element, "AXChildren") or {}) do
			visit(child, depth + 1)
		end
	end

	visit(root, 0)
	return results
end

local function findByIdentifier(root, identifier, maxDepth)
	for _, element in ipairs(descendants(root, maxDepth)) do
		if attribute(element, "AXIdentifier") == identifier then
			return element
		end
	end
	return nil
end

local function perform(element, action)
	local ok = pcall(function()
		element:performAction(action)
	end)
	return ok
end

local function writeResult(ok, message)
	local file = io.open(RESULT_PATH, "w")
	if file then
		file:write((ok and "ok: " or "error: ") .. message .. "\n")
		file:close()
	end
	if ok then
		log.i(message)
	else
		log.e(message)
	end
end

local function retry(deadline, action, timeoutMessage, onTimeout)
	if action() then
		return
	end
	if hs.timer.secondsSinceEpoch() >= deadline then
		if onTimeout then
			onTimeout()
		else
			writeResult(false, timeoutMessage)
		end
		return
	end
	hs.timer.doAfter(0.05, function()
		retry(deadline, action, timeoutMessage, onTimeout)
	end)
end

function M.pressFocus()
	os.remove(RESULT_PATH)
	local app = hs.application.get("com.apple.controlcenter")
	if not app then
		writeResult(false, "Control Center is not running")
		return false
	end

	local root = hs.axuielement.applicationElement(app)
	local menuItem = findByIdentifier(root, CONTROL_CENTER_ITEM, 8)
	local menuFrame = menuItem and attribute(menuItem, "AXFrame")
	if not menuItem or not menuFrame then
		writeResult(false, "Could not find Control Center in the menu bar")
		return false
	end
	local originalMouse = hs.mouse.absolutePosition()
	local menuX = menuFrame.x + menuFrame.w / 2
	local menuScreen
	for _, screen in ipairs(hs.screen.allScreens()) do
		local frame = screen:fullFrame()
		if menuX >= frame.x and menuX < frame.x + frame.w then
			menuScreen = screen
			break
		end
	end
	menuScreen = menuScreen or hs.screen.mainScreen()
	local screenFrame = menuScreen:fullFrame()

	hs.eventtap.keyStroke({}, "escape", 0)
	hs.mouse.absolutePosition({ x = menuX, y = screenFrame.y })
	hs.timer.doAfter(0.4, function()
		menuItem = findByIdentifier(root, CONTROL_CENTER_ITEM, 8)
		if not menuItem or not perform(menuItem, "AXPress") then
			hs.mouse.absolutePosition(originalMouse)
			writeResult(false, "Could not open Control Center")
			return
		end

		retry(hs.timer.secondsSinceEpoch() + 3, function()
			local focusTile = findByIdentifier(root, FOCUS_TILE, 12)
			if not focusTile then
				return false
			end
			local priorValue = attribute(focusTile, "AXValue")
			if not perform(focusTile, "AXPress") then
				hs.mouse.absolutePosition(originalMouse)
				writeResult(false, "Could not press the Focus control")
				return true
			end
			hs.timer.doAfter(0.2, function()
				hs.eventtap.keyStroke({}, "escape", 0)
				hs.mouse.absolutePosition(originalMouse)
				writeResult(true, "Pressed Focus control (prior AXValue " .. tostring(priorValue) .. ")")
			end)
			return true
		end, "Timed out waiting for the Focus control", function()
			hs.eventtap.keyStroke({}, "escape", 0)
			hs.mouse.absolutePosition(originalMouse)
			writeResult(false, "Timed out waiting for the Focus control")
		end)
	end)
	return true
end

return M
