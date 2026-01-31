import XCTest
@testable import CleanLock

final class KeyboardLayoutTests: XCTestCase {

    func testMacBookLayoutHasCorrectKeyCount() {
        let layout = KeyboardLayout.macBook
        // Total keys in layout minus 5 placeholder keys (F3-F6 + TouchID which are system intercepted)
        // Row 0: 14 keys (esc, F1, F2, placeholder x4, F7-F12, placeholder TouchID) -> 9 cleanable
        // Row 1: 14 keys
        // Row 2: 14 keys
        // Row 3: 13 keys
        // Row 4: 12 keys
        // Row 5: 11 keys
        // Total: 14+14+14+13+12+11 = 78 keys in rows, minus 5 placeholders = 73 cleanable keys
        let totalRowKeys = layout.rows.flatMap { $0 }.count
        let placeholderCount = layout.rows.flatMap { $0 }.filter { $0.isPlaceholder }.count
        XCTAssertEqual(placeholderCount, 5, "Should have 5 placeholder keys (F3-F6 + TouchID)")
        XCTAssertEqual(layout.allKeys.count, totalRowKeys - placeholderCount, "allKeys should exclude placeholders")
    }

    func testKeyHasValidProperties() {
        let layout = KeyboardLayout.macBook
        let escKey = layout.allKeys.first { $0.label == "esc" }

        XCTAssertNotNil(escKey)
        XCTAssertEqual(escKey?.keyCode, 53)
        XCTAssertGreaterThan(escKey?.width ?? 0, 0)
    }

    func testAllKeysHaveUniqueKeyCodes() {
        let layout = KeyboardLayout.macBook
        let keyCodes = layout.allKeys.map { $0.keyCode }
        let uniqueKeyCodes = Set(keyCodes)

        XCTAssertEqual(keyCodes.count, uniqueKeyCodes.count)
    }

    func testRowsAreOrganizedCorrectly() {
        let layout = KeyboardLayout.macBook

        // Layout has 6 rows: function row (0), number row (1), QWERTY (2), home (3), shift (4), bottom (5)
        XCTAssertEqual(layout.rows.count, 6)
        XCTAssertEqual(layout.rows[0].count, 14) // Function row (esc + F1-F12 + TouchID placeholder)
        XCTAssertEqual(layout.rows[1].count, 14) // Number row
        XCTAssertEqual(layout.rows[2].count, 14) // QWERTY row
        XCTAssertEqual(layout.rows[3].count, 13) // Home row
        XCTAssertEqual(layout.rows[4].count, 12) // Shift row
        XCTAssertEqual(layout.rows[5].count, 11) // Bottom row with arrows
    }

    func testPlaceholderKeysAreNotIncludedInAllKeys() {
        let layout = KeyboardLayout.macBook
        let placeholders = layout.allKeys.filter { $0.isPlaceholder }
        XCTAssertEqual(placeholders.count, 0, "allKeys should not contain placeholder keys")
    }

    func testFunctionKeysAreMarkedCorrectly() {
        let layout = KeyboardLayout.macBook
        let functionKeys = layout.allKeys.filter { $0.isFunctionKey }

        // F1, F2, F7-F12, esc = 9 function keys (F3-F6 are placeholders)
        XCTAssertEqual(functionKeys.count, 9, "Should have 9 function keys (F3-F6 are system intercepted)")
    }
}
