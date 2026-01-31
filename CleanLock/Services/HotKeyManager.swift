import Foundation
import AppKit
import Carbon
import Combine

// MARK: - Global HotKey Handler

/// 全局热键处理器 - 使用 Carbon API 无需辅助功能权限
private var globalHotKeyHandler: (() -> Void)?

/// Carbon 事件处理回调
private func carbonHotKeyHandler(
    nextHandler: EventHandlerCallRef?,
    theEvent: EventRef?,
    userData: UnsafeMutableRawPointer?
) -> OSStatus {
    globalHotKeyHandler?()
    return noErr
}

@MainActor
final class HotKeyManager: ObservableObject {
    @Published var currentHotKey: HotKey = .default

    private var hotKeyRef: EventHotKeyRef?
    private var eventHandlerRef: EventHandlerRef?

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

        /// 转换为 Carbon 修饰键格式
        var carbonModifiers: UInt32 {
            var carbonMods: UInt32 = 0
            if modifiers.contains(.command) { carbonMods |= UInt32(cmdKey) }
            if modifiers.contains(.shift) { carbonMods |= UInt32(shiftKey) }
            if modifiers.contains(.option) { carbonMods |= UInt32(optionKey) }
            if modifiers.contains(.control) { carbonMods |= UInt32(controlKey) }
            return carbonMods
        }

        private func keyCodeToString(_ keyCode: UInt16) -> String {
            let keyMap: [UInt16: String] = [
                // 字母键
                0: "A", 1: "S", 2: "D", 3: "F", 4: "H", 5: "G", 6: "Z", 7: "X",
                8: "C", 9: "V", 11: "B", 12: "Q", 13: "W", 14: "E", 15: "R",
                16: "Y", 17: "T", 31: "O", 32: "U", 34: "I", 35: "P", 37: "L",
                38: "J", 40: "K", 45: "N", 46: "M",
                // 数字键
                18: "1", 19: "2", 20: "3", 21: "4", 22: "6", 23: "5",
                24: "=", 25: "9", 26: "7", 27: "-", 28: "8", 29: "0",
                // 符号键
                30: "]", 33: "[", 39: "'", 41: ";", 42: "\\", 43: ",",
                44: "/", 47: ".", 50: "`",
                // 功能键
                36: "↩", 48: "⇥", 49: "Space", 51: "⌫", 53: "Esc"
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
        registerHotKey()
    }

    func stop() {
        unregisterHotKey()
    }

    /// 重新注册热键（当热键设置改变时调用）
    func reregisterHotKey() {
        unregisterHotKey()
        registerHotKey()
    }

    private func registerHotKey() {
        // 设置全局回调
        globalHotKeyHandler = { [weak self] in
            Task { @MainActor in
                self?.onHotKeyPressed?()
            }
        }

        // 注册事件处理器
        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )

        let status = InstallEventHandler(
            GetApplicationEventTarget(),
            carbonHotKeyHandler,
            1,
            &eventType,
            nil,
            &eventHandlerRef
        )

        guard status == noErr else {
            print("Failed to install event handler: \(status)")
            return
        }

        // 注册热键
        let hotKeyID = EventHotKeyID(signature: OSType(0x434C4B00), id: 1) // "CLK\0"

        let registerStatus = RegisterEventHotKey(
            UInt32(currentHotKey.keyCode),
            currentHotKey.carbonModifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )

        if registerStatus != noErr {
            print("Failed to register hotkey: \(registerStatus)")
        }
    }

    private func unregisterHotKey() {
        if let hotKeyRef = hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
            self.hotKeyRef = nil
        }

        if let eventHandlerRef = eventHandlerRef {
            RemoveEventHandler(eventHandlerRef)
            self.eventHandlerRef = nil
        }

        globalHotKeyHandler = nil
    }

    func saveHotKey() {
        if let data = try? JSONEncoder().encode(currentHotKey) {
            UserDefaults.standard.set(data, forKey: "CleanLockHotKey")
        }
        // 保存后重新注册热键
        reregisterHotKey()
    }

    func loadHotKey() {
        if let data = UserDefaults.standard.data(forKey: "CleanLockHotKey"),
           let hotKey = try? JSONDecoder().decode(HotKey.self, from: data) {
            currentHotKey = hotKey
        }
    }

    deinit {
        // 注意：deinit 不在 MainActor 上下文中
        // 直接调用 Carbon API 清理资源（这些是 C API，线程安全）
        if let ref = hotKeyRef {
            UnregisterEventHotKey(ref)
        }
        if let ref = eventHandlerRef {
            RemoveEventHandler(ref)
        }
        globalHotKeyHandler = nil
    }
}
