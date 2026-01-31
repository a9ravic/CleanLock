import Foundation
import AppKit
import Carbon
import Combine

@MainActor
final class HotKeyManager: ObservableObject {
    @Published var currentHotKey: HotKey = .default

    private var eventMonitor: Any?
    var onHotKeyPressed: (() -> Void)?

    struct HotKey: Equatable, Codable {
        var keyCode: UInt16
        var modifiers: NSEvent.ModifierFlags

        static let `default` = HotKey(
            keyCode: 40, // K
            modifiers: [.command, .shift]
        )

        var displayString: String {
            var parts: [String] = []
            if modifiers.contains(.command) { parts.append("⌘") }
            if modifiers.contains(.shift) { parts.append("⇧") }
            if modifiers.contains(.option) { parts.append("⌥") }
            if modifiers.contains(.control) { parts.append("⌃") }
            parts.append(keyCodeToString(keyCode))
            return parts.joined()
        }

        private func keyCodeToString(_ keyCode: UInt16) -> String {
            let keyMap: [UInt16: String] = [
                0: "A", 1: "S", 2: "D", 3: "F", 4: "H", 5: "G", 6: "Z", 7: "X",
                8: "C", 9: "V", 11: "B", 12: "Q", 13: "W", 14: "E", 15: "R",
                16: "Y", 17: "T", 31: "O", 32: "U", 34: "I", 35: "P", 37: "L",
                38: "J", 40: "K", 45: "N", 46: "M"
            ]
            return keyMap[keyCode] ?? "?"
        }

        // Custom Codable for NSEvent.ModifierFlags
        enum CodingKeys: String, CodingKey {
            case keyCode
            case modifiersRawValue
        }

        init(keyCode: UInt16, modifiers: NSEvent.ModifierFlags) {
            self.keyCode = keyCode
            self.modifiers = modifiers
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            keyCode = try container.decode(UInt16.self, forKey: .keyCode)
            let rawValue = try container.decode(UInt.self, forKey: .modifiersRawValue)
            modifiers = NSEvent.ModifierFlags(rawValue: rawValue)
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(keyCode, forKey: .keyCode)
            try container.encode(modifiers.rawValue, forKey: .modifiersRawValue)
        }
    }

    func start() {
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            Task { @MainActor in
                self?.handleGlobalKeyEvent(event)
            }
        }
    }

    func stop() {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
    }

    private func handleGlobalKeyEvent(_ event: NSEvent) {
        let pressedModifiers = event.modifierFlags.intersection([.command, .shift, .option, .control])
        let requiredModifiers = currentHotKey.modifiers.intersection([.command, .shift, .option, .control])

        if event.keyCode == currentHotKey.keyCode && pressedModifiers == requiredModifiers {
            onHotKeyPressed?()
        }
    }

    func saveHotKey() {
        if let data = try? JSONEncoder().encode(currentHotKey) {
            UserDefaults.standard.set(data, forKey: "CleanLockHotKey")
        }
    }

    func loadHotKey() {
        if let data = UserDefaults.standard.data(forKey: "CleanLockHotKey"),
           let hotKey = try? JSONDecoder().decode(HotKey.self, from: data) {
            currentHotKey = hotKey
        }
    }

    deinit {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }
}
