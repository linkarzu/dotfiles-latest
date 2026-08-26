-- Filename: ~/github/dotfiles-latest/hammerspoon/init.lua
-- ~/github/dotfiles-latest/hammerspoon/init.lua

-- require("cursor_escape")
-- require("lgtv_init")
hs.autoLaunch(true)
require("hs.ipc")

local obsMeetingManagerModules = os.getenv("HOME")
  .. "/github/dotfiles-private/scripts/macos/mac/obs-meeting-manager/hammerspoon/?.lua"
package.path = obsMeetingManagerModules .. ";" .. package.path

require("move_mouse_to_corner")
require("clipboard_feedback")
opencodePopup = require("opencode_popup")
applePopup = require("apple_popup")
require("obs_aitum")
require("obs_brave_audio")
require("youtube_studio_dual_stream")
require("dnd")
