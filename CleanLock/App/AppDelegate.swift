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
    private let hotKeyManager = HotKeyManager()
    private let keyInterceptor = KeyInterceptor()

    private var cancellables = Set<AnyCancellable>()
    private var windowResignObserver: NSObjectProtocol?

    private static let hasLaunchedBeforeKey = "hasLaunchedBefore"

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusItem()
        setupHotKey()

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

    func applicationWillTerminate(_ notification: Notification) {
        // 清理热键注册
        hotKeyManager.stop()
        // 清理键盘拦截
        keyInterceptor.stop()
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
            contentRect: NSRect(x: 0, y: 0, width: 420, height: 680),
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
        showCleaningWindow()
    }

    private func showCleaningWindow() {
        guard cleaningWindow == nil else { return }

        // 保存当前系统状态（音量、亮度等）
        SystemStateManager.shared.saveCurrentState()

        let contentView = CleaningView(
            stateManager: stateManager,
            onExit: { [weak self] in
                self?.endCleaning()
            }
        )

        // 使用 KeyableWindow 替代 NSWindow，确保 borderless 窗口可以成为 key window
        let window = KeyableWindow(
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
        window.isReleasedWhenClosed = false

        cleaningWindow = window
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)

        // 监听窗口失去焦点事件，自动恢复焦点
        // 这确保了在沙盒模式下，键盘事件始终发送到清洁窗口
        windowResignObserver = NotificationCenter.default.addObserver(
            forName: NSWindow.didResignKeyNotification,
            object: window,
            queue: .main
        ) { [weak self, weak window] _ in
            guard let self = self, let window = window else { return }
            // 确保清洁窗口仍然存在且未在退出状态
            if self.cleaningWindow != nil && self.stateManager.state != .exiting {
                // 延迟一小段时间后恢复焦点，避免与用户操作冲突
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if self.cleaningWindow != nil {
                        window.makeKeyAndOrderFront(nil)
                        NSApp.activate(ignoringOtherApps: true)
                    }
                }
            }
        }

        setupKeyInterceptor()
        // 根据是否有辅助功能权限决定是否自动跳过系统保留键
        stateManager.startCleaning(hasFullAccess: keyInterceptor.hasFullAccess)
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

        // 请求辅助功能权限（如果用户授权，可以拦截所有按键包括 F3-F6）
        _ = keyInterceptor.start(requestPermission: true)
    }

    func endCleaning() {
        keyInterceptor.stop()
        stateManager.setExiting()

        // 恢复清洁前的系统状态（音量、亮度等）
        SystemStateManager.shared.restoreState()

        // 移除窗口焦点观察者
        if let observer = windowResignObserver {
            NotificationCenter.default.removeObserver(observer)
            windowResignObserver = nil
        }

        guard let window = cleaningWindow else {
            stateManager.reset()
            return
        }

        cleaningWindow = nil

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.3
            window.animator().alphaValue = 0
        } completionHandler: { [weak self] in
            DispatchQueue.main.async {
                window.orderOut(nil)
                self?.stateManager.reset()
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
        window.title = String(localized: "welcome_title")
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
