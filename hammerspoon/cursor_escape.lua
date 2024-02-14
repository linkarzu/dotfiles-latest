-- Function to move the cursor to the top-left corner of the screen
function moveCursorToCorner()
	hs.mouse.absolutePosition(hs.geometry.point(0, 100))
end

-- Function to simulate pressing the Escape key
function pressEscapeKey()
	hs.eventtap.keyStroke({}, "escape")
end

-- Combined Function to handle application focus change events
function applicationWatcher(appName, eventType, appObject)
	if eventType == hs.application.watcher.activated then
		if appName == "Alacritty" then
			moveCursorToCorner()
			-- elseif appName == "Google Chrome" or appName == "Safari" or appName == "YouTube" then
			--   pressEscapeKey()
		end
	end
end

-- Create a new application watcher
appWatcher = hs.application.watcher.new(applicationWatcher)

-- Start the application watcher
appWatcher:start()
