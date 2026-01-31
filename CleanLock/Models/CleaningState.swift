import Foundation
import Combine

enum CleaningState: Equatable {
    case idle
    case cleaning(Set<UInt16>)
    case completed
    case exiting

    static func == (lhs: CleaningState, rhs: CleaningState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle): return true
        case (.completed, .completed): return true
        case (.exiting, .exiting): return true
        case (.cleaning(let a), .cleaning(let b)): return a == b
        default: return false
        }
    }
}

@MainActor
final class CleaningStateManager: ObservableObject {
    @Published private(set) var state: CleaningState = .idle
    @Published var isEscPressed: Bool = false

    let totalKeys: Int
    private let allKeyCodes: Set<UInt16>

    init(layout: KeyboardLayout = .macBook) {
        self.totalKeys = layout.allKeys.count
        self.allKeyCodes = Set(layout.allKeys.map { $0.keyCode })
    }

    var cleanedCount: Int {
        if case .cleaning(let keys) = state {
            return keys.count
        }
        return 0
    }

    var progress: Double {
        Double(cleanedCount) / Double(totalKeys)
    }

    func startCleaning() {
        state = .cleaning(Set())
    }

    func markKeyCleaned(keyCode: UInt16) {
        guard case .cleaning(var keys) = state else { return }
        guard allKeyCodes.contains(keyCode) else { return }

        keys.insert(keyCode)

        if keys.count == totalKeys {
            state = .completed
        } else {
            state = .cleaning(keys)
        }
    }

    func isKeyCleaned(keyCode: UInt16) -> Bool {
        if case .cleaning(let keys) = state {
            return keys.contains(keyCode)
        }
        return false
    }

    func setExiting() {
        state = .exiting
    }

    func reset() {
        state = .idle
    }
}
