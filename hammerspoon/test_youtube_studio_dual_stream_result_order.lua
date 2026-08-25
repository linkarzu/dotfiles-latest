local sourcePath = debug.getinfo(1, "S").source:sub(2):gsub("test_youtube_studio_dual_stream_result_order.lua$", "youtube_studio_dual_stream.lua")
local file = assert(io.open(sourcePath, "r"))
local source = file:read("*a")
file:close()

local safeLogBody = assert(source:match("local function safeLog%b()%s*(.-)%s*end%s*\n%s*local function attribute"))
assert(safeLogBody:find("pcall", 1, true), "Dual Stream logging must contain logger failures")
local safeLog = assert(load("return function(method, message)\n" .. safeLogBody .. "\nend"))()
local loggerFailureContained = pcall(safeLog, function()
	error("expired Hammerspoon IPC port")
end, "verified")
assert(loggerFailureContained, "a logger failure must not escape the Dual Stream callback")
assert(not source:match("[^%w]log%.[iew]%s*%("), "Dual Stream callbacks must not call the logger without safeLog")

local finishPosition = assert(source:find('finish(id, "ok", "verified")', 1, true))
local successLogPosition = assert(
	source:find('safeLog(log.i, "Verified YouTube Studio Dual stream encoder configuration")', 1, true)
)
assert(finishPosition < successLogPosition, "verified result must be published before optional logging")

print("youtube_studio_dual_stream result-order tests passed")
