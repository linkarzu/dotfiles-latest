// Filename: ~/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/plugins/keyboard_battery.swift
// ~/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/plugins/keyboard_battery.swift

// Prints the name and battery level of both halves of the connected split
// keyboard as "<name> <left> <right>", "--" for a half it couldn't read. Exits 1
// without printing when none is connected. When both are connected it's the
// first one in keyboards. Used by keyboard_battery.sh, which compiles it outside
// the sketchybar config directory, because writing there would hotload sketchybar.
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
    let connected = central.retrieveConnectedPeripherals(withServices: [batteryService])
    for name in keyboards {
      guard let found = connected.first(where: { ($0.name ?? "").lowercased().contains(name) })
      else { continue }
      keyboard = found
      keyboardName = name
      found.delegate = self
      central.connect(found)
      return
    }
    exit(1)
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

let reader = Reader()
DispatchQueue.main.asyncAfter(deadline: .now() + 8) { reader.report() }
RunLoop.main.run()
