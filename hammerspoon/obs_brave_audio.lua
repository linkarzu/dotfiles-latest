local M = {}

local log = hs.logger.new("obs-brave-audio", "info")
local RESULT_PATH = "/tmp/obs-brave-audio-hammerspoon-result"
local PROPERTIES_TITLE = "Properties for '7-brave-audio'"
local BRAVE_TITLE = "Brave Browser"
local MAX_NODES = 500

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

local function perform(element, action)
	local ok, result = pcall(function()
		return element:performAction(action)
	end)
	return ok and result ~= false
end

local function showMenu(element)
	return pcall(function()
		element:performAction("AXShowMenu")
	end)
end

local function propertiesWindow(root)
	for _, window in ipairs(attribute(root, "AXWindows") or {}) do
		if attribute(window, "AXTitle") == PROPERTIES_TITLE then
			return window
		end
	end
	return nil
end

local function applicationMenu(window)
	local menus = {}
	for _, element in ipairs(descendants(window, 12)) do
		if attribute(element, "AXRole") == "AXMenuButton" then
			table.insert(menus, element)
		end
	end
	table.sort(menus, function(left, right)
		local leftFrame = attribute(left, "AXFrame")
		local rightFrame = attribute(right, "AXFrame")
		return leftFrame and rightFrame and leftFrame.y < rightFrame.y
	end)
	return menus[2]
end

local function click(element)
	local frame = attribute(element, "AXFrame")
	if not frame then
		return false
	end
	hs.eventtap.leftClick({ x = frame.x + frame.w / 2, y = frame.y + frame.h / 2 })
	return true
end

local function popupItems(root, menuFrame)
	local items = {}
	for _, element in ipairs(descendants(root, 14)) do
		if attribute(element, "AXRole") == "AXMenuItem" then
			local frame = attribute(element, "AXFrame")
			if frame and math.abs(frame.x - (menuFrame.x - 8)) < 30 and math.abs(frame.w - menuFrame.w) < 30 then
				table.insert(items, element)
			end
		end
	end
	table.sort(items, function(left, right)
		return attribute(left, "AXFrame").y < attribute(right, "AXFrame").y
	end)
	return items
end

local function retry(deadline, action, timeoutMessage)
	local done = action()
	if done then
		return
	end
	if hs.timer.secondsSinceEpoch() >= deadline then
		writeResult(false, timeoutMessage)
		return
	end
	hs.timer.doAfter(0.03, function()
		retry(deadline, action, timeoutMessage)
	end)
end

local function context()
	local app = hs.application.get("com.obsproject.obs-studio") or hs.application.find("OBS")
	if not app then
		return nil, nil, nil, nil, nil, "OBS is not running"
	end
	local root = hs.axuielement.applicationElement(app)
	local window = propertiesWindow(root)
	local menu = window and applicationMenu(window)
	local frame = menu and attribute(menu, "AXFrame")
	if not menu or not frame then
		return nil, nil, nil, nil, nil, "Could not find the Application menu"
	end
	return app, root, window, menu, frame, nil
end

local function selectNamedApplication(title, exclude)
	os.remove(RESULT_PATH)
	local app, root, _, menu, frame, err = context()
	if not app then
		writeResult(false, err)
		return false
	end
	if not click(menu) then
		writeResult(false, "Could not open the Application menu")
		return false
	end
	hs.timer.doAfter(0.3, function()
		local selected
		for _, item in ipairs(popupItems(root, frame)) do
			local itemTitle = attribute(item, "AXTitle")
			if title and itemTitle == title then
				selected = item
				break
			end
			if not title and itemTitle and itemTitle:match("%S") and not exclude[itemTitle] then
				selected = item
				break
			end
		end
		if not selected or not click(selected) then
			writeResult(false, "Could not click " .. (title or "an intermediate application"))
			return
		end
		writeResult(true, "Clicked " .. (title or attribute(selected, "AXTitle")))
	end)
	return true
end

function M.selectIntermediate()
	return selectNamedApplication(nil, { [BRAVE_TITLE] = true, ["OBS Studio"] = true })
end

function M.selectBrave()
	return selectNamedApplication(BRAVE_TITLE, {})
end

function M.pressOk()
	os.remove(RESULT_PATH)
	retry(hs.timer.secondsSinceEpoch() + 5, function()
		local _, root, window, menu = context()
		if not root or attribute(menu, "AXTitle") ~= BRAVE_TITLE then
			return false
		end
		for _, element in ipairs(descendants(window, 12)) do
			if attribute(element, "AXRole") == "AXButton" and attribute(element, "AXTitle") == "OK" then
				if perform(element, "AXPress") then
					writeResult(true, "Pressed OK")
				else
					writeResult(false, "Could not press OK")
				end
				return true
			end
		end
		return false
	end, "Timed out waiting for Application menu to select Brave Browser")
	return true
end

function M.select()
	os.remove(RESULT_PATH)
	local app = hs.application.get("com.obsproject.obs-studio") or hs.application.find("OBS")
	if not app then
		writeResult(false, "OBS is not running")
		return false
	end

	local root = hs.axuielement.applicationElement(app)
	local window = propertiesWindow(root)
	local menu = window and applicationMenu(window)
	local menuFrame = menu and attribute(menu, "AXFrame")
	if not menu or not menuFrame then
		writeResult(false, "Could not find the Application menu")
		return false
	end

	app:activate(true)
	if not showMenu(menu) then
		writeResult(false, "Could not open the Application menu")
		return false
	end

	hs.timer.doAfter(0.15, function()
	retry(hs.timer.secondsSinceEpoch() + 3, function()
		local intermediate
		for _, item in ipairs(popupItems(root, menuFrame)) do
			local title = attribute(item, "AXTitle")
			if title and title:match("%S") and title ~= BRAVE_TITLE and title ~= "OBS Studio" then
				intermediate = item
				break
			end
		end
		if not intermediate then
			return false
		end
		if not click(intermediate) then
			writeResult(false, "Could not select an intermediate application")
			return true
		end

		retry(hs.timer.secondsSinceEpoch() + 3, function()
			local refreshedWindow = propertiesWindow(root)
			local refreshedMenu = refreshedWindow and applicationMenu(refreshedWindow)
			local refreshedFrame = refreshedMenu and attribute(refreshedMenu, "AXFrame")
			local refreshedTitle = refreshedMenu and attribute(refreshedMenu, "AXTitle")
			if not refreshedTitle or refreshedTitle == BRAVE_TITLE or refreshedTitle == "OBS Studio" then
				return false
			end
			if not refreshedFrame or not showMenu(refreshedMenu) then
				writeResult(false, "Could not reopen the Application menu")
				return true
			end

			hs.timer.doAfter(0.25, function()
				local braveItem
				for _, item in ipairs(popupItems(root, refreshedFrame)) do
					if attribute(item, "AXTitle") == BRAVE_TITLE then
						braveItem = item
						break
					end
				end
				if not braveItem or not click(braveItem) then
					writeResult(false, "Could not click Brave Browser")
					return
				end
				retry(hs.timer.secondsSinceEpoch() + 3, function()
							local finalWindow = propertiesWindow(root)
							local finalMenu = finalWindow and applicationMenu(finalWindow)
							if not finalMenu or attribute(finalMenu, "AXTitle") ~= BRAVE_TITLE then
								return false
							end
							for _, element in ipairs(finalWindow and descendants(finalWindow, 12) or {}) do
								if attribute(element, "AXRole") == "AXButton" and attribute(element, "AXTitle") == "OK" then
									if perform(element, "AXPress") then
										writeResult(true, "Selected intermediate application, then Brave Browser, then OK")
									else
										writeResult(false, "Could not press OK")
									end
									return true
								end
							end
							writeResult(false, "Could not find the OK button")
							return true
						end, "Timed out waiting for OBS to apply Brave Browser")
			end)
			return true
		end, "Timed out waiting for OBS to apply the intermediate application")
		return true
	end, "Timed out waiting for an intermediate application")
	end)
	return true
end

return M
