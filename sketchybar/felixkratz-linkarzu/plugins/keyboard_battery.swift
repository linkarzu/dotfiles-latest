// Filename: ~/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/plugins/keyboard_battery.swift
// ~/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/plugins/keyboard_battery.swift

// Prints the name and battery level of both halves of the connected split
// keyboard as "<name> <left> <right>", "--" for a half it couldn't read. Exits 1
// without printing when none is connected. When both are connected it's the
// first one in keyboards. Used by keyboard_battery.sh, which compiles it outside
// the sketchybar config directory, because writing there would hotload sketchybar.
//
// With --watch-layer it keeps running instead, and shows on the keyboard.mode item
// and the popup's Layer row whether the keyboard is on its macOS or Windows layer.
// The keyboard notifies
// when that changes (src/layer_report.c in zmk-keyboard-forager and
// zmk-keyboard-toucan). The item stays blank for firmware without that service.
//
// ZMK exposes one Bluetooth battery characteristic per half. macOS only shows
// the first, so this reads them directly. The right half is the split
// peripheral: its characteristic is the one with a user description descriptor
// (2901, "Peripheral 0"), and the left half, the central, has none.
// (CONFIG_ZMK_SPLIT_BLE_CENTRAL_BATTERY_LEVEL_PROXY in zmk-keyboard-forager and
// zmk-keyboard-toucan)

import CoreBluetooth
import Foundation

let keyboards = ["toucan", "forager"]
let batteryService = CBUUID(string: "180F")
let batteryLevel = CBUUID(string: "2A19")
let userDescription = CBUUID(string: "2901")
let layerService = CBUUID(string: "1300D6B0-6B7B-4845-BC0E-F39462875A3E")
let layerValue = CBUUID(string: "557A1190-E35B-448E-A7CB-FE6352D6021A")

func connectedKeyboard(_ central: CBCentralManager) -> (peripheral: CBPeripheral, name: String)? {
  let connected = central.retrieveConnectedPeripherals(withServices: [batteryService])
  for name in keyboards {
    if let found = connected.first(where: { ($0.name ?? "").lowercased().contains(name) }) {
      return (found, name)
    }
  }
  return nil
}

final class LayerWatcher: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
  private var central: CBCentralManager!
  private var keyboard: CBPeripheral?
  private var shown: UInt8?

  override init() {
    super.init()
    central = CBCentralManager(delegate: self, queue: nil)
    Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in self?.check() }
  }

  func centralManagerDidUpdateState(_ central: CBCentralManager) {
    check()
  }

  // Follows the keyboard the battery levels come from.
  private func check() {
    guard central.state == .poweredOn else { return }
    let found = connectedKeyboard(central)?.peripheral
    guard found !== keyboard else { return }
    keyboard = found
    show(nil)
    if let found {
      found.delegate = self
      central.connect(found)
    }
  }

  func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
    peripheral.discoverServices([layerService])
  }

  func centralManager(
    _ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?
  ) {
    guard peripheral === keyboard else { return }
    keyboard = nil
    show(nil)
  }

  // New firmware adds the service without the keyboard having to be paired again.
  func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
    peripheral.discoverServices([layerService])
  }

  func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
    for service in peripheral.services ?? [] where service.uuid == layerService {
      peripheral.discoverCharacteristics([layerValue], for: service)
    }
  }

  func peripheral(
    _ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?
  ) {
    for characteristic in service.characteristics ?? [] where characteristic.uuid == layerValue {
      peripheral.setNotifyValue(true, for: characteristic)
      peripheral.readValue(for: characteristic)
    }
  }

  func peripheral(
    _ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?
  ) {
    if peripheral === keyboard, let value = characteristic.value?.first { show(value) }
  }

  private func show(_ value: UInt8?) {
    guard value != shown else { return }
    shown = value
    let colors = ProcessInfo.processInfo.environment
    let label: String
    let layer: String
    let color: String
    switch value {
    case 0?: (label, layer, color) = ("\u{F179}", "macOS", colors["WHITE"] ?? "0xffffffff")
    case 1?: (label, layer, color) = ("\u{F17A}", "Windows", colors["BLUE"] ?? "0xff04d1f9")
    default: (label, layer, color) = ("", "unknown", colors["GREY"] ?? "0xff7f8490")
    }
    let sketchybar = Process()
    sketchybar.executableURL = URL(fileURLWithPath: "/usr/bin/env")
    sketchybar.arguments = [
      "sketchybar", "--set", "keyboard.mode", "label=\(label)", "label.color=\(color)",
      "--set", "keyboard.popup.layer", "label=\(layer)", "label.color=\(color)",
    ]
    try? sketchybar.run()
  }
}

final class Reader: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
  private var central: CBCentralManager!
  private var keyboard: CBPeripheral?
  private var keyboardName = ""
  private var pendingServices = 0
  private var levels: [CBCharacteristic: UInt8] = [:]
  private var isRight: [CBCharacteristic: Bool] = [:]

  override init() {
    super.init()
    central = CBCentralManager(delegate: self, queue: nil)
  }

  func centralManagerDidUpdateState(_ central: CBCentralManager) {
    guard central.state != .unknown, central.state != .resetting else { return }
    guard central.state == .poweredOn else { exit(1) }
    guard let (found, name) = connectedKeyboard(central) else { exit(1) }
    keyboard = found
    keyboardName = name
    found.delegate = self
    central.connect(found)
  }

  func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
    peripheral.discoverServices([batteryService])
  }

  func centralManager(
    _ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?
  ) {
    exit(1)
  }

  func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
    let services = peripheral.services ?? []
    guard !services.isEmpty else { exit(1) }
    pendingServices = services.count
    for service in services {
      peripheral.discoverCharacteristics([batteryLevel], for: service)
    }
  }

  func peripheral(
    _ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?
  ) {
    for characteristic in service.characteristics ?? [] {
      peripheral.readValue(for: characteristic)
      peripheral.discoverDescriptors(for: characteristic)
    }
    pendingServices -= 1
    finishIfDone()
  }

  func peripheral(
    _ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?
  ) {
    if let level = characteristic.value?.first { levels[characteristic] = level }
    finishIfDone()
  }

  func peripheral(
    _ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic,
    error: Error?
  ) {
    isRight[characteristic] =
      characteristic.descriptors?.contains { $0.uuid == userDescription } ?? false
    finishIfDone()
  }

  private func finishIfDone() {
    guard pendingServices == 0 else { return }
    let characteristics = keyboard?.services?.flatMap { $0.characteristics ?? [] } ?? []
    let done = characteristics.allSatisfy { levels[$0] != nil && isRight[$0] != nil }
    if done { report() }
  }

  func report() {
    func level(right: Bool) -> String {
      levels.first { isRight[$0.key] == right }.map { String($0.value) } ?? "--"
    }
    guard !levels.isEmpty else { exit(1) }
    print(keyboardName, level(right: false), level(right: true))
    exit(0)
  }
}

if CommandLine.arguments.contains("--watch-layer") {
  let watcher = LayerWatcher()
  withExtendedLifetime(watcher) { RunLoop.main.run() }
}

let reader = Reader()
DispatchQueue.main.asyncAfter(deadline: .now() + 8) { reader.report() }
RunLoop.main.run()
