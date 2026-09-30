// Filename: ~/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/plugins/stream_reminder.swift
// ~/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/plugins/stream_reminder.swift

// Stream reminder alert used by custom_text.sh. It stays on screen until OK is
// clicked and prints "thanked" when the checkbox was ticked, otherwise "later".
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

app.activate(ignoringOtherApps: true)
alert.runModal()
print(checkbox.state == .on ? "thanked" : "later")
