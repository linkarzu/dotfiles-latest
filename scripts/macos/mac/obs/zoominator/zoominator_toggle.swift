// Filename: ~/github/dotfiles-latest/scripts/macos/mac/obs/zoominator/zoominator_toggle.swift

// Presses ctrl+alt+shift+cmd+F17 the way the OBS Zoominator plugin can read it.
// Zoominator ignores the modifiers carried by a key press and instead asks macOS
// which modifier keys are held at that moment. A keyboard (ZMK) sends the
// modifiers and the key in the same instant, before macOS counts them as held,
// so Zoominator never fires. This presses each modifier on its own, waits, then
// taps F17, so they are held by the time F17 arrives.

import Cocoa

let modifiers: [(key: CGKeyCode, flag: CGEventFlags)] = [
    (0x3B, .maskControl), (0x3A, .maskAlternate), (0x38, .maskShift), (0x37, .maskCommand),
]
let f17: CGKeyCode = 0x40

func anyModifierHeld() -> Bool {
    [0x3B, 0x3E, 0x3A, 0x3D, 0x38, 0x3C, 0x37, 0x36].contains {
        CGEventSource.keyState(.combinedSessionState, key: CGKeyCode($0))
    }
}

// skhd runs this while the keyboard still holds its own modifiers; their release
// would cancel ours, so wait for it first (up to 1 s).
for _ in 0..<100 where anyModifierHeld() { usleep(10_000) }

let source = CGEventSource(stateID: .hidSystemState)
var flags = CGEventFlags()

func post(_ key: CGKeyCode, down: Bool) {
    let event = CGEvent(keyboardEventSource: source, virtualKey: key, keyDown: down)!
    event.flags = flags
    event.post(tap: .cghidEventTap)
}

for modifier in modifiers {
    flags.insert(modifier.flag)
    post(modifier.key, down: true)
    usleep(15_000)
}
usleep(40_000)
post(f17, down: true)
usleep(30_000)
post(f17, down: false)
for modifier in modifiers.reversed() {
    flags.remove(modifier.flag)
    post(modifier.key, down: false)
    usleep(15_000)
}
