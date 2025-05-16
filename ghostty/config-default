# The font families to use.
# 
# You can generate the list of valid values using the CLI:
# 
#     ghostty +list-fonts
# 
# This configuration can be repeated multiple times to specify preferred
# fallback fonts when the requested codepoint is not available in the primary
# font. This is particularly useful for multiple languages, symbolic fonts,
# etc.
# 
# Notes on emoji specifically: On macOS, Ghostty by default will always use
# Apple Color Emoji and on Linux will always use Noto Emoji. You can
# override this behavior by specifying a font family here that contains
# emoji glyphs.
# 
# The specific styles (bold, italic, bold italic) do not need to be
# explicitly set. If a style is not set, then the regular style (font-family)
# will be searched for stylistic variants. If a stylistic variant is not
# found, Ghostty will use the regular style. This prevents falling back to a
# different font family just to get a style such as bold. This also applies
# if you explicitly specify a font family for a style. For example, if you
# set `font-family-bold = FooBar` and "FooBar" cannot be found, Ghostty will
# use whatever font is set for `font-family` for the bold style.
# 
# Finally, some styles may be synthesized if they are not supported.
# For example, if a font does not have an italic style and no alternative
# italic font is specified, Ghostty will synthesize an italic style by
# applying a slant to the regular style. If you want to disable these
# synthesized styles then you can use the `font-style` configurations
# as documented below.
# 
# You can disable styles completely by using the `font-style` set of
# configurations. See the documentation for `font-style` for more information.
# 
# If you want to overwrite a previous set value rather than append a fallback,
# specify the value as `""` (empty string) to reset the list and then set the
# new values. For example:
# 
#     font-family = ""
#     font-family = "My Favorite Font"
# 
# Setting any of these as CLI arguments will automatically clear the
# values set in configuration files so you don't need to specify
# `--font-family=""` before setting a new value. You only need to specify
# this within config files if you want to clear previously set values in
# configuration files or on the CLI if you want to clear values set on the
# CLI.
# 
# Changing this configuration at runtime will only affect new terminals, i.e.
# new windows, tabs, etc.
font-family = 

font-family-bold = 
font-family-italic = 
font-family-bold-italic = 
# The named font style to use for each of the requested terminal font styles.
# This looks up the style based on the font style string advertised by the
# font itself. For example, "Iosevka Heavy" has a style of "Heavy".
# 
# You can also use these fields to completely disable a font style. If you set
# the value of the configuration below to literal `false` then that font style
# will be disabled. If the running program in the terminal requests a disabled
# font style, the regular font style will be used instead.
# 
# These are only valid if its corresponding font-family is also specified. If
# no font-family is specified, then the font-style is ignored unless you're
# disabling the font style.
font-style = default

font-style-bold = default
font-style-italic = default
font-style-bold-italic = default
# Control whether Ghostty should synthesize a style if the requested style is
# not available in the specified font-family.
# 
# Ghostty can synthesize bold, italic, and bold italic styles if the font
# does not have a specific style. For bold, this is done by drawing an
# outline around the glyph of varying thickness. For italic, this is done by
# applying a slant to the glyph. For bold italic, both of these are applied.
# 
# Synthetic styles are not perfect and will generally not look as good
# as a font that has the style natively. However, they are useful to
# provide styled text when the font does not have the style.
# 
# Set this to "false" or "true" to disable or enable synthetic styles
# completely. You can disable specific styles using "no-bold", "no-italic",
# and "no-bold-italic". You can disable multiple styles by separating them
# with a comma. For example, "no-bold,no-italic".
# 
# Available style keys are: `bold`, `italic`, `bold-italic`.
# 
# If synthetic styles are disabled, then the regular style will be used
# instead if the requested style is not available. If the font has the
# requested style, then the font will be used as-is since the style is
# not synthetic.
# 
# Warning: An easy mistake is to disable `bold` or `italic` but not
# `bold-italic`. Disabling only `bold` or `italic` will NOT disable either
# in the `bold-italic` style. If you want to disable `bold-italic`, you must
# explicitly disable it. You cannot partially disable `bold-italic`.
# 
# By default, synthetic styles are enabled.
font-synthetic-style = bold,italic,bold-italic

# Apply a font feature. To enable multiple font features you can repeat
# this multiple times or use a comma-separated list of feature settings.
# 
# The syntax for feature settings is as follows, where `feat` is a feature:
# 
#   * Enable features with e.g. `feat`, `+feat`, `feat on`, `feat=1`.
#   * Disabled features with e.g. `-feat`, `feat off`, `feat=0`.
#   * Set a feature value with e.g. `feat=2`, `feat = 3`, `feat 4`.
#   * Feature names may be wrapped in quotes, meaning this config should be
#     syntactically compatible with the `font-feature-settings` CSS property.
# 
# The syntax is fairly loose, but invalid settings will be silently ignored.
# 
# The font feature will apply to all fonts rendered by Ghostty. A future
# enhancement will allow targeting specific faces.
# 
# To disable programming ligatures, use `-calt` since this is the typical
# feature name for programming ligatures. To look into what font features
# your font has and what they do, use a font inspection tool such as
# [fontdrop.info](https://fontdrop.info).
# 
# To generally disable most ligatures, use `-calt, -liga, -dlig`.
font-feature = 

# Font size in points. This value can be a non-integer and the nearest integer
# pixel size will be selected. If you have a high dpi display where 1pt = 2px
# then you can get an odd numbered pixel size by specifying a half point.
# 
# For example, 13.5pt @ 2px/pt = 27px
# 
# Changing this configuration at runtime will only affect new terminals,
# i.e. new windows, tabs, etc. Note that you may still not see the change
# depending on your `window-inherit-font-size` setting. If that setting is
# true, only the first window will be affected by this change since all
# subsequent windows will inherit the font size of the previous window.
# 
# On Linux with GTK, font size is scaled according to both display-wide and
# text-specific scaling factors, which are often managed by your desktop
# environment (e.g. the GNOME display scale and large text settings).
font-size = 13

# A repeatable configuration to set one or more font variations values for
# a variable font. A variable font is a single font, usually with a filename
# ending in `-VF.ttf` or `-VF.otf` that contains one or more configurable axes
# for things such as weight, slant, etc. Not all fonts support variations;
# only fonts that explicitly state they are variable fonts will work.
# 
# The format of this is `id=value` where `id` is the axis identifier. An axis
# identifier is always a 4 character string, such as `wght`. To get the list
# of supported axes, look at your font documentation or use a font inspection
# tool.
# 
# Invalid ids and values are usually ignored. For example, if a font only
# supports weights from 100 to 700, setting `wght=800` will do nothing (it
# will not be clamped to 700). You must consult your font's documentation to
# see what values are supported.
# 
# Common axes are: `wght` (weight), `slnt` (slant), `ital` (italic), `opsz`
# (optical size), `wdth` (width), `GRAD` (gradient), etc.
font-variation = 

font-variation-bold = 
font-variation-italic = 
font-variation-bold-italic = 
# Force one or a range of Unicode codepoints to map to a specific named font.
# This is useful if you want to support special symbols or if you want to use
# specific glyphs that render better for your specific font.
# 
# The syntax is `codepoint=fontname` where `codepoint` is either a single
# codepoint or a range. Codepoints must be specified as full Unicode
# hex values, such as `U+ABCD`. Codepoints ranges are specified as
# `U+ABCD-U+DEFG`. You can specify multiple ranges for the same font separated
# by commas, such as `U+ABCD-U+DEFG,U+1234-U+5678=fontname`. The font name is
# the same value as you would use for `font-family`.
# 
# This configuration can be repeated multiple times to specify multiple
# codepoint mappings.
# 
# Changing this configuration at runtime will only affect new terminals,
# i.e. new windows, tabs, etc.
font-codepoint-map = 

# Draw fonts with a thicker stroke, if supported.
# This is currently only supported on macOS.
font-thicken = false

# Strength of thickening when `font-thicken` is enabled.
# 
# Valid values are integers between `0` and `255`. `0` does not correspond to
# *no* thickening, rather it corresponds to the lightest available thickening.
# 
# Has no effect when `font-thicken` is set to `false`.
# 
# This is currently only supported on macOS.
font-thicken-strength = 255

# What color space to use when performing alpha blending.
# 
# This affects the appearance of text and of any images with transparency.
# Additionally, custom shaders will receive colors in the configured space.
# 
# Valid values:
# 
# * `native` - Perform alpha blending in the native color space for the OS.
#   On macOS this corresponds to Display P3, and on Linux it's sRGB.
# 
# * `linear` - Perform alpha blending in linear space. This will eliminate
#   the darkening artifacts around the edges of text that are very visible
#   when certain color combinations are used (e.g. red / green), but makes
#   dark text look much thinner than normal and light text much thicker.
#   This is also sometimes known as "gamma correction".
#   (Currently only supported on macOS. Has no effect on Linux.)
# 
# * `linear-corrected` - Same as `linear`, but with a correction step applied
#   for text that makes it look nearly or completely identical to `native`,
#   but without any of the darkening artifacts.
alpha-blending = native

# All of the configurations behavior adjust various metrics determined by the
# font. The values can be integers (1, -1, etc.) or a percentage (20%, -15%,
# etc.). In each case, the values represent the amount to change the original
# value.
# 
# For example, a value of `1` increases the value by 1; it does not set it to
# literally 1. A value of `20%` increases the value by 20%. And so on.
# 
# There is little to no validation on these values so the wrong values (e.g.
# `-100%`) can cause the terminal to be unusable. Use with caution and reason.
# 
# Some values are clamped to minimum or maximum values. This can make it
# appear that certain values are ignored. For example, many `*-thickness`
# adjustments cannot go below 1px.
# 
# `adjust-cell-height` has some additional behaviors to describe:
# 
#   * The font will be centered vertically in the cell.
# 
#   * The cursor will remain the same size as the font, but may be
#     adjusted separately with `adjust-cursor-height`.
# 
#   * Powerline glyphs will be adjusted along with the cell height so
#     that things like status lines continue to look aligned.
adjust-cell-width = 

adjust-cell-height = 
# Distance in pixels or percentage adjustment from the bottom of the cell to the text baseline.
# Increase to move baseline UP, decrease to move baseline DOWN.
# See the notes about adjustments in `adjust-cell-width`.
adjust-font-baseline = 

# Distance in pixels or percentage adjustment from the top of the cell to the top of the underline.
# Increase to move underline DOWN, decrease to move underline UP.
# See the notes about adjustments in `adjust-cell-width`.
adjust-underline-position = 

# Thickness in pixels of the underline.
# See the notes about adjustments in `adjust-cell-width`.
adjust-underline-thickness = 

# Distance in pixels or percentage adjustment from the top of the cell to the top of the strikethrough.
# Increase to move strikethrough DOWN, decrease to move strikethrough UP.
# See the notes about adjustments in `adjust-cell-width`.
adjust-strikethrough-position = 

# Thickness in pixels or percentage adjustment of the strikethrough.
# See the notes about adjustments in `adjust-cell-width`.
adjust-strikethrough-thickness = 

# Distance in pixels or percentage adjustment from the top of the cell to the top of the overline.
# Increase to move overline DOWN, decrease to move overline UP.
# See the notes about adjustments in `adjust-cell-width`.
adjust-overline-position = 

# Thickness in pixels or percentage adjustment of the overline.
# See the notes about adjustments in `adjust-cell-width`.
adjust-overline-thickness = 

# Thickness in pixels or percentage adjustment of the bar cursor and outlined rect cursor.
# See the notes about adjustments in `adjust-cell-width`.
adjust-cursor-thickness = 

# Height in pixels or percentage adjustment of the cursor. Currently applies to all cursor types:
# bar, rect, and outlined rect.
# See the notes about adjustments in `adjust-cell-width`.
adjust-cursor-height = 

# Thickness in pixels or percentage adjustment of box drawing characters.
# See the notes about adjustments in `adjust-cell-width`.
adjust-box-thickness = 

# The method to use for calculating the cell width of a grapheme cluster.
# The default value is `unicode` which uses the Unicode standard to determine
# grapheme width. This results in correct grapheme width but may result in
# cursor-desync issues with some programs (such as shells) that may use a
# legacy method such as `wcswidth`.
# 
# Valid values are:
# 
# * `legacy` - Use a legacy method to determine grapheme width, such as
#   wcswidth This maximizes compatibility with legacy programs but may result
#   in incorrect grapheme width for certain graphemes such as skin-tone
#   emoji, non-English characters, etc.
# 
#   This is called "legacy" and not something more specific because the
#   behavior is undefined and we want to retain the ability to modify it.
#   For example, we may or may not use libc `wcswidth` now or in the future.
# 
# * `unicode` - Use the Unicode standard to determine grapheme width.
# 
# If a running program explicitly enables terminal mode 2027, then `unicode`
# width will be forced regardless of this configuration. When mode 2027 is
# reset, this configuration will be used again.
# 
# This configuration can be changed at runtime but will not affect existing
# terminals. Only new terminals will use the new configuration.
grapheme-width-method = unicode

# FreeType load flags to enable. The format of this is a list of flags to
# enable separated by commas. If you prefix a flag with `no-` then it is
# disabled. If you omit a flag, its default value is used, so you must
# explicitly disable flags you don't want. You can also use `true` or `false`
# to turn all flags on or off.
# 
# This configuration only applies to Ghostty builds that use FreeType.
# This is usually the case only for Linux builds. macOS uses CoreText
# and does not have an equivalent configuration.
# 
# Available flags:
# 
#   * `hinting` - Enable or disable hinting, enabled by default.
#   * `force-autohint` - Use the freetype auto-hinter rather than the
#     font's native hinter. Enabled by default.
#   * `monochrome` - Instructs renderer to use 1-bit monochrome
#     rendering. This option doesn't impact the hinter.
#     Enabled by default.
#   * `autohint` - Use the freetype auto-hinter. Enabled by default.
# 
# Example: `hinting`, `no-hinting`, `force-autohint`, `no-force-autohint`
freetype-load-flags = hinting,force-autohint,monochrome,autohint

# A theme to use. This can be a built-in theme name, a custom theme
# name, or an absolute path to a custom theme file. Ghostty also supports
# specifying a different theme to use for light and dark mode. Each
# option is documented below.
# 
# If the theme is an absolute pathname, Ghostty will attempt to load that
# file as a theme. If that file does not exist or is inaccessible, an error
# will be logged and no other directories will be searched.
# 
# If the theme is not an absolute pathname, two different directories will be
# searched for a file name that matches the theme. This is case sensitive on
# systems with case-sensitive filesystems. It is an error for a theme name to
# include path separators unless it is an absolute pathname.
# 
# The first directory is the `themes` subdirectory of your Ghostty
# configuration directory. This is `$XDG_CONFIG_DIR/ghostty/themes` or
# `~/.config/ghostty/themes`.
# 
# The second directory is the `themes` subdirectory of the Ghostty resources
# directory. Ghostty ships with a multitude of themes that will be installed
# into this directory. On macOS, this list is in the
# `Ghostty.app/Contents/Resources/ghostty/themes` directory. On Linux, this
# list is in the `share/ghostty/themes` directory (wherever you installed the
# Ghostty "share" directory.
# 
# To see a list of available themes, run `ghostty +list-themes`.
# 
# A theme file is simply another Ghostty configuration file. They share
# the same syntax and same configuration options. A theme can set any valid
# configuration option so please do not use a theme file from an untrusted
# source. The built-in themes are audited to only set safe configuration
# options.
# 
# Some options cannot be set within theme files. The reason these are not
# supported should be self-evident. A theme file cannot set `theme` or
# `config-file`. At the time of writing this, Ghostty will not show any
# warnings or errors if you set these options in a theme file but they will
# be silently ignored.
# 
# Any additional colors specified via background, foreground, palette, etc.
# will override the colors specified in the theme.
# 
# To specify a different theme for light and dark mode, use the following
# syntax: `light:theme-name,dark:theme-name`. For example:
# `light:rose-pine-dawn,dark:rose-pine`. Whitespace around all values are
# trimmed and order of light and dark does not matter. Both light and dark
# must be specified in this form. In this form, the theme used will be
# based on the current desktop environment theme.
# 
# There are some known bugs with light/dark mode theming. These will
# be fixed in a future update:
# 
#   - macOS: titlebar tabs style is not updated when switching themes.
# 
theme = 

# Background color for the window.
# Specified as either hex (`#RRGGBB` or `RRGGBB`) or a named X11 color.
background = #282c34

# Foreground color for the window.
# Specified as either hex (`#RRGGBB` or `RRGGBB`) or a named X11 color.
foreground = #ffffff

# The foreground and background color for selection. If this is not set, then
# the selection color is just the inverted window background and foreground
# (note: not to be confused with the cell bg/fg).
# Specified as either hex (`#RRGGBB` or `RRGGBB`) or a named X11 color.
selection-foreground = 

selection-background = 
# Swap the foreground and background colors of cells for selection. This
# option overrides the `selection-foreground` and `selection-background`
# options.
# 
# If you select across cells with differing foregrounds and backgrounds, the
# selection color will vary across the selection.
selection-invert-fg-bg = false

# The minimum contrast ratio between the foreground and background colors.
# The contrast ratio is a value between 1 and 21. A value of 1 allows for no
# contrast (e.g. black on black). This value is the contrast ratio as defined
# by the [WCAG 2.0 specification](https://www.w3.org/TR/WCAG20/).
# 
# If you want to avoid invisible text (same color as background), a value of
# 1.1 is a good value. If you want to avoid text that is difficult to read, a
# value of 3 or higher is a good value. The higher the value, the more likely
# that text will become black or white.
# 
# This value does not apply to Emoji or images.
minimum-contrast = 1

# Color palette for the 256 color form that many terminal applications use.
# The syntax of this configuration is `N=COLOR` where `N` is 0 to 255 (for
# the 256 colors in the terminal color table) and `COLOR` is a typical RGB
# color code such as `#AABBCC` or `AABBCC`, or a named X11 color.
# 
# The palette index can be in decimal, binary, octal, or hexadecimal.
# Decimal is assumed unless a prefix is used: `0b` for binary, `0o` for octal,
# and `0x` for hexadecimal.
# 
# For definitions on the color indices and what they canonically map to,
# [see this cheat sheet](https://www.ditig.com/256-colors-cheat-sheet).
palette = 0=#1d1f21
palette = 1=#cc6666
palette = 2=#b5bd68
palette = 3=#f0c674
palette = 4=#81a2be
palette = 5=#b294bb
palette = 6=#8abeb7
palette = 7=#c5c8c6
palette = 8=#666666
palette = 9=#d54e53
palette = 10=#b9ca4a
palette = 11=#e7c547
palette = 12=#7aa6da
palette = 13=#c397d8
palette = 14=#70c0b1
palette = 15=#eaeaea
palette = 16=#000000
palette = 17=#00005f
palette = 18=#000087
palette = 19=#0000af
palette = 20=#0000d7
palette = 21=#0000ff
palette = 22=#005f00
palette = 23=#005f5f
palette = 24=#005f87
palette = 25=#005faf
palette = 26=#005fd7
palette = 27=#005fff
palette = 28=#008700
palette = 29=#00875f
palette = 30=#008787
palette = 31=#0087af
palette = 32=#0087d7
palette = 33=#0087ff
palette = 34=#00af00
palette = 35=#00af5f
palette = 36=#00af87
palette = 37=#00afaf
palette = 38=#00afd7
palette = 39=#00afff
palette = 40=#00d700
palette = 41=#00d75f
palette = 42=#00d787
palette = 43=#00d7af
palette = 44=#00d7d7
palette = 45=#00d7ff
palette = 46=#00ff00
palette = 47=#00ff5f
palette = 48=#00ff87
palette = 49=#00ffaf
palette = 50=#00ffd7
palette = 51=#00ffff
palette = 52=#5f0000
palette = 53=#5f005f
palette = 54=#5f0087
palette = 55=#5f00af
palette = 56=#5f00d7
palette = 57=#5f00ff
palette = 58=#5f5f00
palette = 59=#5f5f5f
palette = 60=#5f5f87
palette = 61=#5f5faf
palette = 62=#5f5fd7
palette = 63=#5f5fff
palette = 64=#5f8700
palette = 65=#5f875f
palette = 66=#5f8787
palette = 67=#5f87af
palette = 68=#5f87d7
palette = 69=#5f87ff
palette = 70=#5faf00
palette = 71=#5faf5f
palette = 72=#5faf87
palette = 73=#5fafaf
palette = 74=#5fafd7
palette = 75=#5fafff
palette = 76=#5fd700
palette = 77=#5fd75f
palette = 78=#5fd787
palette = 79=#5fd7af
palette = 80=#5fd7d7
palette = 81=#5fd7ff
palette = 82=#5fff00
palette = 83=#5fff5f
palette = 84=#5fff87
palette = 85=#5fffaf
palette = 86=#5fffd7
palette = 87=#5fffff
palette = 88=#870000
palette = 89=#87005f
palette = 90=#870087
palette = 91=#8700af
palette = 92=#8700d7
palette = 93=#8700ff
palette = 94=#875f00
palette = 95=#875f5f
palette = 96=#875f87
palette = 97=#875faf
palette = 98=#875fd7
palette = 99=#875fff
palette = 100=#878700
palette = 101=#87875f
palette = 102=#878787
palette = 103=#8787af
palette = 104=#8787d7
palette = 105=#8787ff
palette = 106=#87af00
palette = 107=#87af5f
palette = 108=#87af87
palette = 109=#87afaf
palette = 110=#87afd7
palette = 111=#87afff
palette = 112=#87d700
palette = 113=#87d75f
palette = 114=#87d787
palette = 115=#87d7af
palette = 116=#87d7d7
palette = 117=#87d7ff
palette = 118=#87ff00
palette = 119=#87ff5f
palette = 120=#87ff87
palette = 121=#87ffaf
palette = 122=#87ffd7
palette = 123=#87ffff
palette = 124=#af0000
palette = 125=#af005f
palette = 126=#af0087
palette = 127=#af00af
palette = 128=#af00d7
palette = 129=#af00ff
palette = 130=#af5f00
palette = 131=#af5f5f
palette = 132=#af5f87
palette = 133=#af5faf
palette = 134=#af5fd7
palette = 135=#af5fff
palette = 136=#af8700
palette = 137=#af875f
palette = 138=#af8787
palette = 139=#af87af
palette = 140=#af87d7
palette = 141=#af87ff
palette = 142=#afaf00
palette = 143=#afaf5f
palette = 144=#afaf87
palette = 145=#afafaf
palette = 146=#afafd7
palette = 147=#afafff
palette = 148=#afd700
palette = 149=#afd75f
palette = 150=#afd787
palette = 151=#afd7af
palette = 152=#afd7d7
palette = 153=#afd7ff
palette = 154=#afff00
palette = 155=#afff5f
palette = 156=#afff87
palette = 157=#afffaf
palette = 158=#afffd7
palette = 159=#afffff
palette = 160=#d70000
palette = 161=#d7005f
palette = 162=#d70087
palette = 163=#d700af
palette = 164=#d700d7
palette = 165=#d700ff
palette = 166=#d75f00
palette = 167=#d75f5f
palette = 168=#d75f87
palette = 169=#d75faf
palette = 170=#d75fd7
palette = 171=#d75fff
palette = 172=#d78700
palette = 173=#d7875f
palette = 174=#d78787
palette = 175=#d787af
palette = 176=#d787d7
palette = 177=#d787ff
palette = 178=#d7af00
palette = 179=#d7af5f
palette = 180=#d7af87
palette = 181=#d7afaf
palette = 182=#d7afd7
palette = 183=#d7afff
palette = 184=#d7d700
palette = 185=#d7d75f
palette = 186=#d7d787
palette = 187=#d7d7af
palette = 188=#d7d7d7
palette = 189=#d7d7ff
palette = 190=#d7ff00
palette = 191=#d7ff5f
palette = 192=#d7ff87
palette = 193=#d7ffaf
palette = 194=#d7ffd7
palette = 195=#d7ffff
palette = 196=#ff0000
palette = 197=#ff005f
palette = 198=#ff0087
palette = 199=#ff00af
palette = 200=#ff00d7
palette = 201=#ff00ff
palette = 202=#ff5f00
palette = 203=#ff5f5f
palette = 204=#ff5f87
palette = 205=#ff5faf
palette = 206=#ff5fd7
palette = 207=#ff5fff
palette = 208=#ff8700
palette = 209=#ff875f
palette = 210=#ff8787
palette = 211=#ff87af
palette = 212=#ff87d7
palette = 213=#ff87ff
palette = 214=#ffaf00
palette = 215=#ffaf5f
palette = 216=#ffaf87
palette = 217=#ffafaf
palette = 218=#ffafd7
palette = 219=#ffafff
palette = 220=#ffd700
palette = 221=#ffd75f
palette = 222=#ffd787
palette = 223=#ffd7af
palette = 224=#ffd7d7
palette = 225=#ffd7ff
palette = 226=#ffff00
palette = 227=#ffff5f
palette = 228=#ffff87
palette = 229=#ffffaf
palette = 230=#ffffd7
palette = 231=#ffffff
palette = 232=#080808
palette = 233=#121212
palette = 234=#1c1c1c
palette = 235=#262626
palette = 236=#303030
palette = 237=#3a3a3a
palette = 238=#444444
palette = 239=#4e4e4e
palette = 240=#585858
palette = 241=#626262
palette = 242=#6c6c6c
palette = 243=#767676
palette = 244=#808080
palette = 245=#8a8a8a
palette = 246=#949494
palette = 247=#9e9e9e
palette = 248=#a8a8a8
palette = 249=#b2b2b2
palette = 250=#bcbcbc
palette = 251=#c6c6c6
palette = 252=#d0d0d0
palette = 253=#dadada
palette = 254=#e4e4e4
palette = 255=#eeeeee

# The color of the cursor. If this is not set, a default will be chosen.
# Specified as either hex (`#RRGGBB` or `RRGGBB`) or a named X11 color.
cursor-color = 

# Swap the foreground and background colors of the cell under the cursor. This
# option overrides the `cursor-color` and `cursor-text` options.
cursor-invert-fg-bg = false

# The opacity level (opposite of transparency) of the cursor. A value of 1
# is fully opaque and a value of 0 is fully transparent. A value less than 0
# or greater than 1 will be clamped to the nearest valid value. Note that a
# sufficiently small value such as 0.3 may be effectively invisible and may
# make it difficult to find the cursor.
cursor-opacity = 1

# The style of the cursor. This sets the default style. A running program can
# still request an explicit cursor style using escape sequences (such as `CSI
# q`). Shell configurations will often request specific cursor styles.
# 
# Note that shell integration will automatically set the cursor to a bar at
# a prompt, regardless of this configuration. You can disable that behavior
# by specifying `shell-integration-features = no-cursor` or disabling shell
# integration entirely.
# 
# Valid values are:
# 
#   * `block`
#   * `bar`
#   * `underline`
#   * `block_hollow`
# 
cursor-style = block

# Sets the default blinking state of the cursor. This is just the default
# state; running programs may override the cursor style using `DECSCUSR` (`CSI
# q`).
# 
# If this is not set, the cursor blinks by default. Note that this is not the
# same as a "true" value, as noted below.
# 
# If this is not set at all (`null`), then Ghostty will respect DEC Mode 12
# (AT&T cursor blink) as an alternate approach to turning blinking on/off. If
# this is set to any value other than null, DEC mode 12 will be ignored but
# `DECSCUSR` will still be respected.
# 
# Valid values are:
# 
#   * ` ` (blank)
#   * `true`
#   * `false`
# 
cursor-style-blink = 

# The color of the text under the cursor. If this is not set, a default will
# be chosen.
# Specified as either hex (`#RRGGBB` or `RRGGBB`) or a named X11 color.
cursor-text = 

# Enables the ability to move the cursor at prompts by using `alt+click` on
# Linux and `option+click` on macOS.
# 
# This feature requires shell integration (specifically prompt marking
# via `OSC 133`) and only works in primary screen mode. Alternate screen
# applications like vim usually have their own version of this feature but
# this configuration doesn't control that.
# 
# It should be noted that this feature works by translating your desired
# position into a series of synthetic arrow key movements, so some weird
# behavior around edge cases are to be expected. This is unfortunately how
# this feature is implemented across terminals because there isn't any other
# way to implement it.
cursor-click-to-move = true

# Hide the mouse immediately when typing. The mouse becomes visible again
# when the mouse is used (button, movement, etc.). Platform-specific behavior
# may dictate other scenarios where the mouse is shown. For example on macOS,
# the mouse is shown again when a new window, tab, or split is created.
mouse-hide-while-typing = false

# Determines whether running programs can detect the shift key pressed with a
# mouse click. Typically, the shift key is used to extend mouse selection.
# 
# The default value of `false` means that the shift key is not sent with
# the mouse protocol and will extend the selection. This value can be
# conditionally overridden by the running program with the `XTSHIFTESCAPE`
# sequence.
# 
# The value `true` means that the shift key is sent with the mouse protocol
# but the running program can override this behavior with `XTSHIFTESCAPE`.
# 
# The value `never` is the same as `false` but the running program cannot
# override this behavior with `XTSHIFTESCAPE`. The value `always` is the
# same as `true` but the running program cannot override this behavior with
# `XTSHIFTESCAPE`.
# 
# If you always want shift to extend mouse selection even if the program
# requests otherwise, set this to `never`.
# 
# Valid values are:
# 
#   * `true`
#   * `false`
#   * `always`
#   * `never`
# 
mouse-shift-capture = false

# Multiplier for scrolling distance with the mouse wheel. Any value less
# than 0.01 or greater than 10,000 will be clamped to the nearest valid
# value.
# 
# A value of "1" (default) scrolls the default amount. A value of "2" scrolls
# double the default amount. A value of "0.5" scrolls half the default amount.
# Et cetera.
mouse-scroll-multiplier = 1

# The opacity level (opposite of transparency) of the background. A value of
# 1 is fully opaque and a value of 0 is fully transparent. A value less than 0
# or greater than 1 will be clamped to the nearest valid value.
# 
# On macOS, background opacity is disabled when the terminal enters native
# fullscreen. This is because the background becomes gray and it can cause
# widgets to show through which isn't generally desirable.
# 
# On macOS, changing this configuration requires restarting Ghostty completely.
background-opacity = 1

# Whether to blur the background when `background-opacity` is less than 1.
# 
# Valid values are:
# 
#   * a nonnegative integer specifying the *blur intensity*
#   * `false`, equivalent to a blur intensity of 0
#   * `true`, equivalent to the default blur intensity of 20, which is
#     reasonable for a good looking blur. Higher blur intensities may
#     cause strange rendering and performance issues.
# 
# Supported on macOS and on some Linux desktop environments, including:
# 
#   * KDE Plasma (Wayland and X11)
# 
# Warning: the exact blur intensity is _ignored_ under KDE Plasma, and setting
# this setting to either `true` or any positive blur intensity value would
# achieve the same effect. The reason is that KWin, the window compositor
# powering Plasma, only has one global blur setting and does not allow
# applications to specify individual blur settings.
# 
# To configure KWin's global blur setting, open System Settings and go to
# "Apps & Windows" > "Window Management" > "Desktop Effects" and select the
# "Blur" plugin. If disabled, enable it by ticking the checkbox to the left.
# Then click on the "Configure" button and there will be two sliders that
# allow you to set background blur and noise intensities for all apps,
# including Ghostty.
# 
# All other Linux desktop environments are as of now unsupported. Users may
# need to set environment-specific settings and/or install third-party plugins
# in order to support background blur, as there isn't a unified interface for
# doing so.
background-blur = false

# The opacity level (opposite of transparency) of an unfocused split.
# Unfocused splits by default are slightly faded out to make it easier to see
# which split is focused. To disable this feature, set this value to 1.
# 
# A value of 1 is fully opaque and a value of 0 is fully transparent. Because
# "0" is not useful (it makes the window look very weird), the minimum value
# is 0.15. This value still looks weird but you can at least see what's going
# on. A value outside of the range 0.15 to 1 will be clamped to the nearest
# valid value.
unfocused-split-opacity = 0.7

# The color to dim the unfocused split. Unfocused splits are dimmed by
# rendering a semi-transparent rectangle over the split. This sets the color of
# that rectangle and can be used to carefully control the dimming effect.
# 
# This will default to the background color.
# 
# Specified as either hex (`#RRGGBB` or `RRGGBB`) or a named X11 color.
unfocused-split-fill = 

# The color of the split divider. If this is not set, a default will be chosen.
# Specified as either hex (`#RRGGBB` or `RRGGBB`) or a named X11 color.
split-divider-color = 

# The command to run, usually a shell. If this is not an absolute path, it'll
# be looked up in the `PATH`. If this is not set, a default will be looked up
# from your system. The rules for the default lookup are:
# 
#   * `SHELL` environment variable
# 
#   * `passwd` entry (user information)
# 
# This can contain additional arguments to run the command with. If additional
# arguments are provided, the command will be executed using `/bin/sh -c`.
# Ghostty does not do any shell command parsing.
# 
# This command will be used for all new terminal surfaces, i.e. new windows,
# tabs, etc. If you want to run a command only for the first terminal surface
# created when Ghostty starts, use the `initial-command` configuration.
# 
# Ghostty supports the common `-e` flag for executing a command with
# arguments. For example, `ghostty -e fish --with --custom --args`.
# This flag sets the `initial-command` configuration, see that for more
# information.
command = 

# This is the same as "command", but only applies to the first terminal
# surface created when Ghostty starts. Subsequent terminal surfaces will use
# the `command` configuration.
# 
# After the first terminal surface is created (or closed), there is no
# way to run this initial command again automatically. As such, setting
# this at runtime works but will only affect the next terminal surface
# if it is the first one ever created.
# 
# If you're using the `ghostty` CLI there is also a shortcut to set this
# with arguments directly: you can use the `-e` flag. For example: `ghostty -e
# fish --with --custom --args`. The `-e` flag automatically forces some
# other behaviors as well:
# 
#   * `gtk-single-instance=false` - This ensures that a new instance is
#     launched and the CLI args are respected.
# 
#   * `quit-after-last-window-closed=true` - This ensures that the Ghostty
#     process will exit when the command exits. Additionally, the
#     `quit-after-last-window-closed-delay` is unset.
# 
#   * `shell-integration=detect` (if not `none`) - This prevents forcibly
#     injecting any configured shell integration into the command's
#     environment. With `-e` its highly unlikely that you're executing a
#     shell and forced shell integration is likely to cause problems
#     (e.g. by wrapping your command in a shell, setting env vars, etc.).
#     This is a safety measure to prevent unexpected behavior. If you want
#     shell integration with a `-e`-executed command, you must either
#     name your binary appropriately or source the shell integration script
#     manually.
# 
initial-command = 

# If true, keep the terminal open after the command exits. Normally, the
# terminal window closes when the running command (such as a shell) exits.
# With this true, the terminal window will stay open until any keypress is
# received.
# 
# This is primarily useful for scripts or debugging.
wait-after-command = false

# The number of milliseconds of runtime below which we consider a process exit
# to be abnormal. This is used to show an error message when the process exits
# too quickly.
# 
# On Linux, this must be paired with a non-zero exit code. On macOS, we allow
# any exit code because of the way shell processes are launched via the login
# command.
abnormal-command-exit-runtime = 250

# The size of the scrollback buffer in bytes. This also includes the active
# screen. No matter what this is set to, enough memory will always be
# allocated for the visible screen and anything leftover is the limit for
# the scrollback.
# 
# When this limit is reached, the oldest lines are removed from the
# scrollback.
# 
# Scrollback currently exists completely in memory. This means that the
# larger this value, the larger potential memory usage. Scrollback is
# allocated lazily up to this limit, so if you set this to a very large
# value, it will not immediately consume a lot of memory.
# 
# This size is per terminal surface, not for the entire application.
# 
# It is not currently possible to set an unlimited scrollback buffer.
# This is a future planned feature.
# 
# This can be changed at runtime but will only affect new terminal surfaces.
scrollback-limit = 10000000

# Match a regular expression against the terminal text and associate clicking
# it with an action. This can be used to match URLs, file paths, etc. Actions
# can be opening using the system opener (e.g. `open` or `xdg-open`) or
# executing any arbitrary binding action.
# 
# Links that are configured earlier take precedence over links that are
# configured later.
# 
# A default link that matches a URL and opens it in the system opener always
# exists. This can be disabled using `link-url`.
# 
# TODO: This can't currently be set!

# Enable URL matching. URLs are matched on hover with control (Linux) or
# super (macOS) pressed and open using the default system application for
# the linked URL.
# 
# The URL matcher is always lowest priority of any configured links (see
# `link`). If you want to customize URL matching, use `link` and disable this.
link-url = true

# Whether to start the window in a maximized state. This setting applies
# to new windows and does not apply to tabs, splits, etc. However, this setting
# will apply to all new windows, not just the first one.
maximize = false

# Start new windows in fullscreen. This setting applies to new windows and
# does not apply to tabs, splits, etc. However, this setting will apply to all
# new windows, not just the first one.
# 
# On macOS, this setting does not work if window-decoration is set to
# "false", because native fullscreen on macOS requires window decorations
# to be set.
fullscreen = false

# The title Ghostty will use for the window. This will force the title of the
# window to be this title at all times and Ghostty will ignore any set title
# escape sequences programs (such as Neovim) may send.
# 
# If you want a blank title, set this to one or more spaces by quoting
# the value. For example, `title = " "`. This effectively hides the title.
# This is necessary because setting a blank value resets the title to the
# default value of the running program.
# 
# This configuration can be reloaded at runtime. If it is set, the title
# will update for all windows. If it is unset, the next title change escape
# sequence will be honored but previous changes will not retroactively
# be set. This latter case may require you to restart programs such as Neovim
# to get the new title.
title = 

# The setting that will change the application class value.
# 
# This controls the class field of the `WM_CLASS` X11 property (when running
# under X11), and the Wayland application ID (when running under Wayland).
# 
# Note that changing this value between invocations will create new, separate
# instances, of Ghostty when running with `gtk-single-instance=true`. See that
# option for more details.
# 
# The class name must follow the requirements defined [in the GTK
# documentation](https://docs.gtk.org/gio/type_func.Application.id_is_valid.html).
# 
# The default is `com.mitchellh.ghostty`.
# 
# This only affects GTK builds.
class = 

# This controls the instance name field of the `WM_CLASS` X11 property when
# running under X11. It has no effect otherwise.
# 
# The default is `ghostty`.
# 
# This only affects GTK builds.
x11-instance-name = 

# The directory to change to after starting the command.
# 
# This setting is secondary to the `window-inherit-working-directory`
# setting. If a previous Ghostty terminal exists in the same process,
# `window-inherit-working-directory` will take precedence. Otherwise, this
# setting will be used. Typically, this setting is used only for the first
# window.
# 
# The default is `inherit` except in special scenarios listed next. On macOS,
# if Ghostty can detect it is launched from launchd (double-clicked) or
# `open`, then it defaults to `home`. On Linux with GTK, if Ghostty can detect
# it was launched from a desktop launcher, then it defaults to `home`.
# 
# The value of this must be an absolute value or one of the special values
# below:
# 
#   * `home` - The home directory of the executing user.
# 
#   * `inherit` - The working directory of the launching process.
working-directory = 

# Key bindings. The format is `trigger=action`. Duplicate triggers will
# overwrite previously set values. The list of actions is available in
# the documentation or using the `ghostty +list-actions` command.
# 
# Trigger: `+`-separated list of keys and modifiers. Example: `ctrl+a`,
# `ctrl+shift+b`, `up`.
# 
# Valid keys are currently only listed in the
# [Ghostty source code](https://github.com/ghostty-org/ghostty/blob/d6e76858164d52cff460fedc61ddf2e560912d71/src/input/key.zig#L255).
# This is a documentation limitation and we will improve this in the future.
# A common gotcha is that numeric keys are written as words: e.g. `one`,
# `two`, `three`, etc. and not `1`, `2`, `3`. This will also be improved in
# the future.
# 
# Valid modifiers are `shift`, `ctrl` (alias: `control`), `alt` (alias: `opt`,
# `option`), and `super` (alias: `cmd`, `command`). You may use the modifier
# or the alias. When debugging keybinds, the non-aliased modifier will always
# be used in output.
# 
# Note: The fn or "globe" key on keyboards are not supported as a
# modifier. This is a limitation of the operating systems and GUI toolkits
# that Ghostty uses.
# 
# Some additional notes for triggers:
# 
#   * modifiers cannot repeat, `ctrl+ctrl+a` is invalid.
# 
#   * modifiers and keys can be in any order, `shift+a+ctrl` is *weird*,
#     but valid.
# 
#   * only a single key input is allowed, `ctrl+a+b` is invalid.
# 
#   * the key input can be prefixed with `physical:` to specify a
#     physical key mapping rather than a logical one. A physical key
#     mapping responds to the hardware keycode and not the keycode
#     translated by any system keyboard layouts. Example: "ctrl+physical:a"
# 
# You may also specify multiple triggers separated by `>` to require a
# sequence of triggers to activate the action. For example,
# `ctrl+a>n=new_window` will only trigger the `new_window` action if the
# user presses `ctrl+a` followed separately by `n`. In other software, this
# is sometimes called a leader key, a key chord, a key table, etc. There
# is no hardcoded limit on the number of parts in a sequence.
# 
# Warning: If you define a sequence as a CLI argument to `ghostty`,
# you probably have to quote the keybind since `>` is a special character
# in most shells. Example: ghostty --keybind='ctrl+a>n=new_window'
# 
# A trigger sequence has some special handling:
# 
#   * Ghostty will wait an indefinite amount of time for the next key in
#     the sequence. There is no way to specify a timeout. The only way to
#     force the output of a prefix key is to assign another keybind to
#     specifically output that key (e.g. `ctrl+a>ctrl+a=text:foo`) or
#     press an unbound key which will send both keys to the program.
# 
#   * If a prefix in a sequence is previously bound, the sequence will
#     override the previous binding. For example, if `ctrl+a` is bound to
#     `new_window` and `ctrl+a>n` is bound to `new_tab`, pressing `ctrl+a`
#     will do nothing.
# 
#   * Adding to the above, if a previously bound sequence prefix is
#     used in a new, non-sequence binding, the entire previously bound
#     sequence will be unbound. For example, if you bind `ctrl+a>n` and
#     `ctrl+a>t`, and then bind `ctrl+a` directly, both `ctrl+a>n` and
#     `ctrl+a>t` will become unbound.
# 
#   * Trigger sequences are not allowed for `global:` or `all:`-prefixed
#     triggers. This is a limitation we could remove in the future.
# 
# Action is the action to take when the trigger is satisfied. It takes the
# format `action` or `action:param`. The latter form is only valid if the
# action requires a parameter.
# 
#   * `ignore` - Do nothing, ignore the key input. This can be used to
#     black hole certain inputs to have no effect.
# 
#   * `unbind` - Remove the binding. This makes it so the previous action
#     is removed, and the key will be sent through to the child command
#     if it is printable. Unbind will remove any matching trigger,
#     including `physical:`-prefixed triggers without specifying the
#     prefix.
# 
#   * `csi:text` - Send a CSI sequence. e.g. `csi:A` sends "cursor up".
# 
#   * `esc:text` - Send an escape sequence. e.g. `esc:d` deletes to the
#     end of the word to the right.
# 
#   * `text:text` - Send a string. Uses Zig string literal syntax.
#     e.g. `text:\x15` sends Ctrl-U.
# 
#   * All other actions can be found in the documentation or by using the
#     `ghostty +list-actions` command.
# 
# Some notes for the action:
# 
#   * The parameter is taken as-is after the `:`. Double quotes or
#     other mechanisms are included and NOT parsed. If you want to
#     send a string value that includes spaces, wrap the entire
#     trigger/action in double quotes. Example: `--keybind="up=csi:A B"`
# 
# There are some additional special values that can be specified for
# keybind:
# 
#   * `keybind=clear` will clear all set keybindings. Warning: this
#     removes ALL keybindings up to this point, including the default
#     keybindings.
# 
# The keybind trigger can be prefixed with some special values to change
# the behavior of the keybind. These are:
# 
#   * `all:` - Make the keybind apply to all terminal surfaces. By default,
#     keybinds only apply to the focused terminal surface. If this is true,
#     then the keybind will be sent to all terminal surfaces. This only
#     applies to actions that are surface-specific. For actions that
#     are already global (e.g. `quit`), this prefix has no effect.
# 
#   * `global:` - Make the keybind global. By default, keybinds only work
#     within Ghostty and under the right conditions (application focused,
#     sometimes terminal focused, etc.). If you want a keybind to work
#     globally across your system (e.g. even when Ghostty is not focused),
#     specify this prefix. This prefix implies `all:`. Note: this does not
#     work in all environments; see the additional notes below for more
#     information.
# 
#   * `unconsumed:` - Do not consume the input. By default, a keybind
#     will consume the input, meaning that the associated encoding (if
#     any) will not be sent to the running program in the terminal. If
#     you wish to send the encoded value to the program, specify the
#     `unconsumed:` prefix before the entire keybind. For example:
#     `unconsumed:ctrl+a=reload_config`. `global:` and `all:`-prefixed
#     keybinds will always consume the input regardless of this setting.
#     Since they are not associated with a specific terminal surface,
#     they're never encoded.
# 
#   * `performable:` - Only consume the input if the action is able to be
#     performed. For example, the `copy_to_clipboard` action will only
#     consume the input if there is a selection to copy. If there is no
#     selection, Ghostty behaves as if the keybind was not set. This has
#     no effect with `global:` or `all:`-prefixed keybinds. For key
#     sequences, this will reset the sequence if the action is not
#     performable (acting identically to not having a keybind set at
#     all).
# 
#     Performable keybinds will not appear as menu shortcuts in the
#     application menu. This is because the menu shortcuts force the
#     action to be performed regardless of the state of the terminal.
#     Performable keybinds will still work, they just won't appear as
#     a shortcut label in the menu.
# 
# Keybind triggers are not unique per prefix combination. For example,
# `ctrl+a` and `global:ctrl+a` are not two separate keybinds. The keybind
# set later will overwrite the keybind set earlier. In this case, the
# `global:` keybind will be used.
# 
# Multiple prefixes can be specified. For example,
# `global:unconsumed:ctrl+a=reload_config` will make the keybind global
# and not consume the input to reload the config.
# 
# Note: `global:` is only supported on macOS. On macOS,
# this feature requires accessibility permissions to be granted to Ghostty.
# When a `global:` keybind is specified and Ghostty is launched or reloaded,
# Ghostty will attempt to request these permissions. If the permissions are
# not granted, the keybind will not work. On macOS, you can find these
# permissions in System Preferences -> Privacy & Security -> Accessibility.
keybind = super+page_up=scroll_page_up
keybind = super+ctrl+equal=equalize_splits
keybind = super+physical:four=goto_tab:4
keybind = super+shift+down=jump_to_prompt:1
keybind = super+shift+w=close_window
keybind = super+shift+left_bracket=previous_tab
keybind = super+backspace=text:\x15
keybind = super+alt+w=close_tab
keybind = super+w=close_surface
keybind = super+alt+i=inspector:toggle
keybind = super+physical:eight=goto_tab:8
keybind = super+alt+right=goto_split:right
keybind = shift+up=adjust_selection:up
keybind = super+down=jump_to_prompt:1
keybind = super+enter=toggle_fullscreen
keybind = super+t=new_tab
keybind = super+c=copy_to_clipboard
keybind = super+shift+right_bracket=next_tab
keybind = super+physical:one=goto_tab:1
keybind = shift+left=adjust_selection:left
keybind = super+equal=increase_font_size:1
keybind = shift+page_up=adjust_selection:page_up
keybind = super+physical:three=goto_tab:3
keybind = super+right=text:\x05
keybind = super+d=new_split:right
keybind = super+ctrl+down=resize_split:down,10
keybind = shift+end=adjust_selection:end
keybind = super+plus=increase_font_size:1
keybind = super+q=quit
keybind = super+home=scroll_to_top
keybind = super+ctrl+left=resize_split:left,10
keybind = alt+left=esc:b
keybind = super+ctrl+up=resize_split:up,10
keybind = super+left=text:\x01
keybind = super+shift+up=jump_to_prompt:-1
keybind = shift+right=adjust_selection:right
keybind = super+comma=open_config
keybind = super+shift+comma=reload_config
keybind = super+minus=decrease_font_size:1
keybind = shift+page_down=adjust_selection:page_down
keybind = ctrl+tab=next_tab
keybind = super+a=select_all
keybind = alt+right=esc:f
keybind = super+shift+enter=toggle_split_zoom
keybind = super+alt+down=goto_split:down
keybind = super+ctrl+f=toggle_fullscreen
keybind = super+ctrl+right=resize_split:right,10
keybind = super+alt+shift+j=write_screen_file:open
keybind = shift+down=adjust_selection:down
keybind = ctrl+shift+tab=previous_tab
keybind = super+n=new_window
keybind = super+alt+left=goto_split:left
keybind = super+page_down=scroll_page_down
keybind = super+alt+shift+w=close_all_windows
keybind = super+alt+up=goto_split:up
keybind = super+shift+v=paste_from_selection
keybind = super+left_bracket=goto_split:previous
keybind = super+physical:nine=last_tab
keybind = super+right_bracket=goto_split:next
keybind = super+end=scroll_to_bottom
keybind = super+shift+j=write_screen_file:paste
keybind = super+shift+d=new_split:down
keybind = super+zero=reset_font_size
keybind = super+physical:five=goto_tab:5
keybind = shift+home=adjust_selection:home
keybind = super+physical:seven=goto_tab:7
keybind = super+up=jump_to_prompt:-1
keybind = super+k=clear_screen
keybind = super+physical:two=goto_tab:2
keybind = super+physical:six=goto_tab:6
keybind = super+v=paste_from_clipboard

# Horizontal window padding. This applies padding between the terminal cells
# and the left and right window borders. The value is in points, meaning that
# it will be scaled appropriately for screen DPI.
# 
# If this value is set too large, the screen will render nothing, because the
# grid will be completely squished by the padding. It is up to you as the user
# to pick a reasonable value. If you pick an unreasonable value, a warning
# will appear in the logs.
# 
# Changing this configuration at runtime will only affect new terminals, i.e.
# new windows, tabs, etc.
# 
# To set a different left and right padding, specify two numerical values
# separated by a comma. For example, `window-padding-x = 2,4` will set the
# left padding to 2 and the right padding to 4. If you want to set both
# paddings to the same value, you can use a single value. For example,
# `window-padding-x = 2` will set both paddings to 2.
window-padding-x = 2

# Vertical window padding. This applies padding between the terminal cells and
# the top and bottom window borders. The value is in points, meaning that it
# will be scaled appropriately for screen DPI.
# 
# If this value is set too large, the screen will render nothing, because the
# grid will be completely squished by the padding. It is up to you as the user
# to pick a reasonable value. If you pick an unreasonable value, a warning
# will appear in the logs.
# 
# Changing this configuration at runtime will only affect new terminals,
# i.e. new windows, tabs, etc.
# 
# To set a different top and bottom padding, specify two numerical values
# separated by a comma. For example, `window-padding-y = 2,4` will set the
# top padding to 2 and the bottom padding to 4. If you want to set both
# paddings to the same value, you can use a single value. For example,
# `window-padding-y = 2` will set both paddings to 2.
window-padding-y = 2

# The viewport dimensions are usually not perfectly divisible by the cell
# size. In this case, some extra padding on the end of a column and the bottom
# of the final row may exist. If this is `true`, then this extra padding
# is automatically balanced between all four edges to minimize imbalance on
# one side. If this is `false`, the top left grid cell will always hug the
# edge with zero padding other than what may be specified with the other
# `window-padding` options.
# 
# If other `window-padding` fields are set and this is `true`, this will still
# apply. The other padding is applied first and may affect how many grid cells
# actually exist, and this is applied last in order to balance the padding
# given a certain viewport size and grid cell size.
window-padding-balance = false

# The color of the padding area of the window. Valid values are:
# 
# * `background` - The background color specified in `background`.
# * `extend` - Extend the background color of the nearest grid cell.
# * `extend-always` - Same as "extend" but always extends without applying
#   any of the heuristics that disable extending noted below.
# 
# The "extend" value will be disabled in certain scenarios. On primary
# screen applications (e.g. not something like Neovim), the color will not
# be extended vertically if any of the following are true:
# 
# * The nearest row has any cells that have the default background color.
#   The thinking is that in this case, the default background color looks
#   fine as a padding color.
# * The nearest row is a prompt row (requires shell integration). The
#   thinking here is that prompts often contain powerline glyphs that
#   do not look good extended.
# * The nearest row contains a perfect fit powerline character. These
#   don't look good extended.
# 
window-padding-color = background

# Synchronize rendering with the screen refresh rate. If true, this will
# minimize tearing and align redraws with the screen but may cause input
# latency. If false, this will maximize redraw frequency but may cause tearing,
# and under heavy load may use more CPU and power.
# 
# This defaults to true because out-of-sync rendering on macOS can
# cause kernel panics (macOS 14.4+) and performance issues for external
# displays over some hardware such as DisplayLink. If you want to minimize
# input latency, set this to false with the known aforementioned risks.
# 
# Changing this value at runtime will only affect new terminals.
# 
# This setting is only supported currently on macOS.
window-vsync = true

# If true, new windows and tabs will inherit the working directory of the
# previously focused window. If no window was previously focused, the default
# working directory will be used (the `working-directory` option).
window-inherit-working-directory = true

# If true, new windows and tabs will inherit the font size of the previously
# focused window. If no window was previously focused, the default font size
# will be used. If this is false, the default font size specified in the
# configuration `font-size` will be used.
window-inherit-font-size = true

# Configure a preference for window decorations. This setting specifies
# a _preference_; the actual OS, desktop environment, window manager, etc.
# may override this preference. Ghostty will do its best to respect this
# preference but it may not always be possible.
# 
# Valid values:
# 
#   * `none` - All window decorations will be disabled. Titlebar,
#     borders, etc. will not be shown. On macOS, this will also disable
#     tabs (enforced by the system).
# 
#   * `auto` - Automatically decide to use either client-side or server-side
#     decorations based on the detected preferences of the current OS and
#     desktop environment. This option usually makes Ghostty look the most
#     "native" for your desktop.
# 
#   * `client` - Prefer client-side decorations.
# 
#   * `server` - Prefer server-side decorations. This is only relevant
#     on Linux with GTK, either on X11, or Wayland on a compositor that
#     supports the `org_kde_kwin_server_decoration` protocol (e.g. KDE Plasma,
#     but almost any non-GNOME desktop supports this protocol).
# 
#     If `server` is set but the environment doesn't support server-side
#     decorations, client-side decorations will be used instead.
# 
# The default value is `auto`.
# 
# For the sake of backwards compatibility and convenience, this setting also
# accepts boolean true and false values. If set to `true`, this is equivalent
# to `auto`. If set to `false`, this is equivalent to `none`.
# This is convenient for users who live primarily on systems that don't
# differentiate between client and server-side decorations (e.g. macOS and
# Windows).
# 
# The "toggle_window_decorations" keybind action can be used to create
# a keybinding to toggle this setting at runtime. This will always toggle
# back to "auto" if the current value is "none" (this is an issue
# that will be fixed in the future).
# 
# Changing this configuration in your configuration and reloading will
# only affect new windows. Existing windows will not be affected.
# 
# macOS: To hide the titlebar without removing the native window borders
#        or rounded corners, use `macos-titlebar-style = hidden` instead.
window-decoration = auto

# The font that will be used for the application's window and tab titles.
# 
# If this setting is left unset, the system default font will be used.
# 
# Note: any font available on the system may be used, this font is not
# required to be a fixed-width font.
window-title-font-family = 

# The text that will be displayed in the subtitle of the window. Valid values:
# 
#   * `false` - Disable the subtitle.
#   * `working-directory` - Set the subtitle to the working directory of the
#      surface.
# 
# This feature is only supported on GTK with Adwaita enabled.
window-subtitle = false

# The theme to use for the windows. Valid values:
# 
#   * `auto` - Determine the theme based on the configured terminal
#      background color. This has no effect if the "theme" configuration
#      has separate light and dark themes. In that case, the behavior
#      of "auto" is equivalent to "system".
#   * `system` - Use the system theme.
#   * `light` - Use the light theme regardless of system theme.
#   * `dark` - Use the dark theme regardless of system theme.
#   * `ghostty` - Use the background and foreground colors specified in the
#     Ghostty configuration. This is only supported on Linux builds with
#     Adwaita and `gtk-adwaita` enabled.
# 
# On macOS, if `macos-titlebar-style` is "tabs", the window theme will be
# automatically set based on the luminosity of the terminal background color.
# This only applies to terminal windows. This setting will still apply to
# non-terminal windows within Ghostty.
# 
# This is currently only supported on macOS and Linux.
window-theme = auto

# The color space to use when interpreting terminal colors. "Terminal colors"
# refers to colors specified in your configuration and colors produced by
# direct-color SGR sequences.
# 
# Valid values:
# 
#   * `srgb` - Interpret colors in the sRGB color space. This is the default.
#   * `display-p3` - Interpret colors in the Display P3 color space.
# 
# This setting is currently only supported on macOS.
window-colorspace = srgb

# The initial window size. This size is in terminal grid cells by default.
# Both values must be set to take effect. If only one value is set, it is
# ignored.
# 
# We don't currently support specifying a size in pixels but a future change
# can enable that. If this isn't specified, the app runtime will determine
# some default size.
# 
# Note that the window manager may put limits on the size or override the
# size. For example, a tiling window manager may force the window to be a
# certain size to fit within the grid. There is nothing Ghostty will do about
# this, but it will make an effort.
# 
# Sizes larger than the screen size will be clamped to the screen size.
# This can be used to create a maximized-by-default window size.
# 
# This will not affect new tabs, splits, or other nested terminal elements.
# This only affects the initial window size of any new window. Changing this
# value will not affect the size of the window after it has been created. This
# is only used for the initial size.
# 
# BUG: On Linux with GTK, the calculated window size will not properly take
# into account window decorations. As a result, the grid dimensions will not
# exactly match this configuration. If window decorations are disabled (see
# `window-decoration`), then this will work as expected.
# 
# Windows smaller than 10 wide by 4 high are not allowed.
window-height = 0

window-width = 0
# The starting window position. This position is in pixels and is relative
# to the top-left corner of the primary monitor. Both values must be set to take
# effect. If only one value is set, it is ignored.
# 
# Note that the window manager may put limits on the position or override
# the position. For example, a tiling window manager may force the window
# to be a certain position to fit within the grid. There is nothing Ghostty
# will do about this, but it will make an effort.
# 
# Also note that negative values are also up to the operating system and
# window manager. Some window managers may not allow windows to be placed
# off-screen.
# 
# Invalid positions are runtime-specific, but generally the positions are
# clamped to the nearest valid position.
# 
# On macOS, the window position is relative to the top-left corner of
# the visible screen area. This means that if the menu bar is visible, the
# window will be placed below the menu bar.
# 
# Note: this is only supported on macOS and Linux GLFW builds. The GTK
# runtime does not support setting the window position (this is a limitation
# of GTK 4.0).
window-position-x = 

window-position-y = 
# Whether to enable saving and restoring window state. Window state includes
# their position, size, tabs, splits, etc. Some window state requires shell
# integration, such as preserving working directories. See `shell-integration`
# for more information.
# 
# There are three valid values for this configuration:
# 
#   * `default` will use the default system behavior. On macOS, this
#     will only save state if the application is forcibly terminated
#     or if it is configured systemwide via Settings.app.
# 
#   * `never` will never save window state.
# 
#   * `always` will always save window state whenever Ghostty is exited.
# 
# If you change this value to `never` while Ghostty is not running, the next
# Ghostty launch will NOT restore the window state.
# 
# If you change this value to `default` while Ghostty is not running and the
# previous exit saved state, the next Ghostty launch will still restore the
# window state. This is because Ghostty cannot know if the previous exit was
# due to a forced save or not (macOS doesn't provide this information).
# 
# If you change this value so that window state is saved while Ghostty is not
# running, the previous window state will not be restored because Ghostty only
# saves state on exit if this is enabled.
# 
# The default value is `default`.
# 
# This is currently only supported on macOS. This has no effect on Linux.
window-save-state = default

# Resize the window in discrete increments of the focused surface's cell size.
# If this is disabled, surfaces are resized in pixel increments. Currently
# only supported on macOS.
window-step-resize = false

# The position where new tabs are created. Valid values:
# 
#   * `current` - Insert the new tab after the currently focused tab,
#     or at the end if there are no focused tabs.
# 
#   * `end` - Insert the new tab at the end of the tab list.
window-new-tab-position = current

# Background color for the window titlebar. This only takes effect if
# window-theme is set to ghostty. Currently only supported in the GTK app
# runtime.
# 
# Specified as either hex (`#RRGGBB` or `RRGGBB`) or a named X11 color.
window-titlebar-background = 

# Foreground color for the window titlebar. This only takes effect if
# window-theme is set to ghostty. Currently only supported in the GTK app
# runtime.
# 
# Specified as either hex (`#RRGGBB` or `RRGGBB`) or a named X11 color.
window-titlebar-foreground = 

# This controls when resize overlays are shown. Resize overlays are a
# transient popup that shows the size of the terminal while the surfaces are
# being resized. The possible options are:
# 
#   * `always` - Always show resize overlays.
#   * `never` - Never show resize overlays.
#   * `after-first` - The resize overlay will not appear when the surface
#                     is first created, but will show up if the surface is
#                     subsequently resized.
# 
# The default is `after-first`.
resize-overlay = after-first

# If resize overlays are enabled, this controls the position of the overlay.
# The possible options are:
# 
#   * `center`
#   * `top-left`
#   * `top-center`
#   * `top-right`
#   * `bottom-left`
#   * `bottom-center`
#   * `bottom-right`
# 
# The default is `center`.
resize-overlay-position = center

# If resize overlays are enabled, this controls how long the overlay is
# visible on the screen before it is hidden. The default is ¾ of a second or
# 750 ms.
# 
# The duration is specified as a series of numbers followed by time units.
# Whitespace is allowed between numbers and units. Each number and unit will
# be added together to form the total duration.
# 
# The allowed time units are as follows:
# 
#   * `y` - 365 SI days, or 8760 hours, or 31536000 seconds. No adjustments
#     are made for leap years or leap seconds.
#   * `d` - one SI day, or 86400 seconds.
#   * `h` - one hour, or 3600 seconds.
#   * `m` - one minute, or 60 seconds.
#   * `s` - one second.
#   * `ms` - one millisecond, or 0.001 second.
#   * `us` or `µs` - one microsecond, or 0.000001 second.
#   * `ns` - one nanosecond, or 0.000000001 second.
# 
# Examples:
#   * `1h30m`
#   * `45s`
# 
# Units can be repeated and will be added together. This means that
# `1h1h` is equivalent to `2h`. This is confusing and should be avoided.
# A future update may disallow this.
# 
# The maximum value is `584y 49w 23h 34m 33s 709ms 551µs 615ns`. Any
# value larger than this will be clamped to the maximum value.
resize-overlay-duration = 750ms

# If true, when there are multiple split panes, the mouse selects the pane
# that is focused. This only applies to the currently focused window; e.g.
# mousing over a split in an unfocused window will not focus that split
# and bring the window to front.
# 
# Default is false.
focus-follows-mouse = false

# Whether to allow programs running in the terminal to read/write to the
# system clipboard (OSC 52, for googling). The default is to allow clipboard
# reading after prompting the user and allow writing unconditionally.
# 
# Valid values are:
# 
#   * `ask`
#   * `allow`
#   * `deny`
# 
clipboard-read = ask

clipboard-write = allow
# Trims trailing whitespace on data that is copied to the clipboard. This does
# not affect data sent to the clipboard via `clipboard-write`.
clipboard-trim-trailing-spaces = true

# Require confirmation before pasting text that appears unsafe. This helps
# prevent a "copy/paste attack" where a user may accidentally execute unsafe
# commands by pasting text with newlines.
clipboard-paste-protection = true

# If true, bracketed pastes will be considered safe. By default, bracketed
# pastes are considered safe. "Bracketed" pastes are pastes while the running
# program has bracketed paste mode enabled (a setting set by the running
# program, not the terminal emulator).
clipboard-paste-bracketed-safe = true

# Enables or disabled title reporting (CSI 21 t). This escape sequence
# allows the running program to query the terminal title. This is a common
# security issue and is disabled by default.
# 
# Warning: This can expose sensitive information at best and enable
# arbitrary code execution at worst (with a maliciously crafted title
# and a minor amount of user interaction).
title-report = false

# The total amount of bytes that can be used for image data (e.g. the Kitty
# image protocol) per terminal screen. The maximum value is 4,294,967,295
# (4GiB). The default is 320MB. If this is set to zero, then all image
# protocols will be disabled.
# 
# This value is separate for primary and alternate screens so the effective
# limit per surface is double.
image-storage-limit = 320000000

# Whether to automatically copy selected text to the clipboard. `true`
# will prefer to copy to the selection clipboard, otherwise it will copy to
# the system clipboard.
# 
# The value `clipboard` will always copy text to the selection clipboard
# as well as the system clipboard.
# 
# Middle-click paste will always use the selection clipboard. Middle-click
# paste is always enabled even if this is `false`.
# 
# The default value is true on Linux and macOS.
copy-on-select = true

# The time in milliseconds between clicks to consider a click a repeat
# (double, triple, etc.) or an entirely new single click. A value of zero will
# use a platform-specific default. The default on macOS is determined by the
# OS settings. On every other platform it is 500ms.
click-repeat-interval = 0

# Additional configuration files to read. This configuration can be repeated
# to read multiple configuration files. Configuration files themselves can
# load more configuration files. Paths are relative to the file containing the
# `config-file` directive. For command-line arguments, paths are relative to
# the current working directory.
# 
# Prepend a ? character to the file path to suppress errors if the file does
# not exist. If you want to include a file that begins with a literal ?
# character, surround the file path in double quotes (").
# 
# Cycles are not allowed. If a cycle is detected, an error will be logged and
# the configuration file will be ignored.
# 
# Configuration files are loaded after the configuration they're defined
# within in the order they're defined. **THIS IS A VERY SUBTLE BUT IMPORTANT
# POINT.** To put it another way: configuration files do not take effect
# until after the entire configuration is loaded. For example, in the
# configuration below:
# 
# ```
# config-file = "foo"
# a = 1
# ```
# 
# If "foo" contains `a = 2`, the final value of `a` will be 2, because
# `foo` is loaded after the configuration file that configures the
# nested `config-file` value.
config-file = 

# When this is true, the default configuration file paths will be loaded.
# The default configuration file paths are currently only the XDG
# config path ($XDG_CONFIG_HOME/ghostty/config).
# 
# If this is false, the default configuration paths will not be loaded.
# This is targeted directly at using Ghostty from the CLI in a way
# that minimizes external effects.
# 
# This is a CLI-only configuration. Setting this in a configuration file
# will have no effect. It is not an error, but it will not do anything.
# This configuration can only be set via CLI arguments.
config-default-files = true

# Confirms that a surface should be closed before closing it.
# 
# This defaults to `true`. If set to `false`, surfaces will close without
# any confirmation. This can also be set to `always`, which will always
# confirm closing a surface, even if shell integration says a process isn't
# running.
confirm-close-surface = true

# Whether or not to quit after the last surface is closed.
# 
# This defaults to `false` on macOS since that is standard behavior for
# a macOS application. On Linux, this defaults to `true` since that is
# generally expected behavior.
# 
# On Linux, if this is `true`, Ghostty can delay quitting fully until a
# configurable amount of time has passed after the last window is closed.
# See the documentation of `quit-after-last-window-closed-delay`.
quit-after-last-window-closed = false

# Controls how long Ghostty will stay running after the last open surface has
# been closed. This only has an effect if `quit-after-last-window-closed` is
# also set to `true`.
# 
# The minimum value for this configuration is `1s`. Any values lower than
# this will be clamped to `1s`.
# 
# The duration is specified as a series of numbers followed by time units.
# Whitespace is allowed between numbers and units. Each number and unit will
# be added together to form the total duration.
# 
# The allowed time units are as follows:
# 
#   * `y` - 365 SI days, or 8760 hours, or 31536000 seconds. No adjustments
#     are made for leap years or leap seconds.
#   * `d` - one SI day, or 86400 seconds.
#   * `h` - one hour, or 3600 seconds.
#   * `m` - one minute, or 60 seconds.
#   * `s` - one second.
#   * `ms` - one millisecond, or 0.001 second.
#   * `us` or `µs` - one microsecond, or 0.000001 second.
#   * `ns` - one nanosecond, or 0.000000001 second.
# 
# Examples:
#   * `1h30m`
#   * `45s`
# 
# Units can be repeated and will be added together. This means that
# `1h1h` is equivalent to `2h`. This is confusing and should be avoided.
# A future update may disallow this.
# 
# The maximum value is `584y 49w 23h 34m 33s 709ms 551µs 615ns`. Any
# value larger than this will be clamped to the maximum value.
# 
# By default `quit-after-last-window-closed-delay` is unset and
# Ghostty will quit immediately after the last window is closed if
# `quit-after-last-window-closed` is `true`.
# 
# Only implemented on Linux.
quit-after-last-window-closed-delay = 

# This controls whether an initial window is created when Ghostty
# is run. Note that if `quit-after-last-window-closed` is `true` and
# `quit-after-last-window-closed-delay` is set, setting `initial-window` to
# `false` will mean that Ghostty will quit after the configured delay if no
# window is ever created. Only implemented on Linux and macOS.
initial-window = true

# The position of the "quick" terminal window. To learn more about the
# quick terminal, see the documentation for the `toggle_quick_terminal`
# binding action.
# 
# Valid values are:
# 
#   * `top` - Terminal appears at the top of the screen.
#   * `bottom` - Terminal appears at the bottom of the screen.
#   * `left` - Terminal appears at the left of the screen.
#   * `right` - Terminal appears at the right of the screen.
#   * `center` - Terminal appears at the center of the screen.
# 
# Changing this configuration requires restarting Ghostty completely.
# 
# Note: There is no default keybind for toggling the quick terminal.
# To enable this feature, bind the `toggle_quick_terminal` action to a key.
quick-terminal-position = top

# The screen where the quick terminal should show up.
# 
# Valid values are:
# 
#  * `main` - The screen that the operating system recommends as the main
#    screen. On macOS, this is the screen that is currently receiving
#    keyboard input. This screen is defined by the operating system and
#    not chosen by Ghostty.
# 
#  * `mouse` - The screen that the mouse is currently hovered over.
# 
#  * `macos-menu-bar` - The screen that contains the macOS menu bar as
#    set in the display settings on macOS. This is a bit confusing because
#    every screen on macOS has a menu bar, but this is the screen that
#    contains the primary menu bar.
# 
# The default value is `main` because this is the recommended screen
# by the operating system.
quick-terminal-screen = main

# Duration (in seconds) of the quick terminal enter and exit animation.
# Set it to 0 to disable animation completely. This can be changed at
# runtime.
quick-terminal-animation-duration = 0.2

# Automatically hide the quick terminal when focus shifts to another window.
# Set it to false for the quick terminal to remain open even when it loses focus.
quick-terminal-autohide = true

# This configuration option determines the behavior of the quick terminal
# when switching between macOS spaces. macOS spaces are virtual desktops
# that can be manually created or are automatically created when an
# application is in full-screen mode.
# 
# Valid values are:
# 
#  * `move` - When switching to another space, the quick terminal will
#    also moved to the current space.
# 
#  * `remain` - The quick terminal will stay only in the space where it
#    was originally opened and will not follow when switching to another
#    space.
# 
# The default value is `move`.
quick-terminal-space-behavior = move

# Whether to enable shell integration auto-injection or not. Shell integration
# greatly enhances the terminal experience by enabling a number of features:
# 
#   * Working directory reporting so new tabs, splits inherit the
#     previous terminal's working directory.
# 
#   * Prompt marking that enables the "jump_to_prompt" keybinding.
# 
#   * If you're sitting at a prompt, closing a terminal will not ask
#     for confirmation.
# 
#   * Resizing the window with a complex prompt usually paints much
#     better.
# 
# Allowable values are:
# 
#   * `none` - Do not do any automatic injection. You can still manually
#     configure your shell to enable the integration.
# 
#   * `detect` - Detect the shell based on the filename.
# 
#   * `bash`, `elvish`, `fish`, `zsh` - Use this specific shell injection scheme.
# 
# The default value is `detect`.
shell-integration = detect

# Shell integration features to enable. These require our shell integration
# to be loaded, either automatically via shell-integration or manually.
# 
# The format of this is a list of features to enable separated by commas. If
# you prefix a feature with `no-` then it is disabled. If you omit a feature,
# its default value is used, so you must explicitly disable features you don't
# want. You can also use `true` or `false` to turn all features on or off.
# 
# Available features:
# 
#   * `cursor` - Set the cursor to a blinking bar at the prompt.
# 
#   * `sudo` - Set sudo wrapper to preserve terminfo.
# 
#   * `title` - Set the window title via shell integration.
# 
# Example: `cursor`, `no-cursor`, `sudo`, `no-sudo`, `title`, `no-title`
shell-integration-features = cursor,no-sudo,title

# Sets the reporting format for OSC sequences that request color information.
# Ghostty currently supports OSC 10 (foreground), OSC 11 (background), and
# OSC 4 (256 color palette) queries, and by default the reported values
# are scaled-up RGB values, where each component are 16 bits. This is how
# most terminals report these values. However, some legacy applications may
# require 8-bit, unscaled, components. We also support turning off reporting
# altogether. The components are lowercase hex values.
# 
# Allowable values are:
# 
#   * `none` - OSC 4/10/11 queries receive no reply
# 
#   * `8-bit` - Color components are return unscaled, e.g. `rr/gg/bb`
# 
#   * `16-bit` - Color components are returned scaled, e.g. `rrrr/gggg/bbbb`
# 
# The default value is `16-bit`.
osc-color-report-format = 16-bit

# If true, allows the "KAM" mode (ANSI mode 2) to be used within
# the terminal. KAM disables keyboard input at the request of the
# application. This is not a common feature and is not recommended
# to be enabled. This will not be documented further because
# if you know you need KAM, you know. If you don't know if you
# need KAM, you don't need it.
vt-kam-allowed = false

# Custom shaders to run after the default shaders. This is a file path
# to a GLSL-syntax shader for all platforms.
# 
# Warning: Invalid shaders can cause Ghostty to become unusable such as by
# causing the window to be completely black. If this happens, you can
# unset this configuration to disable the shader.
# 
# On Linux, this requires OpenGL 4.2. Ghostty typically only requires
# OpenGL 3.3, but custom shaders push that requirement up to 4.2.
# 
# The shader API is identical to the Shadertoy API: you specify a `mainImage`
# function and the available uniforms match Shadertoy. The iChannel0 uniform
# is a texture containing the rendered terminal screen.
# 
# If the shader fails to compile, the shader will be ignored. Any errors
# related to shader compilation will not show up as configuration errors
# and only show up in the log, since shader compilation happens after
# configuration loading on the dedicated render thread.  For interactive
# development, use [shadertoy.com](https://shadertoy.com).
# 
# This can be repeated multiple times to load multiple shaders. The shaders
# will be run in the order they are specified.
# 
# Changing this value at runtime and reloading the configuration will only
# affect new windows, tabs, and splits.
custom-shader = 

# If `true` (default), the focused terminal surface will run an animation
# loop when custom shaders are used. This uses slightly more CPU (generally
# less than 10%) but allows the shader to animate. This only runs if there
# are custom shaders and the terminal is focused.
# 
# If this is set to `false`, the terminal and custom shader will only render
# when the terminal is updated. This is more efficient but the shader will
# not animate.
# 
# This can also be set to `always`, which will always run the animation
# loop regardless of whether the terminal is focused or not. The animation
# loop will still only run when custom shaders are used. Note that this
# will use more CPU per terminal surface and can become quite expensive
# depending on the shader and your terminal usage.
# 
# This value can be changed at runtime and will affect all currently
# open terminals.
custom-shader-animation = true

# Control the in-app notifications that Ghostty shows.
# 
# On Linux (GTK) with Adwaita, in-app notifications show up as toasts. Toasts
# appear overlaid on top of the terminal window. They are used to show
# information that is not critical but may be important.
# 
# Possible notifications are:
# 
#   - `clipboard-copy` (default: true) - Show a notification when text is copied
#     to the clipboard.
# 
# To specify a notification to enable, specify the name of the notification.
# To specify a notification to disable, prefix the name with `no-`. For
# example, to disable `clipboard-copy`, set this configuration to
# `no-clipboard-copy`. To enable it, set this configuration to `clipboard-copy`.
# 
# Multiple notifications can be enabled or disabled by separating them
# with a comma.
# 
# A value of "false" will disable all notifications. A value of "true" will
# enable all notifications.
# 
# This configuration only applies to GTK with Adwaita enabled.
app-notifications = clipboard-copy

# If anything other than false, fullscreen mode on macOS will not use the
# native fullscreen, but make the window fullscreen without animations and
# using a new space. It's faster than the native fullscreen mode since it
# doesn't use animations.
# 
# Important: tabs DO NOT WORK in this mode. Non-native fullscreen removes
# the titlebar and macOS native tabs require the titlebar. If you use tabs,
# you should not use this mode.
# 
# If you fullscreen a window with tabs, the currently focused tab will
# become fullscreen while the others will remain in a separate window in
# the background. You can switch to that window using normal window-switching
# keybindings such as command+tilde. When you exit fullscreen, the window
# will return to the tabbed state it was in before.
# 
# Allowable values are:
# 
#   * `visible-menu` - Use non-native macOS fullscreen, keep the menu bar visible
#   * `true` - Use non-native macOS fullscreen, hide the menu bar
#   * `false` - Use native macOS fullscreen
# 
# Changing this option at runtime works, but will only apply to the next
# time the window is made fullscreen. If a window is already fullscreen,
# it will retain the previous setting until fullscreen is exited.
macos-non-native-fullscreen = false

# The style of the macOS titlebar. Available values are: "native",
# "transparent", "tabs", and "hidden".
# 
# The "native" style uses the native macOS titlebar with zero customization.
# The titlebar will match your window theme (see `window-theme`).
# 
# The "transparent" style is the same as "native" but the titlebar will
# be transparent and allow your window background color to come through.
# This makes a more seamless window appearance but looks a little less
# typical for a macOS application and may not work well with all themes.
# 
# The "transparent" style will also update in real-time to dynamic
# changes to the window background color, e.g. via OSC 11. To make this
# more aesthetically pleasing, this only happens if the terminal is
# a window, tab, or split that borders the top of the window. This
# avoids a disjointed appearance where the titlebar color changes
# but all the topmost terminals don't match.
# 
# The "tabs" style is a completely custom titlebar that integrates the
# tab bar into the titlebar. This titlebar always matches the background
# color of the terminal. There are some limitations to this style:
# On macOS 13 and below, saved window state will not restore tabs correctly.
# macOS 14 does not have this issue and any other macOS version has not
# been tested.
# 
# The "hidden" style hides the titlebar. Unlike `window-decoration = false`,
# however, it does not remove the frame from the window or cause it to have
# squared corners. Changing to or from this option at run-time may affect
# existing windows in buggy ways.
# 
# When "hidden", the top titlebar area can no longer be used for dragging
# the window. To drag the window, you can use option+click on the resizable
# areas of the frame to drag the window. This is a standard macOS behavior
# and not something Ghostty enables.
# 
# The default value is "transparent". This is an opinionated choice
# but its one I think is the most aesthetically pleasing and works in
# most cases.
# 
# Changing this option at runtime only applies to new windows.
macos-titlebar-style = transparent

# Whether the proxy icon in the macOS titlebar is visible. The proxy icon
# is the icon that represents the folder of the current working directory.
# You can see this very clearly in the macOS built-in Terminal.app
# titlebar.
# 
# The proxy icon is only visible with the native macOS titlebar style.
# 
# Valid values are:
# 
#   * `visible` - Show the proxy icon.
#   * `hidden` - Hide the proxy icon.
# 
# The default value is `visible`.
# 
# This setting can be changed at runtime and will affect all currently
# open windows but only after their working directory changes again.
# Therefore, to make this work after changing the setting, you must
# usually `cd` to a different directory, open a different file in an
# editor, etc.
macos-titlebar-proxy-icon = visible

# macOS doesn't have a distinct "alt" key and instead has the "option"
# key which behaves slightly differently. On macOS by default, the
# option key plus a character will sometimes produces a Unicode character.
# For example, on US standard layouts option-b produces "∫". This may be
# undesirable if you want to use "option" as an "alt" key for keybindings
# in terminal programs or shells.
# 
# This configuration lets you change the behavior so that option is treated
# as alt.
# 
# The default behavior (unset) will depend on your active keyboard
# layout. If your keyboard layout is one of the keyboard layouts listed
# below, then the default value is "true". Otherwise, the default
# value is "false". Keyboard layouts with a default value of "true" are:
# 
#   - U.S. Standard
#   - U.S. International
# 
# Note that if an *Option*-sequence doesn't produce a printable character, it
# will be treated as *Alt* regardless of this setting. (e.g. `alt+ctrl+a`).
# 
# Explicit values that can be set:
# 
# If `true`, the *Option* key will be treated as *Alt*. This makes terminal
# sequences expecting *Alt* to work properly, but will break Unicode input
# sequences on macOS if you use them via the *Alt* key.
# 
# You may set this to `false` to restore the macOS *Alt* key unicode
# sequences but this will break terminal sequences expecting *Alt* to work.
# 
# The values `left` or `right` enable this for the left or right *Option*
# key, respectively.
# 
# This does not work with GLFW builds.
macos-option-as-alt = 

# Whether to enable the macOS window shadow. The default value is true.
# With some window managers and window transparency settings, you may
# find false more visually appealing.
macos-window-shadow = true

# If true, Ghostty on macOS will automatically enable the "Secure Input"
# feature when it detects that a password prompt is being displayed.
# 
# "Secure Input" is a macOS security feature that prevents applications from
# reading keyboard events. This can always be enabled manually using the
# `Ghostty > Secure Keyboard Entry` menu item.
# 
# Note that automatic password prompt detection is based on heuristics
# and may not always work as expected. Specifically, it does not work
# over SSH connections, but there may be other cases where it also
# doesn't work.
# 
# A reason to disable this feature is if you find that it is interfering
# with legitimate accessibility software (or software that uses the
# accessibility APIs), since secure input prevents any application from
# reading keyboard events.
macos-auto-secure-input = true

# If true, Ghostty will show a graphical indication when secure input is
# enabled. This indication is generally recommended to know when secure input
# is enabled.
# 
# Normally, secure input is only active when a password prompt is displayed
# or it is manually (and typically temporarily) enabled. However, if you
# always have secure input enabled, the indication can be distracting and
# you may want to disable it.
macos-secure-input-indication = true

# Customize the macOS app icon.
# 
# This only affects the icon that appears in the dock, application
# switcher, etc. This does not affect the icon in Finder because
# that is controlled by a hardcoded value in the signed application
# bundle and can't be changed at runtime. For more details on what
# exactly is affected, see the `NSApplication.icon` Apple documentation;
# that is the API that is being used to set the icon.
# 
# Valid values:
# 
#  * `official` - Use the official Ghostty icon.
#  * `blueprint`, `chalkboard`, `microchip`, `glass`, `holographic`,
#    `paper`, `retro`, `xray` - Official variants of the Ghostty icon
#    hand-created by artists (no AI).
#  * `custom-style` - Use the official Ghostty icon but with custom
#    styles applied to various layers. The custom styles must be
#    specified using the additional `macos-icon`-prefixed configurations.
#    The `macos-icon-ghost-color` and `macos-icon-screen-color`
#    configurations are required for this style.
# 
# WARNING: The `custom-style` option is _experimental_. We may change
# the format of the custom styles in the future. We're still finalizing
# the exact layers and customization options that will be available.
# 
# Other caveats:
# 
#   * The icon in the update dialog will always be the official icon.
#     This is because the update dialog is managed through a
#     separate framework and cannot be customized without significant
#     effort.
# 
macos-icon = official

# The material to use for the frame of the macOS app icon.
# 
# Valid values:
# 
#  * `aluminum` - A brushed aluminum frame. This is the default.
#  * `beige` - A classic 90's computer beige frame.
#  * `plastic` - A glossy, dark plastic frame.
#  * `chrome` - A shiny chrome frame.
# 
# This only has an effect when `macos-icon` is set to `custom-style`.
macos-icon-frame = aluminum

# The color of the ghost in the macOS app icon.
# 
# Note: This configuration is required when `macos-icon` is set to
# `custom-style`.
# 
# This only has an effect when `macos-icon` is set to `custom-style`.
# 
# Specified as either hex (`#RRGGBB` or `RRGGBB`) or a named X11 color.
macos-icon-ghost-color = 

# The color of the screen in the macOS app icon.
# 
# The screen is a gradient so you can specify multiple colors that
# make up the gradient. Comma-separated colors may be specified as
# as either hex (`#RRGGBB` or `RRGGBB`) or as named X11 colors.
# 
# Note: This configuration is required when `macos-icon` is set to
# `custom-style`.
# 
# This only has an effect when `macos-icon` is set to `custom-style`.
macos-icon-screen-color = 

# Put every surface (tab, split, window) into a dedicated Linux cgroup.
# 
# This makes it so that resource management can be done on a per-surface
# granularity. For example, if a shell program is using too much memory,
# only that shell will be killed by the oom monitor instead of the entire
# Ghostty process. Similarly, if a shell program is using too much CPU,
# only that surface will be CPU-throttled.
# 
# This will cause startup times to be slower (a hundred milliseconds or so),
# so the default value is "single-instance." In single-instance mode, only
# one instance of Ghostty is running (see gtk-single-instance) so the startup
# time is a one-time cost. Additionally, single instance Ghostty is much
# more likely to have many windows, tabs, etc. so cgroup isolation is a
# big benefit.
# 
# This feature requires systemd. If systemd is unavailable, cgroup
# initialization will fail. By default, this will not prevent Ghostty
# from working (see linux-cgroup-hard-fail).
# 
# Valid values are:
# 
#   * `never` - Never use cgroups.
#   * `always` - Always use cgroups.
#   * `single-instance` - Enable cgroups only for Ghostty instances launched
#     as single-instance applications (see gtk-single-instance).
# 
linux-cgroup = single-instance

# Memory limit for any individual terminal process (tab, split, window,
# etc.) in bytes. If this is unset then no memory limit will be set.
# 
# Note that this sets the "memory.high" configuration for the memory
# controller, which is a soft limit. You should configure something like
# systemd-oom to handle killing processes that have too much memory
# pressure.
linux-cgroup-memory-limit = 

# Number of processes limit for any individual terminal process (tab, split,
# window, etc.). If this is unset then no limit will be set.
# 
# Note that this sets the "pids.max" configuration for the process number
# controller, which is a hard limit.
linux-cgroup-processes-limit = 

# If this is false, then any cgroup initialization (for linux-cgroup)
# will be allowed to fail and the failure is ignored. This is useful if
# you view cgroup isolation as a "nice to have" and not a critical resource
# management feature, because Ghostty startup will not fail if cgroup APIs
# fail.
# 
# If this is true, then any cgroup initialization failure will cause
# Ghostty to exit or new surfaces to not be created.
# 
# Note: This currently only affects cgroup initialization. Subprocesses
# must always be able to move themselves into an isolated cgroup.
linux-cgroup-hard-fail = false

# Enable or disable GTK's OpenGL debugging logs. The default is `true` for
# debug builds, `false` for all others.
gtk-opengl-debug = false

# Obsolete configuration that should not be set. This was deprecated in
# Ghostty 1.1.3 and no longer has any effect. The configuration key will
# be fully removed in 1.2.0. You can manually override the GSK renderer
# using standard environment variables such as `GSK_RENDERER` (from GTK).
gtk-gsk-renderer = default

# If `true`, the Ghostty GTK application will run in single-instance mode:
# each new `ghostty` process launched will result in a new window if there is
# already a running process.
# 
# If `false`, each new ghostty process will launch a separate application.
# 
# The default value is `desktop` which will default to `true` if Ghostty
# detects that it was launched from the `.desktop` file such as an app
# launcher (like Gnome Shell)  or by D-Bus activation. If Ghostty is launched
# from the command line, it will default to `false`.
# 
# Note that debug builds of Ghostty have a separate single-instance ID
# so you can test single instance without conflicting with release builds.
gtk-single-instance = desktop

# When enabled, the full GTK titlebar is displayed instead of your window
# manager's simple titlebar. The behavior of this option will vary with your
# window manager.
# 
# This option does nothing when `window-decoration` is false or when running
# under macOS.
# 
# Changing this value at runtime and reloading the configuration will only
# affect new windows.
gtk-titlebar = true

# Determines the side of the screen that the GTK tab bar will stick to.
# Top, bottom, left, right, and hidden are supported. The default is top.
# 
# If this option has value `left` or `right` when using Adwaita, it falls
# back to `top`. `hidden`, meaning that tabs don't exist, is not supported
# without using Adwaita, falling back to `top`.
# 
# When `hidden` is set and Adwaita is enabled, a tab button displaying the
# number of tabs will appear in the title bar. It has the ability to open a
# tab overview for displaying tabs. Alternatively, you can use the
# `toggle_tab_overview` action in a keybind if your window doesn't have a
# title bar, or you can switch tabs with keybinds.
gtk-tabs-location = top

# If this is `true`, the titlebar will be hidden when the window is maximized,
# and shown when the titlebar is unmaximized. GTK only.
gtk-titlebar-hide-when-maximized = false

# Determines the appearance of the top and bottom bars when using the
# Adwaita tab bar. This requires `gtk-adwaita` to be enabled (it is
# by default).
# 
# Valid values are:
# 
#  * `flat` - Top and bottom bars are flat with the terminal window.
#  * `raised` - Top and bottom bars cast a shadow on the terminal area.
#  * `raised-border` - Similar to `raised` but the shadow is replaced with a
#    more subtle border.
# 
# Changing this value at runtime will only affect new windows.
adw-toolbar-style = raised

# If `true` (default), then the Ghostty GTK tabs will be "wide." Wide tabs
# are the new typical Gnome style where tabs fill their available space.
# If you set this to `false` then tabs will only take up space they need,
# which is the old style.
gtk-wide-tabs = true

# If `true` (default), Ghostty will enable Adwaita theme support. This
# will make `window-theme` work properly and will also allow Ghostty to
# properly respond to system theme changes, light/dark mode changing, etc.
# This requires a GTK4 desktop with a GTK4 theme.
# 
# If you are running GTK3 or have a GTK3 theme, you may have to set this
# to false to get your theme picked up properly. Having this set to true
# with GTK3 should not cause any problems, but it may not work exactly as
# expected.
# 
# This configuration only has an effect if Ghostty was built with
# Adwaita support.
gtk-adwaita = true

# Custom CSS files to be loaded.
# 
# This configuration can be repeated multiple times to load multiple files.
# Prepend a ? character to the file path to suppress errors if the file does
# not exist. If you want to include a file that begins with a literal ?
# character, surround the file path in double quotes (").
# The file size limit for a single stylesheet is 5MiB.
gtk-custom-css = 

# If `true` (default), applications running in the terminal can show desktop
# notifications using certain escape sequences such as OSC 9 or OSC 777.
desktop-notifications = true

# If `true`, the bold text will use the bright color palette.
bold-is-bright = false

# This will be used to set the `TERM` environment variable.
# HACK: We set this with an `xterm` prefix because vim uses that to enable key
# protocols (specifically this will enable `modifyOtherKeys`), among other
# features. An option exists in vim to modify this: `:set
# keyprotocol=ghostty:kitty`, however a bug in the implementation prevents it
# from working properly. https://github.com/vim/vim/pull/13211 fixes this.
term = xterm-ghostty

# String to send when we receive `ENQ` (`0x05`) from the command that we are
# running. Defaults to an empty string if not set.
enquiry-response = 

# Control the auto-update functionality of Ghostty. This is only supported
# on macOS currently, since Linux builds are distributed via package
# managers that are not centrally controlled by Ghostty.
# 
# Checking or downloading an update does not send any information to
# the project beyond standard network information mandated by the
# underlying protocols. To put it another way: Ghostty doesn't explicitly
# add any tracking to the update process. The update process works by
# downloading information about the latest version and comparing it
# client-side to the current version.
# 
# Valid values are:
# 
#  * `off` - Disable auto-updates.
#  * `check` - Check for updates and notify the user if an update is
#    available, but do not automatically download or install the update.
#  * `download` - Check for updates, automatically download the update,
#    notify the user, but do not automatically install the update.
# 
# If unset, we defer to Sparkle's default behavior, which respects the
# preference stored in the standard user defaults (`defaults(1)`).
# 
# Changing this value at runtime works after a small delay.
auto-update = 

# The release channel to use for auto-updates.
# 
# The default value of this matches the release channel of the currently
# running Ghostty version. If you download a pre-release version of Ghostty
# then this will be set to `tip` and you will receive pre-release updates.
# If you download a stable version of Ghostty then this will be set to
# `stable` and you will receive stable updates.
# 
# Valid values are:
# 
#  * `stable` - Stable, tagged releases such as "1.0.0".
#  * `tip` - Pre-release versions generated from each commit to the
#    main branch. This is the version that was in use during private
#    beta testing by thousands of people. It is generally stable but
#    will likely have more bugs than the stable channel.
# 
# Changing this configuration requires a full restart of
# Ghostty to take effect.
# 
# This only works on macOS since only macOS has an auto-update feature.
auto-update-channel = 

