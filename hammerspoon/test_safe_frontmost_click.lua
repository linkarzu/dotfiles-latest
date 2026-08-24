local currentFront
local currentWindow
local clicks = 0

hs = {
	application = {
		frontmostApplication = function()
			return currentFront
		end,
	},
	window = {
		focusedWindow = function()
			return currentWindow
		end,
	},
	eventtap = {
		leftClick = function()
			clicks = clicks + 1
		end,
	},
}

local function application(pid, activates)
	local app = { _pid = pid, _activations = 0 }
	function app:pid()
		return self._pid
	end
	function app:activate()
		self._activations = self._activations + 1
		if activates then
			currentFront = self
			currentWindow = {
				application = function()
					return self
				end,
			}
		end
	end
	return app
end

local function window(id, app)
	local candidate = { _id = id, _focuses = 0 }
	function candidate:id()
		return self._id
	end
	function candidate:application()
		return app
	end
	function candidate:focus()
		self._focuses = self._focuses + 1
		currentFront = app
		currentWindow = self
	end
	function candidate:raise() end
	return candidate
end

local click = require("safe_frontmost_click")
local qat = application(1, false)
local target = application(2, true)

currentFront = qat
currentWindow = { application = function() return qat end }
assert(click.leftClick(target, { x = 10, y = 10 }))
assert(clicks == 1, "target activation must occur before clicking")

local wrongStudioWindow = window(20, target)
local broadcastWindow = window(21, target)
target.activate = function()
	currentFront = target
	currentWindow = wrongStudioWindow
end
currentFront = qat
currentWindow = { application = function() return qat end }
assert(click.leftClick(target, { x = 10, y = 10 }, broadcastWindow))
assert(currentWindow:id() == 21, "the exact broadcast window must be restored before clicking")
assert(clicks == 2)

local alreadyFrontmost = application(4, true)
local alreadyFocused = window(40, alreadyFrontmost)
currentFront = alreadyFrontmost
currentWindow = alreadyFocused
assert(click.leftClick(alreadyFrontmost, { x = 10, y = 10 }, alreadyFocused))
assert(alreadyFrontmost._activations == 0, "an already-frontmost app must not be reactivated before clicking")
assert(alreadyFocused._focuses == 0, "an already-focused target must not be refocused before clicking")
assert(clicks == 3)

local blockedTarget = application(3, false)
currentFront = qat
currentWindow = { application = function() return qat end }
assert(not click.leftClick(blockedTarget, { x = 10, y = 10 }))
assert(clicks == 3, "a QAT-frontmost focus failure must suppress the click")

currentFront = target
currentWindow = { application = function() return qat end }
target.activate = function() currentFront = target end
assert(not click.leftClick(target, { x = 10, y = 10 }))
assert(clicks == 3, "a foreign focused window must suppress the click")

print("safe_frontmost_click tests passed")
