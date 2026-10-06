local M = {}

local modeKey = "linkarzu.displayMirrorToggle.builtInMode"

local function displays()
	local builtIn
	local external = {}
	for _, screen in ipairs(hs.screen.allScreens()) do
		if (screen:name() or ""):lower():find("built%-in") then
			builtIn = screen
		else
			table.insert(external, screen)
		end
	end
	return builtIn, external
end

function M.start()
	local builtIn, external = displays()
	if not builtIn then
		return false, "Built-in display not found"
	end
	if #external ~= 1 then
		return false, string.format("Expected one external display, found %d", #external)
	end

	local mode = builtIn:currentMode()
	if not mode then
		return false, "Could not read built-in display mode"
	end
	-- The external display vanishes from hs.screen.allScreens() when mirrored.
	-- The shell toggle detects the real mirror state via CoreGraphics instead.
	hs.settings.set(modeKey, mode)
	if not external[1]:mirrorOf(builtIn, false) then
		hs.settings.clear(modeKey)
		return false, "Hammerspoon could not start display mirroring"
	end
	return true, "mirrored"
end

-- Called once mirroring settled, so macOS does not override the mode again.
function M.setMirrorMode(w, h)
	local builtIn = displays()
	if not builtIn then
		return false, "Built-in display not found"
	end
	local mode = builtIn:currentMode()
	if not mode then
		return false, "Could not read built-in display mode"
	end
	if mode.w == w and mode.h == h and mode.scale == 2 then
		return true, "Mirror mode already set"
	end
	if not builtIn:setMode(w, h, 2, mode.freq, mode.depth) then
		return false, string.format("Could not set built-in display to %dx%d", w, h)
	end
	return true, "Mirror mode set"
end

function M.restoreMode()
	local mode = hs.settings.get(modeKey)
	if not mode then
		return true, "No saved built-in display mode"
	end
	local builtIn = displays()
	if not builtIn or not builtIn:setMode(mode.w, mode.h, mode.scale, mode.freq, mode.depth) then
		return false, "Could not restore built-in display mode"
	end
	hs.settings.clear(modeKey)
	return true, "Built-in display mode restored"
end

return M
