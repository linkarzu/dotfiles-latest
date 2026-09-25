-- Standalone Lua test; all Hammerspoon screen operations below are inert mocks.
local source = arg[1] or "hammerspoon/display_mirror_toggle.lua"
local savedHs = hs

local function screen(name, mirrorResult, modeResult)
	local value = { mirrorCalls = 0, modeCalls = 0 }
	function value:name() return name end
	function value:currentMode()
		return { w = 1512, h = 982, scale = 2, freq = 60, depth = 8 }
	end
	function value:mirrorOf(other, permanent)
		self.mirrorCalls = self.mirrorCalls + 1
		self.mirrorSource = other
		self.mirrorPermanent = permanent
		return mirrorResult ~= false
	end
	function value:setMode(...)
		self.modeCalls = self.modeCalls + 1
		self.modeArguments = { ... }
		return modeResult ~= false
	end
	return value
end

local function loadModule(screens, settings)
	settings = settings or {}
	hs = {
		screen = { allScreens = function() return screens end },
		settings = {
			get = function(key) return settings[key] end,
			set = function(key, value) settings[key] = value end,
			clear = function(key) settings[key] = nil end,
		},
	}
	return dofile(source), settings
end

local ok, err = xpcall(function()
	local builtIn = screen("Built-in Retina Display")
	local external = screen("PA278CV")
	local module, settings = loadModule({ external, builtIn })
	local success, state = module.start()
	assert(success and state == "mirrored")
	assert(external.mirrorCalls == 1 and external.mirrorSource == builtIn)
	assert(external.mirrorPermanent == false)
	assert(settings["linkarzu.displayMirrorToggle.builtInMode"].w == 1512)

	-- A fresh module (Hammerspoon reload) can still restore the saved mode.
	module = loadModule({ external, builtIn }, settings)
	success, state = module.restoreMode()
	assert(success and state == "Built-in display mode restored")
	assert(table.concat(builtIn.modeArguments, ",") == "1512,982,2,60,8")
	assert(settings["linkarzu.displayMirrorToggle.builtInMode"] == nil)
	assert(module.restoreMode())

	module = loadModule({ builtIn })
	success, state = module.start()
	assert(not success and state == "Expected one external display, found 0")

	module = loadModule({ builtIn, screen("Display A"), screen("Display B") })
	success, state = module.start()
	assert(not success and state == "Expected one external display, found 2")

	module = loadModule({ external })
	success, state = module.start()
	assert(not success and state == "Built-in display not found")

	external = screen("PA278CV", false)
	module, settings = loadModule({ builtIn, external })
	success, state = module.start()
	assert(not success and state == "Hammerspoon could not start display mirroring")
	assert(settings["linkarzu.displayMirrorToggle.builtInMode"] == nil)

	builtIn = screen("Built-in Retina Display", true, false)
	module, settings = loadModule({ builtIn, screen("PA278CV") })
	assert(module.start())
	success, state = module.restoreMode()
	assert(not success and state == "Could not restore built-in display mode")
	assert(settings["linkarzu.displayMirrorToggle.builtInMode"] ~= nil)
end, debug.traceback)

hs = savedHs
assert(ok, err)
print("display_mirror_toggle_test: all scenarios passed")
