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

    // MARK: - MacBook 键盘布局（参考 CSS 实现 1:1 还原）

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │  CSS 参考比例（基于 29px 标准键）:                                     │
    // │  - 标准键: 29px = 1.0u                                               │
    // │  - 间距: 5px ≈ 0.172u（固定间距）                                      │
    // │  - 功能键: 14个等宽，高度 0.52                                         │
    // │  - Tab/Delete: 45px ≈ 1.55u                                          │
    // │  - Caps/Return: 55-73px ≈ 1.9u                                       │
    // │  - Shift: 73px ≈ 2.52u                                               │
    // │  - Space: 173px ≈ 5.97u                                              │
    // │  - Command: 37px ≈ 1.28u                                             │
    // │                                                                      │
    // │  每行 15 个单位槽位（14键+1额外），确保矩形对齐                          │
    // └─────────────────────────────────────────────────────────────────────┘

    static let macBook: KeyboardLayout = {
        // ═══════════════════════════════════════════════════════════════
        // Row 0: Function Row - 功能键行
        // 14 个等宽功能键（含右侧电源键/Touch ID 占位）
        // 与数字行对齐：14键 × 1.0 + 13间距
        // ═══════════════════════════════════════════════════════════════
        let row0: [Key] = [
            Key(keyCode: 53, label: "esc", width: 1.0, isFunctionKey: true),
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
            Key.placeholder(width: 1.0),  // 电源键/Touch ID 占位
        ]

        // ═══════════════════════════════════════════════════════════════
        // Row 1: Number Row - 数字键行
        // 14键，与功能键行对齐：13×1.0 + delete(1.0) = 14.0
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
            Key(keyCode: 51, label: "delete", width: 1.0, symbolName: "delete.left")
        ]

        // ═══════════════════════════════════════════════════════════════
        // Row 2: QWERTY Row
        // 14键：tab(1.0) + 13×1.0 = 14.0
        // ═══════════════════════════════════════════════════════════════
        let row2: [Key] = [
            Key(keyCode: 48, label: "tab", width: 1.0, symbolName: "arrow.right.to.line"),
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
        // 13键：caps(1.5) + 11×1.0 + return(1.5) = 14.0
        // ═══════════════════════════════════════════════════════════════
        let row3: [Key] = [
            Key(keyCode: 57, label: "caps lock", width: 1.5, isModifier: true, symbolName: "capslock"),
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
            Key(keyCode: 36, label: "return", width: 1.5, symbolName: "return")
        ]

        // ═══════════════════════════════════════════════════════════════
        // Row 4: Shift Row
        // 12键：shift(2.0) + 10×1.0 + shift(2.0) = 14.0
        // ═══════════════════════════════════════════════════════════════
        let row4: [Key] = [
            Key(keyCode: 56, label: "shift", width: 2.0, isModifier: true, symbolName: "shift"),
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
            Key(keyCode: 60, label: "shift", width: 2.0, isModifier: true, symbolName: "shift")
        ]

        // ═══════════════════════════════════════════════════════════════
        // Row 5: Bottom Row - 底部行
        // 10个水平位置：fn(1.0) + ctrl(1.0) + opt(1.0) + cmd(1.25) + space(4.5)
        //              + cmd(1.25) + opt(1.0) + arrows(3×1.0) = 14.0
        // 所有箭头键都是半高
        // ═══════════════════════════════════════════════════════════════
        let row5: [Key] = [
            Key(keyCode: 63, label: "fn", width: 1.0, isModifier: true, symbolName: "globe"),
            Key(keyCode: 59, label: "control", width: 1.0, isModifier: true, symbolName: "control"),
            Key(keyCode: 58, label: "option", width: 1.0, isModifier: true, symbolName: "option"),
            Key(keyCode: 55, label: "command", width: 1.25, isModifier: true, symbolName: "command"),
            Key(keyCode: 49, label: "", width: 4.5),  // 空格键
            Key(keyCode: 54, label: "command", width: 1.25, isModifier: true, symbolName: "command"),
            Key(keyCode: 61, label: "option", width: 1.0, isModifier: true, symbolName: "option"),
            // 箭头键 - 所有箭头都是半高（上下堆叠，左右并排）
            Key(keyCode: 123, label: "◀", width: 1.0, height: 0.5, symbolName: "arrowtriangle.left.fill"),
            Key(keyCode: 126, label: "▲", width: 1.0, height: 0.5, symbolName: "arrowtriangle.up.fill"),
            Key(keyCode: 125, label: "▼", width: 1.0, height: 0.5, symbolName: "arrowtriangle.down.fill"),
            Key(keyCode: 124, label: "▶", width: 1.0, height: 0.5, symbolName: "arrowtriangle.right.fill")
        ]

        return KeyboardLayout(rows: [row0, row1, row2, row3, row4, row5], arrowKeyStyle: .halfHeight)
    }()
}
