-- Filename: ~/github/dotfiles-latest/hammerspoon/move_mouse_to_corner.lua
-- ~/github/dotfiles-latest/hammerspoon/move_mouse_to_corner.lua

-- Utility to move the mouse to the bottom-right corner of the screen
-- I'm doing this because when the Zen Browser app is focused, but my mouse is
-- on the sidebar on the left, the sidebar does not hide even if the mouse is
-- hidden.
-- So when I focus zen browser, I move the mouse

local function moveMouseToBottomRight()
	local screen = hs.screen.mainScreen() -- Get the primary screen
	local screenFrame = screen:frame() -- Get screen dimensions

	-- Calculate the bottom-right position
	local bottomRight = {
		x = screenFrame.x + screenFrame.w - 100, -- if 1 moves to the Rightmost pixel
		y = screenFrame.y + screenFrame.h - 100, -- if 1 moves to the Bottommost pixel
	}

	-- Move the mouse
	hs.mouse.setAbsolutePosition(bottomRight)
end

local function moveMouseToCenter()
	local screen = hs.screen.mainScreen() -- Get the primary screen
	local screenFrame = screen:frame() -- Get screen dimensions

	-- Calculate the center position
	local center = {
		x = screenFrame.x + (screenFrame.w / 2),
		y = screenFrame.y + (screenFrame.h / 2),
	}

	-- Move the mouse
	hs.mouse.setAbsolutePosition(center)
end

-- Watch for Zen Browser app focus
local zenAppWatcher = hs.application.watcher.new(function(appName, eventType, app)
	if eventType == hs.application.watcher.activated then
		if appName == "Zen Browser" then
			moveMouseToCenter()
		end
	end
end)

-- Start the application watcher
zenAppWatcher:start()
