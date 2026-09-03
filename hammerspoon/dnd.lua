local M = {}

local log = hs.logger.new("dnd", "info")
local RESULT_PATH = "/tmp/dnd-hammerspoon-result"
local CONTROL_CENTER_ITEM = "com.apple.menuextra.controlcenter"
local FOCUS_TILE = "controlcenter-focus-modes"
local FOCUS_MENU_ITEM = "com.apple.menuextra.focusmode"
local DEFAULT_DND_ITEM = "focus-mode-activity-com.apple.donotdisturb.mode.default"
local MAX_NODES = 300
local retry
local writeResult

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
	local ok, result = pcall(function()
		return element:performAction(action)
	end)
	return ok and result ~= nil and result ~= false
end

local function focusValueIsEnabled(value)
	if value == true or value == 1 or value == "1" or value == "on" or value == "enabled" then
		return true
	end
	if value == false or value == 0 or value == "0" or value == "off" or value == "disabled" then
		return false
	end
	return nil
end

local function pressDirectFocusToggle(root, originalMouse, targetState)
	local menuItem = findByIdentifier(root, FOCUS_MENU_ITEM, 8)
	if not menuItem or not perform(menuItem, "AXPress") then
		return false
	end
	retry(hs.timer.secondsSinceEpoch() + 3, function()
		local dndItem = findByIdentifier(root, DEFAULT_DND_ITEM, 12)
		if not dndItem then
			return false
		end
		local priorValue = attribute(dndItem, "AXValue")
		local enabled = focusValueIsEnabled(priorValue)
		if enabled == nil then
			hs.eventtap.keyStroke({}, "escape", 0)
			hs.mouse.absolutePosition(originalMouse)
			writeResult(false, "Could not verify the Do Not Disturb control state")
			return true
		end
		local alreadyTarget = enabled == (targetState == "on")
		if alreadyTarget then
			hs.eventtap.keyStroke({}, "escape", 0)
			hs.mouse.absolutePosition(originalMouse)
			writeResult(true, "Do Not Disturb already matched requested state")
			return true
		end
		if not perform(dndItem, "AXPress") then
			hs.eventtap.keyStroke({}, "escape", 0)
			hs.mouse.absolutePosition(originalMouse)
			writeResult(false, "Could not press the Do Not Disturb control")
			return true
		end
		hs.timer.doAfter(0.2, function()
			hs.eventtap.keyStroke({}, "escape", 0)
			hs.mouse.absolutePosition(originalMouse)
			writeResult(true, "Pressed direct Do Not Disturb control (prior AXValue " .. tostring(priorValue) .. ")")
		end)
		return true
	end, "Timed out waiting for the direct Do Not Disturb control", function()
		hs.eventtap.keyStroke({}, "escape", 0)
		hs.mouse.absolutePosition(originalMouse)
		writeResult(false, "Timed out waiting for the direct Do Not Disturb control")
	end)
	return true
end

writeResult = function(ok, message)
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

retry = function(deadline, action, timeoutMessage, onTimeout)
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

function M.pressFocus(targetState)
	os.remove(RESULT_PATH)
	if targetState ~= "on" and targetState ~= "off" then
		writeResult(false, "Focus target state must be on or off")
		return false
	end
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
			if targetState == "off" then
				return pressDirectFocusToggle(root, originalMouse, targetState)
			end
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
			retry(hs.timer.secondsSinceEpoch() + 3, function()
				return pressDirectFocusToggle(root, originalMouse, targetState)
			end, "Timed out waiting for the direct Focus menu", function()
				hs.mouse.absolutePosition(originalMouse)
				writeResult(false, "Timed out waiting for the direct Focus menu")
			end)
		end)
	end)
	return true
end

return M
