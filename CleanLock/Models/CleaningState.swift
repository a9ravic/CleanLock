import Foundation
import Combine

// MARK: - Cleaning State (简化版，不包含关联值)

enum CleaningState: Equatable {
    case idle
    case cleaning
    case completed
    case exiting
}

// MARK: - Cleaning State Manager

@MainActor
final class CleaningStateManager: ObservableObject {
    /// 清洁阶段状态（不包含已清洁键集合，避免频繁触发全局重绘）
    @Published private(set) var state: CleaningState = .idle

    /// 已清洁的键码集合（独立发布，仅影响依赖它的视图）
    @Published private(set) var cleanedKeys: Set<UInt16> = []

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
        cleanedKeys.count
    }

    var progress: Double {
        guard totalKeys > 0 else { return 0 }
        return Double(cleanedKeys.count) / Double(totalKeys)
    }

    var isCleaning: Bool {
        state == .cleaning
    }

    func startCleaning() {
        cleanedKeys = []
        state = .cleaning
    }

    func markKeyCleaned(keyCode: UInt16) {
        guard state == .cleaning else { return }
        guard allKeyCodes.contains(keyCode) else { return }

        // 只有新键才更新，避免重复触发
        guard !cleanedKeys.contains(keyCode) else { return }

        cleanedKeys.insert(keyCode)

        if cleanedKeys.count == totalKeys {
            completionId += 1
            state = .completed
        }
    }

    func isKeyCleaned(keyCode: UInt16) -> Bool {
        cleanedKeys.contains(keyCode)
    }

    func setExiting() {
        state = .exiting
    }

    func reset() {
        cleanedKeys = []
        state = .idle
    }
}
