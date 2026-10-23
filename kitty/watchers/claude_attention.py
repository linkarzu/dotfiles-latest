# Clears Claude Code attention in SketchyBar once its Kitty window stays
# focused for two seconds, mirroring the focus acknowledgement that
# opencode/plugins/sketchybar-status.ts does for OpenCode.
#
# claude/hooks/sketchybar-status.sh raises attention through the
# claude_waiting user var when a session finishes or needs input while its
# window is not focused.
#
# It also redraws the tab bar when a Claude or OpenCode user var changes, so
# the status dots drawn by kitty/tab_bar.py update right away.
#
# Tab titles come from the running program (tab.active_exe in tab_bar.py), and
# kitty only redraws the tab bar on events like a title change, not when the
# foreground process changes. A tab opened by a session or by
# 562-skhdKittyClaude.sh is drawn before nvim or claude starts, so it showed no
# name or a stale one. When a window loads, the tab bar is redrawn a few times
# over the next seconds on kitty timers, so nothing waits on it.
#
# Claude Code skips its prompt suggestion (the ghost text Tab accepts) when a
# turn ends while the terminal reports focus out. So when a Claude window loses
# focus, a focus in report is sent right behind it and Claude Code always
# thinks it is focused. claude_busy is published for the whole session, so
# its presence marks a window running Claude Code.

import subprocess
from typing import Any

from kitty.boss import Boss
from kitty.fast_data_types import add_timer, current_focused_os_window_id, get_boss
from kitty.window import Window

ack_delay = 2.0
# Seconds after a window loads at which its OS window's tab bar is redrawn
retitle_delays = (0.3, 1.0, 2.5, 5.0)
sketchybar_bin = "/opt/homebrew/bin/sketchybar"


def waiting(window: Window) -> bool:
    return window.user_vars.get("claude_waiting", "0") not in ("", "0")


def acknowledge(window_id: int) -> None:
    boss = get_boss()
    window = boss.window_id_map.get(window_id)
    if window is None or not waiting(window):
        return
    if boss.active_window is not window or current_focused_os_window_id() != window.os_window_id:
        return

    window.set_user_var("claude_waiting", "0")
    window.set_user_var("claude_reason", "none")
    subprocess.Popen(
        [sketchybar_bin, "--trigger", "opencode_update"],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )


def refocus(window_id: int) -> None:
    window = get_boss().window_id_map.get(window_id)
    if window is None or "claude_busy" not in window.user_vars:
        return
    if window.screen.focus_tracking_enabled:
        window.write_to_child(b"\x1b[I")


def redraw_tab_bar(os_window_id: int) -> None:
    tm = get_boss().os_window_map.get(os_window_id)
    if tm is not None:
        tm.mark_tab_bar_dirty()


def on_load(boss: Boss, window: Window, data: dict[str, Any]) -> None:
    os_window_id = window.os_window_id
    for delay in retitle_delays:
        add_timer(lambda timer_id: redraw_tab_bar(os_window_id), delay, False)


def on_focus_change(boss: Boss, window: Window, data: dict[str, Any]) -> None:
    if not data.get("focused"):
        if "claude_busy" in window.user_vars:
            window_id = window.id
            add_timer(lambda timer_id: refocus(window_id), 0.05, False)
        return
    if not waiting(window):
        return
    window_id = window.id
    add_timer(lambda timer_id: acknowledge(window_id), ack_delay, False)


def on_set_user_var(boss: Boss, window: Window, data: dict[str, Any]) -> None:
    if not data.get("key", "").startswith(("claude_", "opencode_")):
        return
    redraw_tab_bar(window.os_window_id)
