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
	font = wezterm.font("JetBrains Mono"),
	font_size = 14.5,

	-- I don't use tabs
	enable_tab_bar = false,

	window_close_confirmation = "NeverPrompt",
	colors = {
		-- The default text color
		foreground = colors["linkarzu_color14"],
		-- The default background color
		background = colors["linkarzu_color10"],

		-- Overrides the cell background color when the current cell is occupied by the cursor
		cursor_bg = colors["linkarzu_color02"],
		-- Overrides the text color when the current cell is occupied by the cursor
		cursor_fg = colors["linkarzu_color14"],
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
