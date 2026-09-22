-- Standalone Lua test; all Hammerspoon screen operations below are inert mocks.
local source = arg[1] or "hammerspoon/display_mirror_toggle.lua"
local savedHs = hs

local function screen(name, mirrorResult, stopResult)
	local value = { mirrorCalls = 0, stopCalls = 0 }
	function value:name()
		return name
	end
	function value:mirrorOf(other, permanent)
		self.mirrorCalls = self.mirrorCalls + 1
		self.mirrorSource = other
		self.mirrorPermanent = permanent
		return mirrorResult ~= false
	end
	function value:mirrorStop(permanent)
		self.stopCalls = self.stopCalls + 1
		self.stopPermanent = permanent
		return stopResult ~= false
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
	assert(module.status() == "extended")

	local success, state = module.toggle()
	assert(success and state == "mirrored")
	assert(external.mirrorCalls == 1 and external.mirrorSource == builtIn)
	assert(external.mirrorPermanent == false)
	assert(settings["linkarzu.displayMirrorToggle.active"] == true)
	assert(module.status() == "mirrored")

	-- The external screen disappears from allScreens while mirroring, but the
	-- retained target object still stops the mirror on the next invocation.
	hs.screen.allScreens = function() return { builtIn } end
	success, state = module.toggle()
	assert(success and state == "extended")
	assert(external.stopCalls == 1 and external.stopPermanent == false)
	assert(settings["linkarzu.displayMirrorToggle.active"] == nil)

	module = loadModule({ builtIn })
	assert(module.status() == "unavailable")
	success, state = module.toggle()
	assert(not success and state == "Expected one external display, found 0")

	module = loadModule({ builtIn, screen("Display A"), screen("Display B") })
	success, state = module.toggle()
	assert(not success and state == "Expected one external display, found 2")

	module = loadModule({ screen("PA278CV") })
	success, state = module.toggle()
	assert(not success and state == "Built-in display not found")

	external = screen("PA278CV", false)
	module, settings = loadModule({ builtIn, external })
	success, state = module.toggle()
	assert(not success and state == "Hammerspoon could not start display mirroring")
	assert(settings["linkarzu.displayMirrorToggle.active"] == nil)

	module = loadModule({ builtIn }, { ["linkarzu.displayMirrorToggle.active"] = true })
	assert(module.status() == "recovery-required")
	success, state = module.toggle()
	assert(not success and state:match("reloaded while mirroring"))

	module, settings = loadModule({ builtIn, screen("PA278CV") }, {
		["linkarzu.displayMirrorToggle.active"] = true,
	})
	assert(module.status() == "extended")
	assert(settings["linkarzu.displayMirrorToggle.active"] == nil)

	external = screen("PA278CV", true, false)
	module, settings = loadModule({ builtIn, external })
	assert(module.toggle())
	success, state = module.toggle()
	assert(not success and state == "Hammerspoon could not stop display mirroring")
	assert(settings["linkarzu.displayMirrorToggle.active"] == true)
end, debug.traceback)

hs = savedHs
assert(ok, err)
print("display_mirror_toggle_test: all scenarios passed")
