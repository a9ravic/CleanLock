import AppKit
import SwiftUI
import Combine

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    private var cleaningWindow: NSWindow?

    private let stateManager = CleaningStateManager()
    private let permissionManager = PermissionManager()
    private let hotKeyManager = HotKeyManager()
    private let keyInterceptor = KeyInterceptor()

    private var cancellables = Set<AnyCancellable>()

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusItem()
        setupHotKey()
        setupPermissionObserver()
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "keyboard.fill", accessibilityDescription: "CleanLock")
            button.action = #selector(togglePopover)
            button.target = self
        }

        popover = NSPopover()
        popover?.behavior = .transient
        popover?.contentViewController = NSHostingController(
            rootView: MenuBarView(
                hotKeyManager: hotKeyManager,
                onStartCleaning: { [weak self] in
                    self?.popover?.close()
                    self?.startCleaning()
                },
                onQuit: {
                    NSApplication.shared.terminate(nil)
                }
            )
        )
    }

    private func setupHotKey() {
        hotKeyManager.loadHotKey()
        hotKeyManager.onHotKeyPressed = { [weak self] in
            self?.startCleaning()
        }
        hotKeyManager.start()
    }

    private func setupPermissionObserver() {
        permissionManager.$hasAccessibilityPermission
            .sink { [weak self] hasPermission in
                if hasPermission, self?.stateManager.state == .idle {
                    if self?.cleaningWindow != nil {
                        self?.stateManager.startCleaning()
                        _ = self?.keyInterceptor.start()
                    }
                }
            }
            .store(in: &cancellables)
    }

    @objc private func togglePopover() {
        guard let button = statusItem?.button else { return }

        if let popover = popover, popover.isShown {
            popover.close()
        } else {
            popover?.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }

    func startCleaning() {
        guard cleaningWindow == nil else { return }

        permissionManager.checkPermission()

        let contentView = CleaningView(
            stateManager: stateManager,
            permissionManager: permissionManager,
            onExit: { [weak self] in
                self?.endCleaning()
            }
        )

        let window = NSWindow(
            contentRect: NSScreen.main?.frame ?? .zero,
            styleMask: [.borderless, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window.level = .screenSaver
        window.backgroundColor = .clear
        window.isOpaque = false
        window.hasShadow = false
        window.contentView = NSHostingView(rootView: contentView)
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

        cleaningWindow = window
        window.makeKeyAndOrderFront(nil)

        if permissionManager.hasAccessibilityPermission {
            stateManager.startCleaning()
            setupKeyInterceptor()
        }
    }

    private func setupKeyInterceptor() {
        keyInterceptor.onKeyPress = { [weak self] keyCode in
            Task { @MainActor in
                // Handle Esc key for exit
                if keyCode == 53 {
                    // Let CleaningView handle Esc hold logic
                    // For now, just mark as cleaned
                }
                self?.stateManager.markKeyCleaned(keyCode: keyCode)
            }
        }
        _ = keyInterceptor.start()
    }

    func endCleaning() {
        keyInterceptor.stop()
        stateManager.reset()

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.3
            cleaningWindow?.animator().alphaValue = 0
        } completionHandler: { [weak self] in
            self?.cleaningWindow?.close()
            self?.cleaningWindow = nil
        }
    }
}
