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

    /// 每次进入 completed 状态时递增，用于强制 SwiftUI 重建 CompletionView
    @Published private(set) var completionId: Int = 0

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
        print("🟣 [StateManager] startCleaning() called")
        state = .cleaning(Set())
    }

    func markKeyCleaned(keyCode: UInt16) {
        guard case .cleaning(var keys) = state else { return }
        guard allKeyCodes.contains(keyCode) else { return }

        keys.insert(keyCode)

        if keys.count == totalKeys {
            completionId += 1  // 递增 ID，强制 SwiftUI 重建 CompletionView
            print("🟣 [StateManager] All keys cleaned! Setting state to .completed, completionId=\(completionId)")
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
        print("🟣 [StateManager] setExiting() called, state changing from \(state) to .exiting")
        state = .exiting
    }

    func reset() {
        print("🟣 [StateManager] reset() called, state changing from \(state) to .idle")
        state = .idle
    }
}
