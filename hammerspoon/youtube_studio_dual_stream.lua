local M = {}
local safeClick = require("safe_frontmost_click")

local log = hs.logger.new("youtube-dual-stream", "info")
local URL_EVENT = "youtube-studio-dual-stream"
local RESULT_PREFIX = "/tmp/youtube-studio-dual-stream"
local YABAI = "/opt/homebrew/bin/yabai"
local MAX_NODES = 10000
local MAX_DEPTH = 45
local POLL_INTERVAL = 0.2
local runId = 0
local activeRun
local cancelledRequests = {}

local function safeLog(method, message)
	pcall(function()
		method(message)
	end)
end

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

local function frameCenterIsInside(frame, container)
	if not frame or not container or frame.w <= 0 or frame.h <= 0 then
		return false
	end
	local x = frame.x + frame.w / 2
	local y = frame.y + frame.h / 2
	return x >= container.x and x <= container.x + container.w and y >= container.y and y <= container.y + container.h
end

local function scrollToVisible(element)
	if not element then
		return false
	end
	local ok = pcall(function()
		element:performAction("AXScrollToVisible")
	end)
	return ok
end

local function press(element, visibleContainer, semantic)
	if not element or not hasAction(element, "AXPress") then
		return false
	end
	local app = hs.application.find("YouTube Studio")
	local targetWindow = activeRun and activeRun.targetWindow or nil
	if semantic then
		return safeClick.performAction(app, element, "AXPress", targetWindow)
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
	if not visibleContainer then
		scrollToVisible(target)
	end
	local frame = attribute(target, "AXFrame")
	if not frame or frame.w <= 0 or frame.h <= 0 then
		return false
	end
	if visibleContainer and not frameCenterIsInside(frame, visibleContainer) then
		return false
	end
	return safeClick.leftClick(app, { x = frame.x + frame.w / 2, y = frame.y + frame.h / 2 }, targetWindow)
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

local function writeResult(requestId, broadcastId, status, code, observed, details)
	if not validRequestId(requestId) then
		safeLog(log.e, "Refused to write Dual stream result with an invalid request ID")
		return
	end
	local path = resultPath(requestId)
	local temporaryPath = path .. ".tmp"
	local file = io.open(temporaryPath, "w")
	if not file then
		safeLog(log.e, "Could not write Dual stream result")
		return
	end
	file:write(hs.json.encode({
		requestId = requestId,
		broadcastId = broadcastId or "",
		status = status,
		code = code,
		observed = observed or code,
		details = details,
	}) .. "\n")
	file:close()
	if not os.rename(temporaryPath, path) then
		safeLog(log.e, "Could not publish Dual stream result")
	end
end

local function focusExactWindow(targetWindow, axWindow)
	local targetWindowId = targetWindow and targetWindow:id() or nil
	if type(targetWindowId) ~= "number" or targetWindowId <= 0 or targetWindowId % 1 ~= 0 then
		return false, targetWindowId, 0
	end
	targetWindow:focus()
	targetWindow:raise()
	pcall(function()
		axWindow:performAction("AXRaise")
	end)
	hs.execute(string.format("%s -m window %d --focus", YABAI, targetWindowId), true)
	local focusedWindow = hs.window.focusedWindow()
	local focusedWindowId = focusedWindow and focusedWindow:id() or 0
	return focusedWindowId == targetWindowId, targetWindowId, focusedWindowId
end

local function snapshot(expectedTitle, broadcastId)
	local app = hs.application.find("YouTube Studio")
	if not app then
		return nil, "studio-not-running"
	end
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
	local focused, targetWindowId, focusedWindowId = focusExactWindow(targetWindow, axWindows[targetIndex])
	if activeRun then
		activeRun.focusEvidence = {
			targetWindowId = targetWindowId or 0,
			focusedWindowId = focusedWindowId,
		}
	end
	if not focused then
		return nil, "broadcast-window-focus-failed"
	end
	if activeRun then
		activeRun.targetWindow = targetWindow
	end
	local window = axWindows[targetIndex]
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
	local pageFrame = attribute(page, "AXFrame")
	local toggleFrame = toggleButton and attribute(toggleButton, "AXFrame") or nil
	local checkboxFrame = attribute(checkbox, "AXFrame")
	local clickFrame = toggleFrame or checkboxFrame
	local toggleVisible = frameCenterIsInside(clickFrame, pageFrame)
	local modeButtonFrame = modeButton and attribute(modeButton, "AXFrame") or nil
	local modeButtonVisible = modeButtonFrame and frameCenterIsInside(modeButtonFrame, pageFrame) or false
	local state = {
		checkbox = checkbox,
		checkboxEnabled = attribute(checkbox, "AXEnabled") == true,
		checkboxState = checkboxState,
		entries = entries,
		mode = mode,
		modeButton = modeButton,
		modeButtonVisible = modeButtonVisible,
		pageFrame = pageFrame,
		checkboxFrame = checkboxFrame,
		toggleFrame = toggleFrame,
		toggleVisible = toggleVisible,
	}
	if activeRun then
		activeRun.evidence = {
			checkboxState = checkboxState,
			clickAttempts = activeRun.clickAttempts or 0,
			mode = mode or "absent",
			modeButtonVisible = modeButtonVisible,
			toggleVisible = toggleVisible,
			targetWindowId = activeRun.focusEvidence and activeRun.focusEvidence.targetWindowId or 0,
			focusedWindowId = activeRun.focusEvidence and activeRun.focusEvidence.focusedWindowId or 0,
		}
	end
	return state
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
	local evidence = activeRun.evidence or {}
	if activeRun.focusEvidence then
		evidence.targetWindowId = activeRun.focusEvidence.targetWindowId
		evidence.focusedWindowId = activeRun.focusEvidence.focusedWindowId
	end
	activeRun = nil
	runId = runId + 1
	writeResult(requestId, broadcastId, status, code, observed, evidence)
end

local function waitFor(id, description, timeout, overallDeadline, timeoutCode, check, onSuccess, onTimeout)
	local deadline = math.min(hs.timer.secondsSinceEpoch() + timeout, overallDeadline)
	local lastObserved = "not-observed"

	local function poll()
		if not isActive(id, overallDeadline) then
			if activeRun and activeRun.runId == id then
				finish(id, "error", timeoutCode, lastObserved)
				safeLog(log.e, description .. " timed out; last observed: " .. lastObserved)
			end
			return
		end
		if hs.timer.secondsSinceEpoch() >= deadline then
			if onTimeout and isActive(id, overallDeadline) then
				onTimeout(lastObserved)
			else
				finish(id, "error", timeoutCode, lastObserved)
			end
			safeLog(log.e, description .. " timed out; last observed: " .. lastObserved)
			return
		end
		local result, observed = check()
		lastObserved = observed or lastObserved
		if hs.timer.secondsSinceEpoch() >= deadline then
			if onTimeout and isActive(id, overallDeadline) then
				onTimeout(lastObserved)
			else
				finish(id, "error", timeoutCode, lastObserved)
			end
			safeLog(log.e, description .. " timed out; last observed: " .. lastObserved)
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
	-- Page discovery, one verified click retry, panel rendering, and final verification each have their own bound.
	local overallDeadline = hs.timer.secondsSinceEpoch() + 45
	activeRun = {
		runId = id,
		requestId = requestId,
		broadcastId = broadcastId,
		clickAttempts = 0,
	}
	writeResult(requestId, broadcastId, "pending", "waiting-for-broadcast-page")

	local function verifyFinalState()
		waitFor(id, "Dual stream encoder verification", 8, overallDeadline, "verification-timeout", function()
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
			return state
		end, function()
			finish(id, "ok", "verified")
			safeLog(log.i, "Verified YouTube Studio Dual stream encoder configuration")
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
		if state.mode ~= "Auto crop" or not state.modeButton then
			finish(id, "error", "mode-menu-open-failed")
			return
		end
		scrollToVisible(state.modeButton)
		waitFor(id, "Vertical mode selector visibility", 5, overallDeadline, "mode-selector-visibility-timeout", function()
			local visibleState, observed = snapshot(expectedTitle, broadcastId)
			if not visibleState then
				return nil, observed
			end
			return visibleState.modeButtonVisible and visibleState or nil, "vertical-mode-selector-offscreen"
		end, function(visibleState)
			if not press(visibleState.modeButton, visibleState.pageFrame, true) then
				finish(id, "error", "mode-menu-open-failed", "mode-menu-visible-click-failed")
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
				return option and { option = option, pageFrame = current.pageFrame } or nil,
					option and nil or "encoder-menu-option-absent"
			end, function(selection)
				if not isActive(id, overallDeadline) or not press(selection.option, selection.pageFrame, true) then
					finish(id, "error", "encoder-selection-failed")
					return
				end
				verifyFinalState()
			end)
		end)
	end

	local function enableIfNeeded(initialState)
		if initialState.mode then
			selectEncoder(initialState)
			return
		end
		local function waitForPanel()
			waitFor(id, "Dual stream panel", 12, overallDeadline, "dual-stream-panel-timeout", function()
				local enabledState, currentObserved = snapshot(expectedTitle, broadcastId)
				if not enabledState then
					return nil, currentObserved
				end
				local observed = "vertical-mode-selector-absent-checkbox-" .. enabledState.checkboxState
				return enabledState.mode and enabledState or nil, observed
			end, selectEncoder)
		end

		local ensureVisibleAndEnable
		ensureVisibleAndEnable = function(state, attempt)
			if not isActive(id, overallDeadline) then
				return
			end
			scrollToVisible(state.checkbox)
			waitFor(id, "Dual stream control visibility", 5, overallDeadline, "dual-stream-control-visibility-timeout", function()
				local visibleState, observed = snapshot(expectedTitle, broadcastId)
				if not visibleState then
					return nil, observed
				end
				return visibleState.toggleVisible and visibleState or nil, "dual-stream-toggle-offscreen"
			end, function(visibleState)
				if visibleState.checkboxState == "on" then
					waitForPanel()
					return
				end
				if visibleState.checkboxState ~= "off" then
					finish(id, "error", "dual-stream-state-unknown")
					return
				end
				activeRun.clickAttempts = attempt
				if not press(visibleState.checkbox, visibleState.pageFrame, attempt > 1) then
					finish(id, "error", "dual-stream-enable-failed", "dual-stream-visible-click-failed")
					return
				end
				waitFor(id, "Dual stream toggle transition", 5, overallDeadline, "dual-stream-toggle-timeout", function()
					local toggledState, observed = snapshot(expectedTitle, broadcastId)
					if not toggledState then
						return nil, observed
					end
					if toggledState.checkboxState == "on" or toggledState.mode then
						return toggledState
					end
					return nil, "dual-stream-toggle-remained-" .. toggledState.checkboxState
				end, waitForPanel, function(lastObserved)
					if attempt < 2 then
						local retryState, observed = snapshot(expectedTitle, broadcastId)
						if retryState then
							ensureVisibleAndEnable(retryState, attempt + 1)
						else
							finish(id, "error", "dual-stream-toggle-timeout", observed or lastObserved)
						end
					else
						finish(id, "error", "dual-stream-toggle-timeout", lastObserved)
					end
				end)
			end)
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
			ensureVisibleAndEnable(state, 1)
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
		safeLog(log.i, "Cancelled YouTube Studio Dual stream automation")
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
