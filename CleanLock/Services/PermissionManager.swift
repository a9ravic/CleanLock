import Foundation
import AppKit
import Combine

@MainActor
final class PermissionManager: ObservableObject {
    @Published private(set) var hasAccessibilityPermission: Bool = false

    private var timer: Timer?

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
}
