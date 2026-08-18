-- Show SketchyBar feedback whenever the macOS system pasteboard changes.

local M = {}

local sketchybar = "/opt/homebrew/bin/sketchybar"
local item = "clipboard.feedback"
local pollInterval = 0.1
local visibleDuration = 1.0
local lastChangeCount = hs.pasteboard.changeCount()
local hideTimer
local generation = 0
local runningTasks = {}

local function setVisible(visible)
	local task
	task = hs.task.new(sketchybar, function()
		runningTasks[task] = nil
	end, { "--set", item, "drawing=" .. (visible and "on" or "off") })

	if task then
		runningTasks[task] = true
		task:start()
	end
end

local function showFeedback()
	generation = generation + 1
	local currentGeneration = generation

	if hideTimer then
		hideTimer:stop()
	end

	setVisible(true)
	hideTimer = hs.timer.doAfter(visibleDuration, function()
		if generation == currentGeneration then
			setVisible(false)
		end
	end)
end

M.watcher = hs.timer.doEvery(pollInterval, function()
	local changeCount = hs.pasteboard.changeCount()
	if changeCount ~= lastChangeCount then
		lastChangeCount = changeCount
		showFeedback()
	end
end)

return M
