local M = {}

local settingsKey = "linkarzu.displayMirrorToggle.active"
local mirrorTarget

local function displays()
	local builtIn
	local external = {}

	for _, screen in ipairs(hs.screen.allScreens()) do
		local name = screen:name() or ""
		if name:lower():find("built%-in") then
			builtIn = screen
		else
			table.insert(external, screen)
		end
	end

	return builtIn, external
end

function M.status()
	if mirrorTarget then
		return "mirrored"
	end

	if hs.settings.get(settingsKey) then
		local builtIn, external = displays()
		if builtIn and #external == 1 then
			hs.settings.clear(settingsKey)
			return "extended"
		end
		return "recovery-required"
	end

	local builtIn, external = displays()
	if builtIn and #external == 1 then
		return "extended"
	end

	return "unavailable"
end

function M.toggle()
	if mirrorTarget then
		if not mirrorTarget:mirrorStop(false) then
			return false, "Hammerspoon could not stop display mirroring"
		end

		mirrorTarget = nil
		hs.settings.clear(settingsKey)
		return true, "extended"
	end

	if hs.settings.get(settingsKey) then
		local builtIn, external = displays()
		if builtIn and #external == 1 then
			hs.settings.clear(settingsKey)
		else
			return false, "Hammerspoon was reloaded while mirroring; stop mirroring in System Settings"
		end
	end

	local builtIn, external = displays()
	if not builtIn then
		return false, "Built-in display not found"
	end
	if #external ~= 1 then
		return false, string.format("Expected one external display, found %d", #external)
	end

	-- Keep the target object so mirrorStop still works after macOS hides the
	-- mirrored external display from hs.screen.allScreens().
	local target = external[1]
	if not target:mirrorOf(builtIn, false) then
		return false, "Hammerspoon could not start display mirroring"
	end

	mirrorTarget = target
	hs.settings.set(settingsKey, true)
	return true, "mirrored"
end

return M
