import Foundation

struct Key: Identifiable, Equatable, Hashable {
    let id: UUID = UUID()
    let keyCode: UInt16
    let label: String
    let width: CGFloat
    let isModifier: Bool

    init(keyCode: UInt16, label: String, width: CGFloat = 1.0, isModifier: Bool = false) {
        self.keyCode = keyCode
        self.label = label
        self.width = width
        self.isModifier = isModifier
    }

    static func == (lhs: Key, rhs: Key) -> Bool {
        lhs.keyCode == rhs.keyCode
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(keyCode)
    }
}

struct KeyboardLayout {
    let rows: [[Key]]

    var allKeys: [Key] {
        rows.flatMap { $0 }
    }

    static let macBook: KeyboardLayout = {
        // Row 0: Function row (14 keys) - esc + F1-F12 + power/eject
        let row0: [Key] = [
            Key(keyCode: 53, label: "esc"),
            Key(keyCode: 122, label: "F1"),
            Key(keyCode: 120, label: "F2"),
            Key(keyCode: 99, label: "F3"),
            Key(keyCode: 118, label: "F4"),
            Key(keyCode: 96, label: "F5"),
            Key(keyCode: 97, label: "F6"),
            Key(keyCode: 98, label: "F7"),
            Key(keyCode: 100, label: "F8"),
            Key(keyCode: 101, label: "F9"),
            Key(keyCode: 109, label: "F10"),
            Key(keyCode: 103, label: "F11"),
            Key(keyCode: 111, label: "F12"),
            Key(keyCode: 107, label: "F15")
        ]

        // Row 1: Number row (15 keys) - ` + 1-0 + - + = + delete
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
            Key(keyCode: 51, label: "delete", width: 1.5),
            Key(keyCode: 117, label: "⌦")
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

        // Row 3: Home and Shift rows combined (24 keys)
        let row3: [Key] = [
            // Home row keys
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
            Key(keyCode: 36, label: "return", width: 1.75),
            // Shift row keys
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

        // Row 4: Bottom row with arrows (10 keys)
        let row4: [Key] = [
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

        return KeyboardLayout(rows: [row0, row1, row2, row3, row4])
    }()
}
