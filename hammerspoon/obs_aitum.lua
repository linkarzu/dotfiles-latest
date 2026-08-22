local M = {}

local log = hs.logger.new("obs-aitum", "info")
local URL_EVENT = "obs-aitum-start"
local DIAGNOSTIC_URL_EVENT = "obs-aitum-diagnose"
local DIAGNOSTIC_RESULT_PATH = "/tmp/obs-aitum-diagnose.txt"
local MAX_NODES = 2000

local function attribute(element, name)
	local ok, value = pcall(function()
		return element:attributeValue(name)
	end)
	return ok and value or nil
end

local function hasAction(element, action)
	local ok, actions = pcall(function()
		return element:actionNames()
	end)
	if not ok or not actions then
		return false
	end
	for _, candidate in ipairs(actions) do
		if candidate == action then
			return true
		end
	end
	return false
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

local function textMatches(element, expected)
	for _, name in ipairs({ "AXTitle", "AXDescription", "AXValue", "AXHelp" }) do
		if attribute(element, name) == expected then
			return true
		end
	end
	return false
end

local function visible(element)
	return attribute(element, "AXHidden") ~= true
end

local function findText(elements, expected, pressable)
	for _, element in ipairs(elements) do
		if textMatches(element, expected) and (not pressable or hasAction(element, "AXPress")) then
			return element
		end
	end
	return nil
end

local function frameCenterY(element)
	local frame = attribute(element, "AXFrame")
	if not frame then
		return nil
	end
	return frame.y + frame.h / 2, frame
end

local function selected(element)
	local value = attribute(element, "AXValue")
	return attribute(element, "AXSelected") == true or value == true or value == 1
end

local function press(element)
	local ok, result = pcall(function()
		return element:performAction("AXPress")
	end)
	return ok and result ~= nil and result ~= false
end

local function horizontalYouTubeLabel(elements)
	local mainHeading = findText(elements, "Main Canvas", false)
	local verticalHeading = findText(elements, "Vertical Canvas", false)
	local mainY = mainHeading and frameCenterY(mainHeading)
	local verticalY = verticalHeading and frameCenterY(verticalHeading)
	if not mainY or not verticalY then
		return nil, "Could not identify the Main Canvas and Vertical Canvas sections"
	end

	for _, element in ipairs(elements) do
		if visible(element) and textMatches(element, "YouTube Output") then
			local y = frameCenterY(element)
			if y and y > mainY and y < verticalY then
				return element
			end
		end
	end
	return nil, "Could not find Main Canvas YouTube Output"
end

local function adjacentStreamButton(label)
	local labelY, labelFrame = frameCenterY(label)
	if not labelY or not labelFrame then
		return nil
	end

	local parent = attribute(label, "AXParent")
	for _ = 1, 5 do
		if not parent then
			break
		end
		local best
		local bestScore
		for _, element in ipairs(descendants(parent, 4)) do
			if visible(element) and attribute(element, "AXDescription") == "Stream" and hasAction(element, "AXPress") then
				local buttonY, buttonFrame = frameCenterY(element)
				if buttonY and buttonFrame and buttonFrame.x > labelFrame.x then
					local verticalDistance = math.abs(buttonY - labelY)
					if verticalDistance <= math.max(labelFrame.h, buttonFrame.h) then
						local score = verticalDistance + math.max(0, buttonFrame.x - labelFrame.x) / 1000
						if not bestScore or score < bestScore then
							best = element
							bestScore = score
						end
					end
				end
			end
		end
		if best then
			return best
		end
		parent = attribute(parent, "AXParent")
	end
	return nil
end

local function fail(message)
	log.e(message)
	hs.alert.show("OBS Aitum: " .. message, 4)
end

local function writeDiagnosticResult(ok, message)
	local file = io.open(DIAGNOSTIC_RESULT_PATH, "w")
	if not file then
		return
	end
	file:write((ok and "ok: " or "error: ") .. message .. "\n")
	file:close()
end

local function runHorizontalYouTube(startOutput)
	local app = hs.application.get("com.obsproject.obs-studio") or hs.application.find("OBS")
	if not app then
		fail("OBS is not running")
		if not startOutput then
			writeDiagnosticResult(false, "OBS is not running")
		end
		return false
	end

	local root = hs.axuielement.applicationElement(app)
	local elements = descendants(root, 14)
	local aitumTab = findText(elements, "Aitum Multistream", true)
	if not aitumTab then
		fail("Could not find the Aitum Multistream dock tab")
		if not startOutput then
			writeDiagnosticResult(false, "Could not find the Aitum Multistream dock tab")
		end
		return false
	end

	local lowerThirdsTab = findText(elements, "lower-thirds", true)
	local function restoreLowerThirdsTab()
		return lowerThirdsTab ~= nil and press(lowerThirdsTab)
	end

	if not selected(aitumTab) and not press(aitumTab) then
		fail("Could not select the Aitum Multistream dock tab")
		if not startOutput then
			writeDiagnosticResult(false, "Could not select the Aitum Multistream dock tab")
		end
		return false
	end

	hs.timer.doAfter(0.2, function()
		local visibleElements = descendants(root, 14)
		local label, labelError = horizontalYouTubeLabel(visibleElements)
		if not label then
			fail(labelError)
			if not startOutput then
				writeDiagnosticResult(false, labelError)
			end
			restoreLowerThirdsTab()
			return
		end

		local button = adjacentStreamButton(label)
		if not button then
			fail("Could not find the Main Canvas YouTube Output button")
			if not startOutput then
				writeDiagnosticResult(false, "Could not find the Main Canvas YouTube Output button")
			end
			restoreLowerThirdsTab()
			return
		end
		if not startOutput then
			log.i("Found Main Canvas YouTube Output button")
			if restoreLowerThirdsTab() then
				writeDiagnosticResult(true, "Found Main Canvas YouTube Output button and restored lower-thirds")
				hs.alert.show("OBS Aitum: Main Canvas YouTube Output is ready", 3)
			else
				writeDiagnosticResult(false, "Found the output button but could not restore the prior tab")
				fail("Found the output button but could not restore the prior tab")
			end
			return
		end
		if not press(button) then
			fail("Could not press the Main Canvas YouTube Output button")
			restoreLowerThirdsTab()
			return
		end
		log.i("Pressed Main Canvas YouTube Output")

		hs.timer.doAfter(0.2, function()
			if not restoreLowerThirdsTab() then
				log.w("Could not restore the lower-thirds OBS dock tab")
			end
		end)
	end)
	return true
end

function M.startHorizontalYouTube()
	return runHorizontalYouTube(true)
end

function M.diagnoseHorizontalYouTube()
	return runHorizontalYouTube(false)
end

hs.urlevent.bind(URL_EVENT, function()
	M.startHorizontalYouTube()
end)

hs.urlevent.bind(DIAGNOSTIC_URL_EVENT, function()
	M.diagnoseHorizontalYouTube()
end)

return M
