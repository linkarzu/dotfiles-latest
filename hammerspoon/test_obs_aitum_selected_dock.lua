local sourcePath = debug.getinfo(1, "S").source:sub(2):gsub("test_obs_aitum_selected_dock.lua$", "obs_aitum.lua")
local file = assert(io.open(sourcePath, "r"))
local source = file:read("*a")
file:close()

assert(source:find('findText(elements, "Aitum Multistream", true)', 1, true), "Aitum must be selected")
assert(not source:find("lower-thirds", 1, true), "Aitum automation must not select the Lower Thirds dock")
assert(not source:find("kitty-quick-access", 1, true), "Aitum automation must not hide unrelated QATs")
assert(not source:find("hideQatWindows", 1, true), "The originating flow must own the exact QAT transition")

print("obs_aitum selected-dock tests passed")
