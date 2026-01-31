import XCTest
@testable import CleanLock

@MainActor
final class CleaningStateTests: XCTestCase {

    func testInitialStateIsIdle() {
        let manager = CleaningStateManager()
        XCTAssertEqual(manager.state, .idle)
    }

    func testStartCleaningTransitionsToCleaningState() {
        let manager = CleaningStateManager()
        manager.startCleaning()

        if case .cleaning(let keys) = manager.state {
            XCTAssertTrue(keys.isEmpty)
        } else {
            XCTFail("Expected cleaning state")
        }
    }

    func testMarkKeyAsCleanedAddsToSet() {
        let manager = CleaningStateManager()
        manager.startCleaning()
        manager.markKeyCleaned(keyCode: 53) // esc

        if case .cleaning(let keys) = manager.state {
            XCTAssertTrue(keys.contains(53))
        } else {
            XCTFail("Expected cleaning state")
        }
    }

    func testProgressCalculation() {
        let manager = CleaningStateManager()
        manager.startCleaning()

        XCTAssertEqual(manager.progress, 0.0)

        manager.markKeyCleaned(keyCode: 53)
        manager.markKeyCleaned(keyCode: 18)

        XCTAssertEqual(manager.cleanedCount, 2)
        // Use actual total keys count from the layout (excludes placeholder keys)
        let totalKeys = Double(KeyboardLayout.macBook.allKeys.count)
        XCTAssertEqual(manager.progress, 2.0 / totalKeys, accuracy: 0.001)
    }

    func testAllKeysCleanedTransitionsToCompleted() {
        let manager = CleaningStateManager()
        manager.startCleaning()

        for key in KeyboardLayout.macBook.allKeys {
            manager.markKeyCleaned(keyCode: key.keyCode)
        }

        XCTAssertEqual(manager.state, .completed)
    }

    func testResetCleaning() {
        let manager = CleaningStateManager()
        manager.startCleaning()
        manager.markKeyCleaned(keyCode: 53)
        manager.reset()

        XCTAssertEqual(manager.state, .idle)
    }

    func testIsKeyCleanedCheck() {
        let manager = CleaningStateManager()
        manager.startCleaning()

        XCTAssertFalse(manager.isKeyCleaned(keyCode: 53))
        manager.markKeyCleaned(keyCode: 53)
        XCTAssertTrue(manager.isKeyCleaned(keyCode: 53))
    }
}
