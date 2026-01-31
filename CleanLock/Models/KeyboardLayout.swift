import Foundation

// MARK: - Key Model

struct Key: Identifiable, Equatable, Hashable {
    // 使用 keyCode 作为稳定的身份标识，而不是 UUID
    // 这允许 SwiftUI 正确识别键的身份，避免不必要的视图重建
    var id: UInt16 { keyCode }
    let keyCode: UInt16
    let label: String
    let secondaryLabel: String?
    let width: CGFloat
    let height: CGFloat
    let isModifier: Bool
    let isPlaceholder: Bool
    let isFunctionKey: Bool
    let symbolName: String?

    init(
        keyCode: UInt16,
        label: String,
        secondaryLabel: String? = nil,
        width: CGFloat = 1.0,
        height: CGFloat = 1.0,
        isModifier: Bool = false,
        isPlaceholder: Bool = false,
        isFunctionKey: Bool = false,
        symbolName: String? = nil
    ) {
        self.keyCode = keyCode
        self.label = label
        self.secondaryLabel = secondaryLabel
        self.width = width
        self.height = height
        self.isModifier = isModifier
        self.isPlaceholder = isPlaceholder
        self.isFunctionKey = isFunctionKey
        self.symbolName = symbolName
    }

    // 用于追踪已分配的占位符 keyCode
    private static var nextPlaceholderKeyCode: UInt16 = 65531  // 从 65531 开始递减

    /// 创建占位符键（用于无法拦截的功能键位置）
    /// 每个占位符使用唯一的 keyCode（65531, 65530, 65529, 65528）
    static func placeholder(width: CGFloat = 1.0) -> Key {
        let keyCode = nextPlaceholderKeyCode
        nextPlaceholderKeyCode -= 1
        return Key(keyCode: keyCode, label: "", width: width, isPlaceholder: true)
    }

    static func == (lhs: Key, rhs: Key) -> Bool {
        lhs.keyCode == rhs.keyCode &&
        lhs.label == rhs.label &&
        lhs.width == rhs.width &&
        lhs.height == rhs.height
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(keyCode)
    }
}

// MARK: - Arrow Key Configuration

enum ArrowKeyStyle {
    case halfHeight  // 上下箭头是半高的（真实 MacBook 风格）
    case fullHeight  // 所有箭头都是全高的
}

// MARK: - Keyboard Layout

struct KeyboardLayout {
    let rows: [[Key]]
    let arrowKeyStyle: ArrowKeyStyle

    /// 所有需要清洁的键（排除占位符）
    var allKeys: [Key] {
        rows.flatMap { $0 }.filter { !$0.isPlaceholder }
    }

    // MARK: - MacBook 键盘布局（精确还原真实键盘）

    static let macBook: KeyboardLayout = {
        // ═══════════════════════════════════════════════════════════════
        // Row 0: Function Row - 功能键行
        // 矮键设计，高度为普通键的 50%
        // esc F1 F2 F3 F4 F5 F6 F7 F8 F9 F10 F11 F12
        // ═══════════════════════════════════════════════════════════════
        let row0: [Key] = [
            Key(keyCode: 53, label: "esc", width: 1.58, isFunctionKey: true),
            Key(keyCode: 122, label: "F1", width: 1.0, isFunctionKey: true, symbolName: "sun.min"),
            Key(keyCode: 120, label: "F2", width: 1.0, isFunctionKey: true, symbolName: "sun.max"),
            Key.placeholder(width: 1.0),  // F3 - Mission Control (系统拦截)
            Key.placeholder(width: 1.0),  // F4 - Spotlight (系统拦截)
            Key.placeholder(width: 1.0),  // F5 - Dictation (系统拦截)
            Key.placeholder(width: 1.0),  // F6 - Do Not Disturb (系统拦截)
            Key(keyCode: 98, label: "F7", width: 1.0, isFunctionKey: true, symbolName: "backward.fill"),
            Key(keyCode: 100, label: "F8", width: 1.0, isFunctionKey: true, symbolName: "playpause.fill"),
            Key(keyCode: 101, label: "F9", width: 1.0, isFunctionKey: true, symbolName: "forward.fill"),
            Key(keyCode: 109, label: "F10", width: 1.0, isFunctionKey: true, symbolName: "speaker.slash.fill"),
            Key(keyCode: 103, label: "F11", width: 1.0, isFunctionKey: true, symbolName: "speaker.wave.1.fill"),
            Key(keyCode: 111, label: "F12", width: 1.0, isFunctionKey: true, symbolName: "speaker.wave.3.fill"),
        ]

        // ═══════════════════════════════════════════════════════════════
        // Row 1: Number Row - 数字键行
        // ` 1 2 3 4 5 6 7 8 9 0 - = delete
        // ═══════════════════════════════════════════════════════════════
        let row1: [Key] = [
            Key(keyCode: 50, label: "`", secondaryLabel: "~"),
            Key(keyCode: 18, label: "1", secondaryLabel: "!"),
            Key(keyCode: 19, label: "2", secondaryLabel: "@"),
            Key(keyCode: 20, label: "3", secondaryLabel: "#"),
            Key(keyCode: 21, label: "4", secondaryLabel: "$"),
            Key(keyCode: 23, label: "5", secondaryLabel: "%"),
            Key(keyCode: 22, label: "6", secondaryLabel: "^"),
            Key(keyCode: 26, label: "7", secondaryLabel: "&"),
            Key(keyCode: 28, label: "8", secondaryLabel: "*"),
            Key(keyCode: 25, label: "9", secondaryLabel: "("),
            Key(keyCode: 29, label: "0", secondaryLabel: ")"),
            Key(keyCode: 27, label: "-", secondaryLabel: "_"),
            Key(keyCode: 24, label: "=", secondaryLabel: "+"),
            Key(keyCode: 51, label: "delete", width: 1.58, symbolName: "delete.left")
        ]

        // ═══════════════════════════════════════════════════════════════
        // Row 2: QWERTY Row
        // tab Q W E R T Y U I O P [ ] \
        // ═══════════════════════════════════════════════════════════════
        let row2: [Key] = [
            Key(keyCode: 48, label: "tab", width: 1.58, symbolName: "arrow.right.to.line"),
            Key(keyCode: 12, label: "Q"),
            Key(keyCode: 13, label: "W"),
            Key(keyCode: 14, label: "E"),
            Key(keyCode: 15, label: "R"),
            Key(keyCode: 17, label: "T"),
            Key(keyCode: 16, label: "Y"),
            Key(keyCode: 32, label: "U"),
            Key(keyCode: 34, label: "I"),
            Key(keyCode: 31, label: "O"),
            Key(keyCode: 35, label: "P"),
            Key(keyCode: 33, label: "[", secondaryLabel: "{"),
            Key(keyCode: 30, label: "]", secondaryLabel: "}"),
            Key(keyCode: 42, label: "\\", secondaryLabel: "|")
        ]

        // ═══════════════════════════════════════════════════════════════
        // Row 3: Home Row
        // caps lock A S D F G H J K L ; ' return
        // ═══════════════════════════════════════════════════════════════
        let row3: [Key] = [
            Key(keyCode: 57, label: "caps lock", width: 1.88, isModifier: true, symbolName: "capslock"),
            Key(keyCode: 0, label: "A"),
            Key(keyCode: 1, label: "S"),
            Key(keyCode: 2, label: "D"),
            Key(keyCode: 3, label: "F"),
            Key(keyCode: 5, label: "G"),
            Key(keyCode: 4, label: "H"),
            Key(keyCode: 38, label: "J"),
            Key(keyCode: 40, label: "K"),
            Key(keyCode: 37, label: "L"),
            Key(keyCode: 41, label: ";", secondaryLabel: ":"),
            Key(keyCode: 39, label: "'", secondaryLabel: "\""),
            Key(keyCode: 36, label: "return", width: 1.88, symbolName: "return")
        ]

        // ═══════════════════════════════════════════════════════════════
        // Row 4: Shift Row
        // shift Z X C V B N M , . / shift
        // ═══════════════════════════════════════════════════════════════
        let row4: [Key] = [
            Key(keyCode: 56, label: "shift", width: 2.45, isModifier: true, symbolName: "shift"),
            Key(keyCode: 6, label: "Z"),
            Key(keyCode: 7, label: "X"),
            Key(keyCode: 8, label: "C"),
            Key(keyCode: 9, label: "V"),
            Key(keyCode: 11, label: "B"),
            Key(keyCode: 45, label: "N"),
            Key(keyCode: 46, label: "M"),
            Key(keyCode: 43, label: ",", secondaryLabel: "<"),
            Key(keyCode: 47, label: ".", secondaryLabel: ">"),
            Key(keyCode: 44, label: "/", secondaryLabel: "?"),
            Key(keyCode: 60, label: "shift", width: 2.45, isModifier: true, symbolName: "shift")
        ]

        // ═══════════════════════════════════════════════════════════════
        // Row 5: Bottom Row - 底部行
        // fn control option command [空格] command option ← ↑↓ →
        // 箭头键采用倒 T 形布局
        // ═══════════════════════════════════════════════════════════════
        let row5: [Key] = [
            Key(keyCode: 63, label: "fn", width: 1.0, isModifier: true, symbolName: "globe"),
            Key(keyCode: 59, label: "control", width: 1.0, isModifier: true, symbolName: "control"),
            Key(keyCode: 58, label: "option", width: 1.0, isModifier: true, symbolName: "option"),
            Key(keyCode: 55, label: "command", width: 1.31, isModifier: true, symbolName: "command"),
            Key(keyCode: 49, label: "", width: 5.58),  // 空格键
            Key(keyCode: 54, label: "command", width: 1.31, isModifier: true, symbolName: "command"),
            Key(keyCode: 61, label: "option", width: 1.0, isModifier: true, symbolName: "option"),
            // 箭头键 - 倒 T 形布局（由 KeyboardView 特殊处理）
            Key(keyCode: 123, label: "◀", width: 1.0, symbolName: "arrowtriangle.left.fill"),
            Key(keyCode: 126, label: "▲", width: 1.0, height: 0.48, symbolName: "arrowtriangle.up.fill"),
            Key(keyCode: 125, label: "▼", width: 1.0, height: 0.48, symbolName: "arrowtriangle.down.fill"),
            Key(keyCode: 124, label: "▶", width: 1.0, symbolName: "arrowtriangle.right.fill")
        ]

        return KeyboardLayout(rows: [row0, row1, row2, row3, row4, row5], arrowKeyStyle: .halfHeight)
    }()
}
