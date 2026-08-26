local M = {}
local safeClick = require("safe_frontmost_click")

local log = hs.logger.new("obs-aitum", "info")
local URL_EVENT = "obs-aitum-start"
local DIAGNOSTIC_URL_EVENT = "obs-aitum-diagnose"
local START_RESULT_PATH = "/tmp/obs-aitum-start.txt"
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

local function findTextContaining(elements, expected)
	for _, element in ipairs(elements) do
		for _, name in ipairs({ "AXTitle", "AXDescription", "AXValue", "AXHelp" }) do
			local value = attribute(element, name)
			if type(value) == "string" and value:find(expected, 1, true) then
				return element
			end
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

local function press(element)
	local app = hs.application.get("com.obsproject.obs-studio") or hs.application.find("OBS")
	return safeClick.performAction(app, element, "AXPress")
end

local function click(element)
	local frame = attribute(element, "AXFrame")
	if not frame then
		return false
	end
	local app = hs.application.get("com.obsproject.obs-studio") or hs.application.find("OBS")
	return safeClick.leftClick(app, { x = frame.x + frame.w / 2, y = frame.y + frame.h / 2 })
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

local function writeStartResult(status, message)
	local file = io.open(START_RESULT_PATH, "w")
	if not file then
		return
	end
	file:write(status .. ": " .. message .. "\n")
	file:close()
end

local function dismissObsCrashReporter()
	local reporter = hs.application.find("Problem Reporter")
	if not reporter then
		return false, nil
	end
	local root = hs.axuielement.applicationElement(reporter)
	for _, window in ipairs(attribute(root, "AXWindows") or {}) do
		local elements = descendants(window, 8)
		local isObsReport = attribute(window, "AXTitle") == "Problem Report for OBS Studio"
			or findTextContaining(elements, "OBS Studio quit unexpectedly.") ~= nil
		if isObsReport then
			local okButton = findText(elements, "OK", true)
			if not okButton or not press(okButton) then
				return true, "Could not dismiss the OBS crash report"
			end
			log.w("Dismissed stale OBS crash report without reopening OBS")
			return true, nil
		end
	end
	return false, nil
end

local function dismissStreamReminders()
	local dismissed = 0
	for _, application in ipairs(hs.application.runningApplications()) do
		if application:name() == "osascript" then
			local root = hs.axuielement.applicationElement(application)
			for _, window in ipairs(attribute(root, "AXWindows") or {}) do
				if attribute(window, "AXTitle") == "Stream reminder" then
					local okButton = findText(descendants(window, 6), "OK", true)
					if not okButton or not press(okButton) then
						return false, "Could not dismiss a Stream reminder dialog"
					end
					dismissed = dismissed + 1
				end
			end
		end
	end
	if dismissed > 0 then
		log.i(string.format("Dismissed %d Stream reminder dialog(s)", dismissed))
	end
	return true, nil
end

local function runHorizontalYouTube(startOutput, popupAttempts, forceClick)
	popupAttempts = popupAttempts or 0
	if startOutput then
		writeStartResult("pending", "Inspecting OBS Aitum controls")
	end
	local foundCrashReport, crashReportError = dismissObsCrashReporter()
	if crashReportError then
		fail(crashReportError)
		if startOutput then
			writeStartResult("error", crashReportError)
		else
			writeDiagnosticResult(false, crashReportError)
		end
		return false
	end
	if foundCrashReport then
		if popupAttempts >= 3 then
			local message = "OBS crash report remained open after dismissal"
			fail(message)
			if startOutput then
				writeStartResult("error", message)
			else
				writeDiagnosticResult(false, message)
			end
			return false
		end
		hs.timer.doAfter(0.2, function()
			runHorizontalYouTube(startOutput, popupAttempts + 1, forceClick)
		end)
		return true
	end
	local remindersDismissed, reminderError = dismissStreamReminders()
	if not remindersDismissed then
		fail(reminderError)
		if startOutput then
			writeStartResult("error", reminderError)
		else
			writeDiagnosticResult(false, reminderError)
		end
		return false
	end
	local app = hs.application.get("com.obsproject.obs-studio") or hs.application.find("OBS")
	if not app then
		fail("OBS is not running")
		if startOutput then
			writeStartResult("error", "OBS is not running")
		else
			writeDiagnosticResult(false, "OBS is not running")
		end
		return false
	end
	local obsWindow
	for _, window in ipairs(app:allWindows()) do
		if window:title():match("^OBS ") then
			obsWindow = window
			window:focus()
			break
		end
	end

	local root = hs.axuielement.applicationElement(app)
	local elements = descendants(root, 14)
	if findTextContaining(elements, "Unable to start output.") then
		if popupAttempts >= 3 then
			local message = "Aitum output error remained open after dismissal"
			fail(message)
			if startOutput then
				writeStartResult("error", message)
			else
				writeDiagnosticResult(false, message)
			end
			return false
		end
		local okButton = findText(elements, "OK", true)
		if not okButton or not press(okButton) then
			fail("Could not dismiss the stale Aitum output error")
			if startOutput then
				writeStartResult("error", "Could not dismiss the stale Aitum output error")
			else
				writeDiagnosticResult(false, "Could not dismiss the stale Aitum output error")
			end
			return false
		end
		log.w("Dismissed stale Aitum main-encoder output error")
		hs.timer.doAfter(0.2, function()
			runHorizontalYouTube(startOutput, popupAttempts + 1, forceClick)
		end)
		return true
	end
	local aitumTab = findText(elements, "Aitum Multistream", true)
	if not aitumTab then
		fail("Could not find the Aitum Multistream dock tab")
		if startOutput then
			writeStartResult("error", "Could not find the Aitum Multistream dock tab")
		else
			writeDiagnosticResult(false, "Could not find the Aitum Multistream dock tab")
		end
		return false
	end

	if not press(aitumTab) then
		fail("Could not select the Aitum Multistream dock tab")
		if startOutput then
			writeStartResult("error", "Could not select the Aitum Multistream dock tab")
		else
			writeDiagnosticResult(false, "Could not select the Aitum Multistream dock tab")
		end
		return false
	end

	hs.timer.doAfter(0.5, function()
		local visibleElements = descendants(root, 14)
		local label, labelError = horizontalYouTubeLabel(visibleElements)
		if not label then
			fail(labelError)
			if startOutput then
				writeStartResult("error", labelError)
			else
				writeDiagnosticResult(false, labelError)
			end
			return
		end

		local button = adjacentStreamButton(label)
		if not button then
			fail("Could not find the Main Canvas YouTube Output button")
			if startOutput then
				writeStartResult("error", "Could not find the Main Canvas YouTube Output button")
			else
				writeDiagnosticResult(false, "Could not find the Main Canvas YouTube Output button")
			end
			return
		end
		if not startOutput then
			local buttonFrame = attribute(button, "AXFrame") or {}
			local valueSettable = false
			pcall(function()
				valueSettable = button:isAttributeSettable("AXValue")
			end)
			local diagnostic = string.format(
				"Found Main Canvas YouTube Output button role=%s title=%s description=%s identifier=%s value=%s valueSettable=%s frame=%.0f,%.0f %.0fx%.0f actions=%s",
				tostring(attribute(button, "AXRole")),
				tostring(attribute(button, "AXTitle")),
				tostring(attribute(button, "AXDescription")),
				tostring(attribute(button, "AXIdentifier")),
				tostring(attribute(button, "AXValue")),
				tostring(valueSettable),
				buttonFrame.x or -1,
				buttonFrame.y or -1,
				buttonFrame.w or -1,
				buttonFrame.h or -1,
				table.concat(attribute(button, "AXActionNames") or {}, ",")
			)
			log.i(diagnostic)
			writeDiagnosticResult(true, diagnostic)
			hs.alert.show("OBS Aitum: Main Canvas YouTube Output is ready", 3)
			return
		end
		app:activate(true)
		if obsWindow then
			obsWindow:raise()
			obsWindow:focus()
		end
		hs.timer.usleep(200000)
		local frontmost = hs.application.frontmostApplication()
		if not frontmost or frontmost:bundleID() ~= "com.obsproject.obs-studio" then
			fail("Could not focus OBS before clicking the Main Canvas YouTube Output button")
			writeStartResult("error", "OBS was not frontmost before the output click")
			return
		end
		local priorValue = attribute(button, "AXValue")
		local pressed = click(button)
		if not pressed then
			fail("Could not press the Main Canvas YouTube Output button")
			writeStartResult("error", "Could not press the Main Canvas YouTube Output button")
			return
		end
		log.i("Pressed Main Canvas YouTube Output")

		hs.timer.doAfter(0.5, function()
			local resultElements = descendants(root, 14)
			if findTextContaining(resultElements, "Unable to start output.") then
				writeStartResult("error", "Aitum rejected the output because the main encoder is inactive")
			else
				writeStartResult(
					"ok",
					string.format(
						"Pressed Main Canvas YouTube Output mode=%s value=%s->%s",
						forceClick and "click-fallback" or "click",
						tostring(priorValue),
						tostring(attribute(button, "AXValue"))
					)
				)
			end
		end)
	end)
	return true
end

function M.startHorizontalYouTube(forceClick)
	return runHorizontalYouTube(true, nil, forceClick)
end

function M.diagnoseHorizontalYouTube()
	return runHorizontalYouTube(false)
end

hs.urlevent.bind(URL_EVENT, function(_, params)
	M.startHorizontalYouTube(params and params.mode == "click")
end)

hs.urlevent.bind(DIAGNOSTIC_URL_EVENT, function()
	M.diagnoseHorizontalYouTube()
end)

return M
