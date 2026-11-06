-- Show SketchyBar feedback whenever the macOS system pasteboard changes or an app reads it.
-- A paste changes nothing on the pasteboard, so there's no change count to poll, and key events
-- don't reach Hammerspoon during Secure Input, which is when this matters most. So pastes come
-- from the entry macOS logs when an app reads the data on the general pasteboard. Any read shows
-- it: a paste the app then rejects still shows, and so does a script calling pbpaste.

local M = {}

local sketchybar = "/opt/homebrew/bin/sketchybar"
local log = "/usr/bin/log"
local copyItem = "clipboard.feedback"
local pasteItem = "clipboard.paste_feedback"
local pollInterval = 0.1
local visibleDuration = 1.0
local logRestartDelay = 5
-- Raycast and Paste keep a clipboard history, they read it right after every copy.
local readPredicate = 'subsystem == "com.apple.CFPasteboard" AND category == "entry"'
	.. " AND eventMessage BEGINSWITH \"CopyData('Apple CFPasteboard general'\""
	.. ' AND process != "Raycast" AND process != "Paste"'
local lastChangeCount = hs.pasteboard.changeCount()
local runningTasks = {}

local function setVisible(item, visible)
	local task
	task = hs.task.new(sketchybar, function()
		runningTasks[task] = nil
	end, { "--set", item, "drawing=" .. (visible and "on" or "off") })

	if task then
		runningTasks[task] = true
		task:start()
	end
end

local function newFeedback(item)
	local hideTimer
	local generation = 0
	local visible = false

	return function()
		generation = generation + 1
		local currentGeneration = generation

		if hideTimer then
			hideTimer:stop()
		end

		-- One paste can read several formats, only the first needs to draw the item.
		if not visible then
			visible = true
			setVisible(item, true)
		end
		hideTimer = hs.timer.doAfter(visibleDuration, function()
			if generation == currentGeneration then
				visible = false
				setVisible(item, false)
			end
		end)
	end
end

local showCopy = newFeedback(copyItem)
local showPaste = newFeedback(pasteItem)

M.watcher = hs.timer.doEvery(pollInterval, function()
	local changeCount = hs.pasteboard.changeCount()
	if changeCount ~= lastChangeCount then
		lastChangeCount = changeCount
		showCopy()
	end
end)

local function startPasteWatcher()
	M.pasteWatcher = hs.task.new(log, function()
		M.pasteRestartTimer = hs.timer.doAfter(logRestartDelay, startPasteWatcher)
	end, function(_, stdout)
		-- The first line log prints repeats the predicate, this only matches actual entries.
		if stdout:find(":entry] CopyData(", 1, true) then
			showPaste()
		end
		return true
	end, { "stream", "--style", "compact", "--level", "info", "--predicate", readPredicate })
	M.pasteWatcher:start()
end

startPasteWatcher()

return M
