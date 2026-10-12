# Custom tab bar that draws the current kitty session name once, before the
# first tab, instead of repeating it in every tab title
# Requires "tab_bar_style custom" in kitty.conf
# https://github.com/kovidgoyal/kitty/issues/8911#issuecomment-4806908910

from kitty.fast_data_types import Screen, get_boss
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
            bar_bg = as_rgb(color_as_int(draw_data.inactive_bg))
            # active_tab_background (green) as the text color, on the inactive
            # tab background, active_tab_foreground is the same color as the bg
            screen.cursor.fg = as_rgb(color_as_int(draw_data.active_bg))
            screen.cursor.bg = bar_bg
            screen.cursor.bold = True
            screen.cursor.italic = False
            screen.draw(f" {sess_name} ")
            # draw_tab_with_powerline only pads and opens a tab that starts at
            # column 0, so open the first tab here with a powerline arrow and a
            # space, otherwise it starts with a flat edge and no padding
            separator = powerline_symbols.get(draw_data.powerline_style, ("\ue0b0", "\ue0b1"))[0]
            screen.cursor.bold = False
            screen.cursor.fg = bar_bg
            screen.cursor.bg = tab_bg
            screen.draw(separator)
            screen.draw(" ")
            screen.cursor.fg, screen.cursor.bg, screen.cursor.bold, screen.cursor.italic = orig
            # Don't count the session name against the first tab's max length,
            # otherwise its title gets truncated with … when many tabs are open
            before = screen.cursor.x

    return draw_tab_with_powerline(
        draw_data, screen, tab, before, max_tab_length, index, is_last, extra_data
    )
