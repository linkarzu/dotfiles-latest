-- Filename: ~/github/dotfiles-latest/wezterm/wezterm.lua
-- ~/github/dotfiles-latest/wezterm/wezterm.lua

-- Pull in the wezterm API
local wezterm = require("wezterm")

-- Load the colors from my existing neobean colors.lua file
local colors = dofile(os.getenv("HOME") .. "/github/dotfiles-latest/neovim/neobean/lua/config/colors.lua")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices
config = {

	-- -- Setting the term to wezterm is what allows support for undercurl
	-- --
	-- -- BEFORE you can set the term to wezterm, you need to install a copy of the
	-- -- wezterm TERM definition
	-- -- https://wezfurlong.org/wezterm/config/lua/config/term.html?h=term
	-- -- https://github.com/wez/wezterm/blob/main/termwiz/data/wezterm.terminfo
	-- --
	-- -- If you're using tmux, set your tmux.conf file to:
	-- -- set -g default-terminal "${TERM}"
	-- -- So that it picks up the wezterm TERM we're defining here
	-- --
	-- -- NOTE: When inside neovim, run a `checkhealth` and under `tmux` you will see that
	-- -- the term is set to `wezterm`. If the term is set to something else:
	-- -- - Reload your tmux configuration,
	-- -- - Then close all your tmux sessions, one at a time and quit wezterm
	-- -- - re-open wezterm
	-- term = "wezterm",
	-- term = "xterm-256color",

	-- When using the wezterm terminfo file, I had issues with images in neovim, images
	-- were shown like split in half, and some part of the image always stayed on the
	-- screen until I quit neovim
	--
	-- Images are working wonderfully in kitty, so decided to try the kitty.terminfo file
	-- https://github.com/kovidgoyal/kitty/blob/master/terminfo/kitty.terminfo
	--
	-- NOTE: I added a modified version of this in my zshrc file, so if the kitty terminfo
	-- file is not present it will be downloaded and installed automatically
	--
	-- But if you want to manually download and install the kitty terminfo file
	-- run the command below on your terminal:
	-- tempfile=$(mktemp) && curl -o "$tempfile" https://raw.githubusercontent.com/kovidgoyal/kitty/master/terminfo/kitty.terminfo && tic -x -o ~/.terminfo "$tempfile" && rm "$tempfile"
	--
	-- NOTE: When inside neovim, run a `checkhealth` and under `tmux` you will see that
	-- the term is set to `xterm-kitty`. If the term is set to something else:
	-- - Reload your tmux configuration,
	-- - Then close all your tmux sessions, one at a time and quit wezterm
	-- - re-open wezterm
	--
	-- Then you'll be able to set your terminal to `xterm-kitty` as seen below
	term = "xterm-kitty",

	-- To enable kitty graphics
	-- https://github.com/wez/wezterm/issues/986
	-- It seems that kitty graphics is not enabled by default according to this
	-- Not sure, so I'm enabling it just in case
	-- https://github.com/wez/wezterm/issues/1406#issuecomment-996253377
	enable_kitty_graphics = true,

	-- I got the GPU settings below from a comment by user @anthonyknowles
	-- In my wezterm video and will test them out
	-- https://youtu.be/ibCPb4tSRXM
	-- https://wezfurlong.org/wezterm/config/lua/config/animation_fps.html?h=animation
	-- animation_fps = 120,

	-- Limits the maximum number of frames per second that wezterm will attempt to draw
	-- I tried settings this value to 5, 15, 30, 60 and you do feel a difference
	-- It feels WAY SMOOTHER at 120
	-- In my humble opiniont, 120 should be the default as I'm not the only one
	-- experiencing this "performance" issue in wezterm
	-- https://wezfurlong.org/wezterm/config/lua/config/max_fps.html
	max_fps = 120,

	-- front_end = "WebGpu" - will more directly use Metal than the OpenGL
	-- The default is "WebGpu". In earlier versions it was "OpenGL"
	-- Metal translation used on M1 machines, may yield some more fps.
	-- https://github.com/wez/wezterm/discussions/3664
	-- https://wezfurlong.org/wezterm/config/lua/config/front_end.html?h=front_
	-- front_end = "WebGpu",

	-- https://wezfurlong.org/wezterm/config/lua/config/webgpu_preferred_adapter.html?h=webgpu_preferred_adapter
	-- webgpu_preferred_adapter

	-- webgpu_power_preference = "LowPower"
	-- https://wezfurlong.org/wezterm/config/lua/config/webgpu_power_preference.html

	-- I use this for ñ and tildes in spanish á é í ó ú
	-- If you're a gringo, you wouldn't understand :wink:
	-- https://github.com/wez/wezterm/discussions/4650
	send_composed_key_when_left_alt_is_pressed = true,

	-- default_prog = {
	-- 	"/bin/zsh",
	-- 	"--login",
	-- 	"-c",
	-- 	[[
	--    if command -v tmux >/dev/null 2>&1; then
	--      tmux attach || tmux new;
	--    else
	--      exec zsh;
	--    fi
	--    ]],
	-- },

	-- For example, changing the color scheme:
	-- color_scheme = "AdventureTime"

	-- Removes the macos bar at the top with the 3 buttons
	window_decorations = "RESIZE",

	-- https://wezfurlong.org/wezterm/config/lua/wezterm/font.html
	-- font = wezterm.font("JetBrainsMono Nerd Font", { weight = "Bold" }),
	font = wezterm.font("JetBrainsMono Nerd Font"),
	-- font_size = 14.5,
	font_size = 15,

	-- I don't use tabs
	enable_tab_bar = false,

	window_close_confirmation = "NeverPrompt",

	-- -- NOTE: My cursor was not blinking when using wezterm with the "wezterm" terminfo
	-- -- Setting my term to "xterm-kitty" fixed the issue
	-- -- I also use the zsh-vi-mode plugin, I had to set up the blinking cursor
	-- -- for that in my zshrc file
	-- -- Neovim didn't need cursor changes, worked by setting it to "xterm-kitty"
	-- --
	default_cursor_style = "SteadyBlock",
	-- default_cursor_style = "BlinkingBlock",

	-- I don't like the the "Linear", which gives it a fade effect between blinks
	cursor_blink_ease_out = "Constant",
	cursor_blink_ease_in = "Constant",
	-- Setting this to 0 disables blinking
	cursor_blink_rate = 0,

	window_padding = {
		left = 2,
		right = 2,
		top = 15,
		bottom = 0,
	},

	colors = {
		-- The default text color
		foreground = colors["linkarzu_color14"],
		-- The default background color
		background = colors["linkarzu_color10"],

		-- Overrides the cell background color when the current cell is occupied by the cursor
		cursor_bg = colors["linkarzu_color24"],
		-- Overrides the text color when the current cell is occupied by the cursor
		cursor_fg = colors["linkarzu_color10"],
		-- Specifies the border color of the cursor when the cursor style is set to Block
		cursor_border = colors["linkarzu_color02"],

		-- The foreground color of selected text
		selection_fg = colors["linkarzu_color14"],
		-- The background color of selected text
		selection_bg = colors["linkarzu_color16"],

		-- The color of the scrollbar "thumb"; the portion that represents the current viewport
		scrollbar_thumb = colors["linkarzu_color10"],

		-- The color of the split lines between panes
		split = colors["linkarzu_color02"],

		-- ANSI color palette
		ansi = {
			colors["linkarzu_color10"], -- black
			colors["linkarzu_color11"], -- red
			colors["linkarzu_color02"], -- green
			colors["linkarzu_color05"], -- yellow
			colors["linkarzu_color04"], -- blue
			colors["linkarzu_color01"], -- magenta
			colors["linkarzu_color03"], -- cyan
			colors["linkarzu_color14"], -- white
		},

		-- Bright ANSI color palette
		brights = {
			colors["linkarzu_color08"], -- bright black
			colors["linkarzu_color11"], -- bright red
			colors["linkarzu_color02"], -- bright green
			colors["linkarzu_color05"], -- bright yellow
			colors["linkarzu_color04"], -- bright blue
			colors["linkarzu_color01"], -- bright magenta
			colors["linkarzu_color03"], -- bright cyan
			colors["linkarzu_color14"], -- bright white
		},
	},
}

-- return the configuration to wezterm
return config
