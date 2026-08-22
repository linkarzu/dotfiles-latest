local M = {}

local log = hs.logger.new("youtube-dual-stream", "info")
local URL_EVENT = "youtube-studio-dual-stream"
local RESULT_PREFIX = "/tmp/youtube-studio-dual-stream"
local EXPECTED_VERTICAL_KEY = "Vertical stream key (RTMP, Variable)"
local MAX_NODES = 10000
local MAX_DEPTH = 45
local POLL_INTERVAL = 0.2
local runId = 0
local activeRun
local cancelledRequests = {}

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
	if not ok then
		return false
	end
	for _, candidate in ipairs(actions or {}) do
		if candidate == action then
			return true
		end
	end
	return false
end

local descendants

local function press(element)
	if not element or not hasAction(element, "AXPress") then
		return false
	end
	local target = element
	if
		attribute(element, "AXRole") == "AXCheckBox"
		and attribute(element, "AXDOMIdentifier") == "layout-switch"
	then
		for _, entry in ipairs(descendants(element)) do
			if attribute(entry.element, "AXDOMIdentifier") == "toggleButton" then
				target = entry.element
				break
			end
		end
	end
	pcall(function()
		target:performAction("AXScrollToVisible")
	end)
	local frame = attribute(target, "AXFrame")
	if not frame or frame.w <= 0 or frame.h <= 0 then
		return false
	end
	hs.eventtap.leftClick({ x = frame.x + frame.w / 2, y = frame.y + frame.h / 2 })
	return true
end

descendants = function(root)
	local results = {}
	local visited = 0

	local function visit(element, depth)
		if depth > MAX_DEPTH or visited >= MAX_NODES then
			return
		end
		visited = visited + 1
		table.insert(results, { element = element, depth = depth })
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

local function findUniqueExact(entries, expected, role, pressable)
	local match
	local count = 0
	local matchDepth
	local seenFrames = {}
	for _, entry in ipairs(entries) do
		local element = entry.element
		if
			textMatches(element, expected)
			and (not role or attribute(element, "AXRole") == role)
			and (not pressable or hasAction(element, "AXPress"))
		then
			local frame = attribute(element, "AXFrame")
			local frameKey = frame
				and string.format("%.1f:%.1f:%.1f:%.1f", frame.x, frame.y, frame.w, frame.h)
				or tostring(element)
			if not seenFrames[frameKey] then
				seenFrames[frameKey] = true
				count = count + 1
			end
			if not matchDepth or entry.depth < matchDepth then
				match = element
				matchDepth = entry.depth
			end
		end
	end
	return count == 1 and match or nil, count
end

local function findAncestor(element, domIdentifier)
	local current = element
	for _ = 1, 12 do
		if not current then
			return nil
		end
		if attribute(current, "AXDOMIdentifier") == domIdentifier then
			return current
		end
		current = attribute(current, "AXParent")
	end
	return nil
end

local function urlString(value)
	if type(value) == "table" then
		return value.url
	end
	return type(value) == "string" and value or nil
end

local function resultPath(requestId)
	return RESULT_PREFIX .. "-" .. requestId .. ".json"
end

local function validRequestId(value)
	return type(value) == "string" and #value == 36 and value:match("^[0-9a-fA-F%-]+$") ~= nil
end

local function validBroadcastId(value)
	return type(value) == "string" and #value > 0 and #value <= 100 and value:match("^[%w_-]+$") ~= nil
end

local function writeResult(requestId, broadcastId, status, code, observed)
	if not validRequestId(requestId) then
		log.e("Refused to write Dual stream result with an invalid request ID")
		return
	end
	local path = resultPath(requestId)
	local temporaryPath = path .. ".tmp"
	local file = io.open(temporaryPath, "w")
	if not file then
		log.e("Could not write Dual stream result")
		return
	end
	file:write(hs.json.encode({
		requestId = requestId,
		broadcastId = broadcastId or "",
		status = status,
		code = code,
		observed = observed or code,
	}) .. "\n")
	file:close()
	if not os.rename(temporaryPath, path) then
		log.e("Could not publish Dual stream result")
	end
end

local function snapshot(expectedTitle, broadcastId)
	local app = hs.application.find("YouTube Studio")
	if not app then
		return nil, "studio-not-running"
	end
	app:activate(true)
	local applicationElement = hs.axuielement.applicationElement(app)
	local axWindows = attribute(applicationElement, "AXWindows") or {}
	local appWindows = app:allWindows()
	local expectedURL = "https://studio.youtube.com/video/" .. broadcastId .. "/livestreaming"
	local targetIndex
	for index, candidate in ipairs(axWindows) do
		for _, entry in ipairs(descendants(candidate)) do
			if attribute(entry.element, "AXRole") == "AXWebArea" then
				local url = urlString(attribute(entry.element, "AXURL"))
				local baseURL = url and url:match("^([^?#]+)") or nil
				if baseURL == expectedURL or baseURL == expectedURL .. "/" then
					targetIndex = index
					break
				end
			end
		end
		if targetIndex then
			break
		end
	end
	if not targetIndex then
		return nil, "broadcast-page-not-visible"
	end
	local targetWindow = appWindows[targetIndex]
	if not targetWindow then
		return nil, "broadcast-window-mapping-unavailable"
	end
	targetWindow:focus()
	targetWindow:raise()
	pcall(function()
		axWindows[targetIndex]:performAction("AXRaise")
	end)
	local focusedWindow = hs.window.focusedWindow()
	if not focusedWindow or focusedWindow:id() ~= targetWindow:id() then
		return nil, "broadcast-window-focus-failed"
	end
	local window = attribute(applicationElement, "AXFocusedWindow") or attribute(applicationElement, "AXMainWindow")
	if not window then
		return nil, "studio-window-not-accessible"
	end
	local entries = descendants(window)
	local page
	local pageMatches = 0
	for _, entry in ipairs(entries) do
		if attribute(entry.element, "AXRole") == "AXWebArea" then
			local url = urlString(attribute(entry.element, "AXURL"))
			local baseURL = url and url:match("^([^?#]+)") or nil
			if baseURL == expectedURL or baseURL == expectedURL .. "/" then
				page = entry.element
				pageMatches = pageMatches + 1
			end
		end
	end
	if pageMatches ~= 1 then
		return nil, pageMatches == 0 and "broadcast-page-not-visible" or "broadcast-page-ambiguous"
	end
	local pageEntries = descendants(page)

	local titleMatches = 0
	for _, entry in ipairs(pageEntries) do
		local element = entry.element
		if attribute(element, "AXRole") == "AXStaticText" and textMatches(element, expectedTitle) then
			titleMatches = titleMatches + 1
		end
	end
	if titleMatches == 0 then
		return nil, "broadcast-title-not-visible"
	end

	local checkbox
	local checkboxMatches = 0
	for _, entry in ipairs(pageEntries) do
		local element = entry.element
		if
			attribute(element, "AXRole") == "AXCheckBox"
			and attribute(element, "AXDescription") == "Dual stream"
			and attribute(element, "AXDOMIdentifier") == "layout-switch"
		then
			checkbox = element
			checkboxMatches = checkboxMatches + 1
		end
	end
	if checkboxMatches ~= 1 then
		return nil, checkboxMatches == 0 and "dual-stream-control-absent" or "dual-stream-control-ambiguous"
	end

	local panel = findAncestor(checkbox, "panels")
	if not panel then
		return nil, "dual-stream-panel-scope-absent"
	end
	local verticalModeEntries = {}
	for _, entry in ipairs(pageEntries) do
		if findAncestor(entry.element, "source-dropdown") then
			table.insert(verticalModeEntries, entry)
		end
	end
	local encoderButton, encoderCount = findUniqueExact(verticalModeEntries, "Encoder", "AXButton", true)
	local autoCropButton, autoCropCount = findUniqueExact(verticalModeEntries, "Auto crop", "AXButton", true)
	if encoderCount + autoCropCount > 1 then
		return nil, "dual-stream-mode-ambiguous"
	end

	local mode
	local modeButton
	if encoderButton then
		mode = "Encoder"
		modeButton = encoderButton
	elseif autoCropButton then
		mode = "Auto crop"
		modeButton = autoCropButton
	end

	local verticalContainer = modeButton and findAncestor(modeButton, "ingestion-container") or nil
	local verticalEntries = verticalContainer and descendants(verticalContainer) or {}
	local selectKeys = {}
	local expectedVerticalKeyCount = 0
	for _, entry in ipairs(verticalEntries) do
		local element = entry.element
		if attribute(element, "AXRole") == "AXTextField" and attribute(element, "AXTitle") == "Select key" then
			table.insert(selectKeys, element)
			if attribute(element, "AXValue") == EXPECTED_VERTICAL_KEY then
				expectedVerticalKeyCount = expectedVerticalKeyCount + 1
			end
		end
	end

	local toggleBar
	local toggleButton
	for _, entry in ipairs(descendants(checkbox)) do
		local domIdentifier = attribute(entry.element, "AXDOMIdentifier")
		if domIdentifier == "toggleBar" then
			toggleBar = entry.element
		elseif domIdentifier == "toggleButton" then
			toggleButton = entry.element
		end
	end
	local checkboxState = "unknown"
	if attribute(checkbox, "AXSelected") == true then
		checkboxState = "on"
	else
		local barFrame = toggleBar and attribute(toggleBar, "AXFrame") or nil
		local buttonFrame = toggleButton and attribute(toggleButton, "AXFrame") or nil
		if barFrame and buttonFrame and barFrame.w > 0 then
			local centerOffset = (buttonFrame.x + buttonFrame.w / 2) - (barFrame.x + barFrame.w / 2)
			local relativeOffset = centerOffset / barFrame.w
			if relativeOffset > 0.1 then
				checkboxState = "on"
			elseif relativeOffset < -0.1 then
				checkboxState = "off"
			end
		end
	end

	return {
		checkbox = checkbox,
		checkboxEnabled = attribute(checkbox, "AXEnabled") == true,
		checkboxState = checkboxState,
		entries = entries,
		mode = mode,
		modeButton = modeButton,
		selectKeyCount = #selectKeys,
		expectedVerticalKeyCount = expectedVerticalKeyCount,
	}
end

local function isActive(id, deadline)
	return activeRun ~= nil
		and activeRun.runId == id
		and runId == id
		and hs.timer.secondsSinceEpoch() < deadline
end

local function finish(id, status, code, observed)
	if not activeRun or activeRun.runId ~= id or runId ~= id then
		return
	end
	local requestId = activeRun.requestId
	local broadcastId = activeRun.broadcastId
	activeRun = nil
	runId = runId + 1
	writeResult(requestId, broadcastId, status, code, observed)
end

local function waitFor(id, description, timeout, overallDeadline, timeoutCode, check, onSuccess)
	local deadline = math.min(hs.timer.secondsSinceEpoch() + timeout, overallDeadline)
	local lastObserved = "not-observed"

	local function poll()
		if not isActive(id, overallDeadline) then
			if activeRun and activeRun.runId == id then
				log.e(description .. " timed out; last observed: " .. lastObserved)
				finish(id, "error", timeoutCode, lastObserved)
			end
			return
		end
		if hs.timer.secondsSinceEpoch() >= deadline then
			log.e(description .. " timed out; last observed: " .. lastObserved)
			finish(id, "error", timeoutCode, lastObserved)
			return
		end
		local result, observed = check()
		lastObserved = observed or lastObserved
		if hs.timer.secondsSinceEpoch() >= deadline then
			log.e(description .. " timed out; last observed: " .. lastObserved)
			finish(id, "error", timeoutCode, lastObserved)
			return
		end
		if result then
			if isActive(id, overallDeadline) then
				onSuccess(result)
			end
			return
		end
		hs.timer.doAfter(POLL_INTERVAL, poll)
	end

	poll()
end

local function configure(expectedTitle, broadcastId, requestId)
	runId = runId + 1
	local id = runId
	local overallDeadline = hs.timer.secondsSinceEpoch() + 15
	activeRun = {
		runId = id,
		requestId = requestId,
		broadcastId = broadcastId,
	}
	writeResult(requestId, broadcastId, "pending", "waiting-for-broadcast-page")

	local function verifyFinalState()
		waitFor(id, "Dual stream encoder verification", 5, overallDeadline, "verification-timeout", function()
			local state, observed = snapshot(expectedTitle, broadcastId)
			if not state then
				return nil, observed
			end
			if not state.checkboxEnabled then
				return nil, "dual-stream-control-disabled"
			end
			if state.checkboxState ~= "on" then
				return nil, state.checkboxState == "off" and "dual-stream-state-off" or "dual-stream-state-unknown"
			end
			if state.mode ~= "Encoder" then
				return nil, "vertical-mode-not-encoder"
			end
			if state.selectKeyCount ~= 1 then
				return nil, "vertical-key-selector-ambiguous"
			end
			if state.expectedVerticalKeyCount ~= 1 then
				return nil, state.expectedVerticalKeyCount == 0 and "vertical-key-not-selected"
					or "vertical-key-ambiguous"
			end
			return state
		end, function()
			log.i("Verified YouTube Studio Dual stream encoder configuration")
			finish(id, "ok", "verified")
		end)
	end

	local function selectEncoder(state)
		if not isActive(id, overallDeadline) then
			return
		end
		if state.mode == "Encoder" then
			verifyFinalState()
			return
		end
		if state.mode ~= "Auto crop" or not state.modeButton or not press(state.modeButton) then
			finish(id, "error", "mode-menu-open-failed")
			return
		end
		waitFor(id, "Encoder menu option", 5, overallDeadline, "encoder-option-timeout", function()
			local current, observed = snapshot(expectedTitle, broadcastId)
			if not current then
				return nil, observed
			end
			local option, count = findUniqueExact(current.entries, "Encoder", "AXMenuItem", true)
			if count > 1 then
				return nil, "encoder-menu-option-ambiguous"
			end
			return option, option and nil or "encoder-menu-option-absent"
		end, function(option)
			if not isActive(id, overallDeadline) or not press(option) then
				finish(id, "error", "encoder-selection-failed")
				return
			end
			verifyFinalState()
		end)
	end

	local function enableIfNeeded(initialState)
		if initialState.mode then
			selectEncoder(initialState)
			return
		end
		local function waitForPanel()
			waitFor(id, "Dual stream panel", 5, overallDeadline, "dual-stream-panel-timeout", function()
				local enabledState, currentObserved = snapshot(expectedTitle, broadcastId)
				if not enabledState then
					return nil, currentObserved
				end
				return enabledState.mode and enabledState or nil, "vertical-mode-selector-absent"
			end, selectEncoder)
		end

		-- Give an already-enabled panel time to render before deciding whether to press the toggle.
		hs.timer.doAfter(3, function()
			if not isActive(id, overallDeadline) then
				return
			end
			local state, observed = snapshot(expectedTitle, broadcastId)
			if not state then
				finish(id, "error", observed or "broadcast-state-unavailable")
				return
			end
			if state.mode then
				selectEncoder(state)
				return
			end
			if not state.checkboxEnabled then
				finish(id, "error", "dual-stream-control-disabled")
				return
			end
			if state.checkboxState == "on" then
				waitForPanel()
				return
			end
			if state.checkboxState ~= "off" then
				finish(id, "error", "dual-stream-state-unknown")
				return
			end
			if not press(state.checkbox) then
				finish(id, "error", "dual-stream-enable-failed")
				return
			end
			waitForPanel()
		end)
	end

	waitFor(id, "YouTube Studio Dual stream page", 15, overallDeadline, "broadcast-page-timeout", function()
		return snapshot(expectedTitle, broadcastId)
	end, enableIfNeeded)
end

function M.configure(expectedTitle, broadcastId, requestId)
	if type(expectedTitle) ~= "string" or expectedTitle == "" or not validBroadcastId(broadcastId) or not validRequestId(requestId) then
		if validRequestId(requestId) then
			writeResult(requestId, broadcastId, "error", "invalid-parameters")
		end
		return false
	end
	if cancelledRequests[requestId] then
		writeResult(requestId, broadcastId, "error", "cancelled")
		return false
	end
	configure(expectedTitle, broadcastId, requestId)
	return true
end

function M.cancel(requestId, broadcastId)
	if validRequestId(requestId) then
		local now = hs.timer.secondsSinceEpoch()
		cancelledRequests[requestId] = now
		for candidate, cancelledAt in pairs(cancelledRequests) do
			if now - cancelledAt > 300 then
				cancelledRequests[candidate] = nil
			end
		end
	end
	if activeRun and activeRun.requestId == requestId then
		local broadcastId = activeRun.broadcastId
		activeRun = nil
		runId = runId + 1
		writeResult(requestId, broadcastId, "error", "cancelled")
		log.i("Cancelled YouTube Studio Dual stream automation")
		return true
	end
	if validRequestId(requestId) then
		writeResult(requestId, validBroadcastId(broadcastId) and broadcastId or "", "error", "cancelled")
	end
	return false
end

hs.urlevent.bind(URL_EVENT, function(_, params)
	if params and params.action == "cancel" then
		M.cancel(params.request, params.broadcast)
		return
	end
	M.configure(params and params.title, params and params.broadcast, params and params.request)
end)

return M
