# Custom tab bar that draws the current kitty session name once, before the
# first tab, instead of repeating it in every tab title
# Requires "tab_bar_style custom" in kitty.conf
# https://github.com/kovidgoyal/kitty/issues/8911#issuecomment-4806908910

from kitty.fast_data_types import Screen, get_boss, get_options
from kitty.tab_bar import (
    DrawData,
    ExtraData,
    TabBarData,
    as_rgb,
    color_as_int,
    draw_tab_with_powerline,
    powerline_symbols,
)


def current_session_name(os_window_id: int) -> str:
    tm = get_boss().os_window_map.get(os_window_id)
    if tm is None:
        return ""
    tab = tm.active_tab
    if tab is None:
        return ""
    return tab.active_session_name or tab.created_in_session_name


def draw_tab(
    draw_data: DrawData,
    screen: Screen,
    tab: TabBarData,
    before: int,
    max_tab_length: int,
    index: int,
    is_last: bool,
    extra_data: ExtraData,
) -> int:
    # Draw the session name once, before the first tab
    if index == 1:
        sess_name = current_session_name(draw_data.os_window_id)
        if sess_name:
            orig = (screen.cursor.fg, screen.cursor.bg, screen.cursor.bold, screen.cursor.italic)
            tab_bg = orig[1]
            # color4 (linkarzu_color04) as the background, with the active
            # tab's text color (active_tab_foreground) on top
            sess_bg = as_rgb(color_as_int(get_options().color4))
            screen.cursor.fg = as_rgb(color_as_int(draw_data.active_fg))
            screen.cursor.bg = sess_bg
            screen.cursor.bold = True
            screen.cursor.italic = False
            screen.draw(f" {sess_name} ")
            # draw_tab_with_powerline only pads and opens a tab that starts at
            # column 0, so open the first tab here with a powerline arrow and a
            # space, otherwise it starts with a flat edge and no padding
            screen.cursor.bold = False
            screen.cursor.fg = sess_bg
            screen.cursor.bg = tab_bg
            screen.draw(powerline_symbols.get(draw_data.powerline_style, ("", ""))[0])
            screen.draw(" ")
            screen.cursor.fg, screen.cursor.bg, screen.cursor.bold, screen.cursor.italic = orig
            # Don't count the session name against the first tab's max length,
            # otherwise its title gets truncated with … when many tabs are open
            before = screen.cursor.x

    end = draw_tab_with_powerline(
        draw_data, screen, tab, before, max_tab_length, index, is_last, extra_data
    )
    # An inactive tab closes with a powerline arrow drawn in its tab background
    # when the next tab is the active one or when it's the last tab.
    # inactive_tab_background matches the transparent window background, so
    # only the dark arrow glyph shows. The active tab's green arrow and the
    # soft separator between two inactive tabs are visible, so those are kept
    if tab.is_active:
        return end
    default_bg = as_rgb(color_as_int(draw_data.default_bg))
    if extra_data.next_tab is None:
        # Last tab, blank the arrow out
        screen.cursor.x = end - 1
        screen.cursor.bg = default_bg
        screen.draw(" ")
    elif extra_data.next_tab.is_active:
        # Next tab is the active one, draw the inverse of the arrow in the
        # active tab's background instead (kitty draws U+E0D7 pixel exact),
        # the green tab then opens with a transparent notch instead of a dark
        # one, then redraw the space kitty puts after the separator, it pads
        # the active tab's title and is drawn in its background
        next_tab_bg = as_rgb(draw_data.tab_bg(extra_data.next_tab))
        screen.cursor.x = end - 1
        screen.cursor.fg = next_tab_bg
        screen.cursor.bg = default_bg
        screen.draw("")
        if end < screen.columns:
            screen.cursor.bg = next_tab_bg
            screen.draw(" ")
    return end
