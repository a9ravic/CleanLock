import Foundation

struct Key: Identifiable, Equatable, Hashable {
    let id: UUID = UUID()
    let keyCode: UInt16
    let label: String
    let width: CGFloat
    let isModifier: Bool
    let isPlaceholder: Bool  // 占位符，不需要清洁

    init(keyCode: UInt16, label: String, width: CGFloat = 1.0, isModifier: Bool = false, isPlaceholder: Bool = false) {
        self.keyCode = keyCode
        self.label = label
        self.width = width
        self.isModifier = isModifier
        self.isPlaceholder = isPlaceholder
    }

    /// 创建占位符键（用于无法拦截的功能键位置）
    static func placeholder(width: CGFloat = 1.0) -> Key {
        Key(keyCode: UInt16.max, label: "", width: width, isPlaceholder: true)
    }

    static func == (lhs: Key, rhs: Key) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct KeyboardLayout {
    let rows: [[Key]]

    /// 所有需要清洁的键（排除占位符）
    var allKeys: [Key] {
        rows.flatMap { $0 }.filter { !$0.isPlaceholder }
    }

    static let macBook: KeyboardLayout = {
        // Row 0: Function row - esc + F1-F2 + placeholders + F7-F12
        // F3-F6 无法通过 CGEvent 拦截，使用占位符保持布局
        let row0: [Key] = [
            Key(keyCode: 53, label: "esc"),
            Key(keyCode: 122, label: "F1"),
            Key(keyCode: 120, label: "F2"),
            Key.placeholder(),  // F3 位置
            Key.placeholder(),  // F4 位置
            Key.placeholder(),  // F5 位置
            Key.placeholder(),  // F6 位置
            Key(keyCode: 98, label: "F7"),
            Key(keyCode: 100, label: "F8"),
            Key(keyCode: 101, label: "F9"),
            Key(keyCode: 109, label: "F10"),
            Key(keyCode: 103, label: "F11"),
            Key(keyCode: 111, label: "F12")
        ]

        // Row 1: Number row (14 keys) - ` + 1-0 + - + = + delete
        let row1: [Key] = [
            Key(keyCode: 50, label: "`"),
            Key(keyCode: 18, label: "1"),
            Key(keyCode: 19, label: "2"),
            Key(keyCode: 20, label: "3"),
            Key(keyCode: 21, label: "4"),
            Key(keyCode: 23, label: "5"),
            Key(keyCode: 22, label: "6"),
            Key(keyCode: 26, label: "7"),
            Key(keyCode: 28, label: "8"),
            Key(keyCode: 25, label: "9"),
            Key(keyCode: 29, label: "0"),
            Key(keyCode: 27, label: "-"),
            Key(keyCode: 24, label: "="),
            Key(keyCode: 51, label: "delete", width: 1.5)
        ]

        // Row 2: QWERTY row (14 keys) - tab + Q-P + [ + ] + \
        let row2: [Key] = [
            Key(keyCode: 48, label: "tab", width: 1.5),
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
            Key(keyCode: 33, label: "["),
            Key(keyCode: 30, label: "]"),
            Key(keyCode: 42, label: "\\")
        ]

        // Row 3: Home row (13 keys) - caps + ASDFGHJKL;' + return
        let row3: [Key] = [
            Key(keyCode: 57, label: "caps", width: 1.75, isModifier: true),
            Key(keyCode: 0, label: "A"),
            Key(keyCode: 1, label: "S"),
            Key(keyCode: 2, label: "D"),
            Key(keyCode: 3, label: "F"),
            Key(keyCode: 5, label: "G"),
            Key(keyCode: 4, label: "H"),
            Key(keyCode: 38, label: "J"),
            Key(keyCode: 40, label: "K"),
            Key(keyCode: 37, label: "L"),
            Key(keyCode: 41, label: ";"),
            Key(keyCode: 39, label: "'"),
            Key(keyCode: 36, label: "return", width: 1.75)
        ]

        // Row 4: Shift row (12 keys) - shift + ZXCVBNM,./ + shift
        let row4: [Key] = [
            Key(keyCode: 56, label: "shift", width: 2.25, isModifier: true),
            Key(keyCode: 6, label: "Z"),
            Key(keyCode: 7, label: "X"),
            Key(keyCode: 8, label: "C"),
            Key(keyCode: 9, label: "V"),
            Key(keyCode: 11, label: "B"),
            Key(keyCode: 45, label: "N"),
            Key(keyCode: 46, label: "M"),
            Key(keyCode: 43, label: ","),
            Key(keyCode: 47, label: "."),
            Key(keyCode: 44, label: "/"),
            Key(keyCode: 60, label: "shift", width: 2.25, isModifier: true)
        ]

        // Row 5: Bottom row with arrows (10 keys)
        let row5: [Key] = [
            Key(keyCode: 63, label: "fn", isModifier: true),
            Key(keyCode: 59, label: "ctrl", width: 1.25, isModifier: true),
            Key(keyCode: 58, label: "opt", width: 1.25, isModifier: true),
            Key(keyCode: 55, label: "cmd", width: 1.5, isModifier: true),
            Key(keyCode: 49, label: "space", width: 5.0),
            Key(keyCode: 54, label: "cmd", width: 1.5, isModifier: true),
            Key(keyCode: 123, label: "←"),
            Key(keyCode: 126, label: "↑"),
            Key(keyCode: 125, label: "↓"),
            Key(keyCode: 124, label: "→")
        ]

        return KeyboardLayout(rows: [row0, row1, row2, row3, row4, row5])
    }()
}
