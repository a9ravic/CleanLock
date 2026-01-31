import XCTest
@testable import CleanLock

final class KeyboardLayoutTests: XCTestCase {

    func testMacBookLayoutHas78Keys() {
        let layout = KeyboardLayout.macBook
        XCTAssertEqual(layout.allKeys.count, 78)
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

        XCTAssertEqual(layout.rows.count, 5)
        XCTAssertEqual(layout.rows[0].count, 14) // Top row
        XCTAssertEqual(layout.rows[4].count, 10) // Bottom row with arrows
    }
}
