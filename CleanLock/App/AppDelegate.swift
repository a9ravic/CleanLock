import AppKit
import SwiftUI
import Combine

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    private var mainWindow: NSWindow?
    private var cleaningWindow: NSWindow?
    private var welcomeWindow: NSWindow?

    private let stateManager = CleaningStateManager()
    private let permissionManager = PermissionManager()
    private let hotKeyManager = HotKeyManager()
    private let keyInterceptor = KeyInterceptor()

    private var cancellables = Set<AnyCancellable>()

    private static let hasLaunchedBeforeKey = "hasLaunchedBefore"

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusItem()
        setupHotKey()
        setupPermissionObserver()

        let hasLaunchedBefore = UserDefaults.standard.bool(forKey: Self.hasLaunchedBeforeKey)
        if hasLaunchedBefore {
            showMainWindow()
        } else {
            showWelcomeWindow()
        }
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            showMainWindow()
        }
        return true
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusItem?.button {
            if let image = NSImage(systemSymbolName: "keyboard.fill", accessibilityDescription: "CleanLock") {
                image.isTemplate = true
                button.image = image
            } else {
                button.title = "⌨️"
            }
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
                onOpenSettings: { [weak self] in
                    self?.popover?.close()
                    self?.showMainWindow()
                },
                onOpenWelcome: { [weak self] in
                    self?.popover?.close()
                    self?.showWelcomeWindow()
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
            .dropFirst() // 忽略初始值
            .sink { [weak self] hasPermission in
                guard let self = self else { return }
                if hasPermission {
                    // 权限已获取，停止监控
                    self.permissionManager.stopMonitoringPermission()
                    // 如果当前没有清洁窗口，自动开始清洁
                    if self.cleaningWindow == nil {
                        self.showCleaningWindow()
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

    // MARK: - Main Window

    func showMainWindow() {
        if let mainWindow = mainWindow {
            mainWindow.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let contentView = MainWindowView(
            hotKeyManager: hotKeyManager,
            onStartCleaning: { [weak self] in
                self?.startCleaning()
            }
        )

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 520),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.title = "CleanLock"
        window.center()
        window.contentView = NSHostingView(rootView: contentView)
        window.isReleasedWhenClosed = false

        mainWindow = window
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    // MARK: - Cleaning

    func startCleaning() {
        guard cleaningWindow == nil else { return }

        permissionManager.checkPermission()

        // 如果没有权限，先请求权限
        if !permissionManager.hasAccessibilityPermission {
            requestAccessibilityPermission()
            return
        }

        showCleaningWindow()
    }

    private func requestAccessibilityPermission() {
        // 使用 AXIsProcessTrustedWithOptions 触发系统权限弹窗
        // 系统弹窗会引导用户去系统设置授权，无需额外弹窗
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        let trusted = AXIsProcessTrustedWithOptions(options)

        if trusted {
            showCleaningWindow()
        } else {
            // 开始监控权限变化，用户授权后自动开始清洁
            permissionManager.startMonitoringPermission()
        }
    }

    private func showCleaningWindow() {
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

        stateManager.startCleaning()
        setupKeyInterceptor()
    }

    private func setupKeyInterceptor() {
        keyInterceptor.onKeyPress = { [weak self] keyCode in
            Task { @MainActor in
                if keyCode == 53 {
                    self?.stateManager.isEscPressed = true
                }
                self?.stateManager.markKeyCleaned(keyCode: keyCode)
            }
        }

        keyInterceptor.onKeyUp = { [weak self] keyCode in
            Task { @MainActor in
                if keyCode == 53 {
                    self?.stateManager.isEscPressed = false
                }
            }
        }

        _ = keyInterceptor.start()
    }

    func endCleaning() {
        keyInterceptor.stop()
        stateManager.reset()

        let window = cleaningWindow
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.3
            window?.animator().alphaValue = 0
        } completionHandler: { [weak self] in
            Task { @MainActor in
                self?.cleaningWindow?.close()
                self?.cleaningWindow = nil
            }
        }
    }

    // MARK: - Welcome Window

    private func showWelcomeWindow() {
        if let welcomeWindow = welcomeWindow {
            welcomeWindow.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let contentView = WelcomeView(onDismiss: { [weak self] in
            self?.closeWelcomeWindow()
        })

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 420, height: 480),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "欢迎使用 CleanLock"
        window.center()
        window.contentView = NSHostingView(rootView: contentView)
        window.isReleasedWhenClosed = false

        welcomeWindow = window
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    private func closeWelcomeWindow() {
        UserDefaults.standard.set(true, forKey: Self.hasLaunchedBeforeKey)
        welcomeWindow?.close()
        welcomeWindow = nil
        showMainWindow()
    }
}
