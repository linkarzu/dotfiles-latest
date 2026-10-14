// Filename: ~/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/plugins/stream_reminder.swift
// ~/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/plugins/stream_reminder.swift

// Stream reminder alert used by custom_text.sh. It stays on screen until OK is
// clicked and prints "thanked" when the checkbox was ticked, otherwise "later".
// It opens over OBS's window, on whichever screen OBS is on (the main screen
// when OBS has no window), like the livestream result popups.
// custom_text.sh compiles it outside the sketchybar config directory, because
// writing there would hotload sketchybar and reset the timer.

import AppKit

let app = NSApplication.shared
app.setActivationPolicy(.accessory)

let alert = NSAlert()
alert.messageText = "Stream reminder"
alert.informativeText = "Thank YouTube members."
alert.alertStyle = .informational
alert.addButton(withTitle: "OK")

// An accessory view sits between the message and the button.
let checkbox = NSButton(checkboxWithTitle: "I thanked the members", target: nil, action: nil)
checkbox.sizeToFit()
alert.accessoryView = checkbox
alert.layout()
alert.window.level = .floating

// OBS's largest on-screen window, from CGWindowList (no Accessibility permission needed).
func obsCenter() -> CGPoint? {
    let options: CGWindowListOption = [.optionOnScreenOnly, .excludeDesktopElements]
    guard let windows = CGWindowListCopyWindowInfo(options, kCGNullWindowID) as? [[String: Any]] else { return nil }
    var best: CGRect?
    for window in windows {
        guard window[kCGWindowOwnerName as String] as? String == "OBS Studio",
              window[kCGWindowLayer as String] as? Int == 0,
              let bounds = window[kCGWindowBounds as String] as? NSDictionary,
              let rect = CGRect(dictionaryRepresentation: bounds) else { continue }
        if best == nil || rect.width * rect.height > best!.width * best!.height { best = rect }
    }
    return best.map { CGPoint(x: $0.midX, y: $0.midY) }
}

app.activate(ignoringOtherApps: true)
alert.window.makeKeyAndOrderFront(nil)
if let center = obsCenter(), let mainHeight = NSScreen.screens.first?.frame.height {
    // Move it once it's on screen: a modal run centers a window that was never shown.
    let size = alert.window.frame.size
    alert.window.setFrameOrigin(NSPoint(x: center.x - size.width / 2, y: mainHeight - center.y - size.height / 2))
}
app.runModal(for: alert.window)
print(checkbox.state == .on ? "thanked" : "later")
