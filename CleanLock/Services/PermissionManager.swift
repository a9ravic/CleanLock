import Foundation
import AppKit
import Combine

@MainActor
final class PermissionManager: ObservableObject {
    @Published private(set) var hasAccessibilityPermission: Bool = false

    // 使用 nonisolated(unsafe) 允许在 deinit 中安全访问
    // Timer.invalidate() 是线程安全的
    nonisolated(unsafe) private var timer: Timer?

    init() {
        checkPermission()
    }

    func checkPermission() {
        hasAccessibilityPermission = AXIsProcessTrusted()
    }

    func openAccessibilitySettings() {
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
        NSWorkspace.shared.open(url)
    }

    func startMonitoringPermission() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.checkPermission()
            }
        }
    }

    func stopMonitoringPermission() {
        timer?.invalidate()
        timer = nil
    }

    deinit {
        timer?.invalidate()
    }
}
