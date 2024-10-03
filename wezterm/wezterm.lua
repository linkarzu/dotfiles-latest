-- Filename: ~/github/dotfiles-latest/wezterm/wezterm.lua
-- ~/github/dotfiles-latest/wezterm/wezterm.lua

-- Pull in the wezterm API
local wezterm = require("wezterm")

-- Load the colors from my existing neobean colors.lua file
local colors_module = dofile(os.getenv("HOME") .. "/github/dotfiles-latest/neovim/neobean/lua/config/colors.lua")
local colors = colors_module.load_colors()

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices
config = {

	--[=====[
	Setting the term to wezterm is what allows support for undercurl

	BEFORE you can set the term to wezterm, you need to install a copy of the
	wezterm TERM definition
	https://wezfurlong.org/wezterm/config/lua/config/term.html?h=term

	If you're using tmux, set your tmux.conf file to:
	set -g default-terminal "${TERM}"
	So that it picks up the wezterm TERM we're defining here

	When inside neovim, run a `checkhealth` and under `tmux` you will see that
	the term is set to `wezterm`. If the term is set to something else:
	Reload your tmux configuration, then close all your tmux sessions to quit the
	terminal and re-open it
  --]=====]
	term = "wezterm",

	default_prog = {
		"/bin/zsh",
		"--login",
		"-c",
		[[
	   if command -v tmux >/dev/null 2>&1; then
	     tmux attach || tmux new;
	   else
	     exec zsh;
	   fi
	   ]],
	},

	-- For example, changing the color scheme:
	-- color_scheme = "AdventureTime"

	-- Removes the macos bar at the top with the 3 buttons
	window_decorations = "RESIZE",

	-- https://wezfurlong.org/wezterm/config/lua/wezterm/font.html
	-- font = wezterm.font("JetBrains Mono", { weight = "Bold" }),
	font = wezterm.font("JetBrains Mono"),
	-- font_size = 14.5,
	font_size = 15,

	-- I don't use tabs
	enable_tab_bar = false,

	window_close_confirmation = "NeverPrompt",

	-- I don't like the the "Linear", which gives it a fade effect between blinks
	cursor_blink_ease_out = "Constant",
	cursor_blink_ease_in = "Constant",
	cursor_blink_rate = 400,

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
		cursor_bg = colors["linkarzu_color14"],
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
