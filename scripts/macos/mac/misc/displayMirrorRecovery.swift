#!/usr/bin/env swift
// The mirrored external screen is absent from hs.screen.allScreens(). Use
// CoreGraphics' online list to detect and unmirror it even after hs.reload().
import CoreGraphics
import Foundation

func fail(_ message: String) -> Never {
    fputs("\(message)\n", stderr)
    exit(1)
}

guard CommandLine.arguments.count == 2,
      ["status", "unmirror"].contains(CommandLine.arguments[1]) else {
    fail("Usage: displayMirrorRecovery.swift status|unmirror")
}

var count: CGDisplayCount = 0
guard CGGetOnlineDisplayList(0, nil, &count) == .success else {
    fail("Could not list online displays")
}
var displays = [CGDirectDisplayID](repeating: 0, count: Int(count))
let result = displays.withUnsafeMutableBufferPointer { buffer in
    CGGetOnlineDisplayList(count, buffer.baseAddress, &count)
}
guard result == .success else { fail("Could not read online displays") }

let online = Array(displays.prefix(Int(count)))
let internalDisplays = online.filter { CGDisplayIsBuiltin($0) != 0 }
let externalDisplays = online.filter { CGDisplayIsBuiltin($0) == 0 }
guard internalDisplays.count == 1, externalDisplays.count == 1 else {
    fail("Expected one built-in and one external online display")
}

let external = externalDisplays[0]
let mirrorSource = CGDisplayMirrorsDisplay(external)
if CommandLine.arguments[1] == "status" {
    print(mirrorSource == internalDisplays[0] ? "mirrored" : "extended")
    exit(0)
}

guard mirrorSource == internalDisplays[0] else {
    fail("External display is not mirroring the MacBook")
}

var config: CGDisplayConfigRef?
guard CGBeginDisplayConfiguration(&config) == .success, let config else {
    fail("Could not start display configuration")
}
guard CGConfigureDisplayMirrorOfDisplay(config, external, 0) == .success else {
    CGCancelDisplayConfiguration(config)
    fail("Could not stop external display mirroring")
}
guard CGCompleteDisplayConfiguration(config, .forSession) == .success else {
    fail("Could not commit extended display configuration")
}
print("extended")
