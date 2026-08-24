local M = {}

local function sameApplication(left, right)
	return left and right and left:pid() == right:pid()
end

function M.ensureFrontmost(app, targetWindow)
	if not app then
		return false
	end
	local frontmost = hs.application.frontmostApplication()
	local focusedWindow = hs.window.focusedWindow()
	if
		sameApplication(frontmost, app)
		and focusedWindow
		and sameApplication(focusedWindow:application(), app)
		and (not targetWindow or focusedWindow:id() == targetWindow:id())
	then
		return true
	end
	app:activate(true)
	if targetWindow then
		targetWindow:focus()
		targetWindow:raise()
	end
	if not sameApplication(hs.application.frontmostApplication(), app) then
		return false
	end
	focusedWindow = hs.window.focusedWindow()
	if not focusedWindow or not sameApplication(focusedWindow:application(), app) then
		return false
	end
	return not targetWindow or focusedWindow:id() == targetWindow:id()
end

function M.leftClick(app, point, targetWindow)
	if not M.ensureFrontmost(app, targetWindow) then
		return false
	end
	hs.eventtap.leftClick(point)
	return true
end

function M.performAction(app, element, action, targetWindow)
	if not M.ensureFrontmost(app, targetWindow) then
		return false
	end
	local ok, result = pcall(function()
		return element:performAction(action)
	end)
	return ok and result ~= nil and result ~= false
end

return M
