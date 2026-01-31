import Foundation
import CoreGraphics
import AppKit

// MARK: - Event Constants

private enum EventConstants {
    /// NX_SYSDEFINED event type for special function keys (brightness, volume, etc.)
    static let systemDefinedEventType: UInt32 = 14
    /// Subtype for auxiliary control button events
    static let auxiliaryControlSubtype: Int16 = 8
    /// Key down state in NX_SYSDEFINED events
    static let keyDownState = 0x0A
    /// Key up state in NX_SYSDEFINED events
    static let keyUpState = 0x0B
}

// MARK: - Key Interceptor Mode

enum KeyInterceptorMode {
    case eventTap       // CGEvent Tap - 需要辅助功能权限，可拦截所有按键
    case localMonitor   // NSEvent Local Monitor - 无需权限，但无法拦截系统功能键
}

// MARK: - Key Interceptor

/// 混合键盘拦截器
/// - 如果有辅助功能权限：使用 CGEvent Tap（可拦截 F3-F6 等系统功能键）
/// - 如果没有权限：使用 Local Monitor（沙盒兼容，但系统功能键会自动跳过）
final class KeyInterceptor {

    // MARK: - Properties

    private var mode: KeyInterceptorMode = .localMonitor

    // CGEvent Tap 相关
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var retainedSelf: Unmanaged<KeyInterceptor>?
    private var tapReenableCount: Int = 0
    private var lastReenableTime: Date?
    private static let maxReenableAttempts = 5
    private static let reenableResetInterval: TimeInterval = 10.0

    // Local Monitor 相关
    private var localKeyDownMonitor: Any?
    private var localKeyUpMonitor: Any?
    private var localFlagsMonitor: Any?

    // 共享状态
    private var pressedModifiers: Set<UInt16> = []

    var onKeyPress: ((UInt16) -> Void)?
    var onKeyUp: ((UInt16) -> Void)?

    /// 当前运行模式
    var currentMode: KeyInterceptorMode {
        mode
    }

    var isRunning: Bool {
        eventTap != nil || localKeyDownMonitor != nil
    }

    /// 是否有辅助功能权限（可拦截所有按键）
    var hasFullAccess: Bool {
        AXIsProcessTrusted()
    }

    // MARK: - Public Methods

    /// 启动键盘拦截
    /// - Parameter requestPermission: 是否请求辅助功能权限（显示系统弹窗）
    /// - Returns: 是否成功启动
    @discardableResult
    func start(requestPermission: Bool = false) -> Bool {
        guard !isRunning else { return true }

        // 检查辅助功能权限
        if requestPermission {
            let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
            _ = AXIsProcessTrustedWithOptions(options)
        }

        // 1. 尝试使用辅助功能权限（完整拦截模式）
        if AXIsProcessTrusted() {
            if startEventTap() {
                mode = .eventTap
                #if DEBUG
                print("🎹 KeyInterceptor started in eventTap mode (full access)")
                #endif
                return true
            }
        }

        // 2. 回退到 Local Monitor（无需权限，但无法检测系统功能键）
        if startLocalMonitor() {
            mode = .localMonitor
            #if DEBUG
            print("🎹 KeyInterceptor started in localMonitor mode (limited)")
            #endif
            return true
        }

        return false
    }

    func stop() {
        stopEventTap()
        stopLocalMonitor()
        pressedModifiers.removeAll()
    }

    // MARK: - CGEvent Tap Implementation

    private func startEventTap() -> Bool {
        let eventMask = (1 << CGEventType.keyDown.rawValue)
            | (1 << CGEventType.keyUp.rawValue)
            | (1 << CGEventType.flagsChanged.rawValue)
            | (1 << EventConstants.systemDefinedEventType)

        let retained = Unmanaged.passRetained(self)

        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(eventMask),
            callback: { proxy, type, event, refcon in
                guard let refcon = refcon else { return Unmanaged.passRetained(event) }
                let interceptor = Unmanaged<KeyInterceptor>.fromOpaque(refcon).takeUnretainedValue()
                return interceptor.handleEventTap(proxy: proxy, type: type, event: event)
            },
            userInfo: retained.toOpaque()
        ) else {
            retained.release()
            return false
        }

        retainedSelf = retained
        eventTap = tap
        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)

        if let source = runLoopSource {
            CFRunLoopAddSource(CFRunLoopGetMain(), source, .commonModes)
            CGEvent.tapEnable(tap: tap, enable: true)
        }

        return true
    }

    private func stopEventTap() {
        if let tap = eventTap {
            CGEvent.tapEnable(tap: tap, enable: false)
            if let source = runLoopSource {
                CFRunLoopRemoveSource(CFRunLoopGetMain(), source, .commonModes)
            }
            CFMachPortInvalidate(tap)
        }

        retainedSelf?.release()
        retainedSelf = nil
        eventTap = nil
        runLoopSource = nil
        tapReenableCount = 0
        lastReenableTime = nil
    }

    private func handleEventTap(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent) -> Unmanaged<CGEvent>? {
        // Handle tap disabled events
        if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
            handleTapDisabled(type: type)
            return Unmanaged.passRetained(event)
        }

        // Handle NX_SYSDEFINED (special function keys)
        if type.rawValue == EventConstants.systemDefinedEventType {
            handleSystemDefinedEvent(event: event)
            return nil  // Block the event
        }

        let keyCode = UInt16(event.getIntegerValueField(.keyboardEventKeycode))

        switch type {
        case .keyDown:
            onKeyPress?(keyCode)
        case .keyUp:
            onKeyUp?(keyCode)
        case .flagsChanged:
            handleFlagsChangedEventTap(event: event, keyCode: keyCode)
        default:
            break
        }

        // Block the event
        return nil
    }

    private func handleTapDisabled(type: CGEventType) {
        let now = Date()

        if let lastTime = lastReenableTime,
           now.timeIntervalSince(lastTime) > Self.reenableResetInterval {
            tapReenableCount = 0
        }

        tapReenableCount += 1
        lastReenableTime = now

        if tapReenableCount > Self.maxReenableAttempts {
            return
        }

        if let tap = eventTap {
            CGEvent.tapEnable(tap: tap, enable: true)
        }
    }

    private func handleSystemDefinedEvent(event: CGEvent) {
        guard let nsEvent = NSEvent(cgEvent: event) else { return }
        guard nsEvent.subtype.rawValue == EventConstants.auxiliaryControlSubtype else { return }

        let data1 = nsEvent.data1
        let keyFlavor = (data1 & 0xFFFF0000) >> 16
        let keyState = (data1 & 0x0000FF00) >> 8
        let isKeyDown = keyState == EventConstants.keyDownState

        let flavorToKeyCode: [Int: UInt16] = [
            // F1-F2: 亮度控制
            3: 122,    // NX_KEYTYPE_BRIGHTNESS_DOWN -> F1
            2: 120,    // NX_KEYTYPE_BRIGHTNESS_UP -> F2
            // F3-F6: 系统功能键
            160: 99,   // Mission Control -> F3
            131: 118,  // Launchpad/Spotlight -> F4
            144: 96,   // Illumination Down (键盘背光) -> F5
            145: 97,   // Illumination Up -> F6
            // F7-F9: 媒体控制
            18: 98, 20: 98,   // PREVIOUS/REWIND -> F7
            16: 100,          // PLAY -> F8
            17: 101, 19: 101, // NEXT/FAST -> F9
            // F10-F12: 音量控制
            7: 109,    // MUTE -> F10
            1: 103,    // SOUND_DOWN -> F11
            0: 111,    // SOUND_UP -> F12
        ]

        if let keyCode = flavorToKeyCode[keyFlavor] {
            if isKeyDown {
                onKeyPress?(keyCode)
            } else {
                onKeyUp?(keyCode)
            }
        }
    }

    private func handleFlagsChangedEventTap(event: CGEvent, keyCode: UInt16) {
        let flags = event.flags

        let keyFlagMap: [(UInt16, CGEventFlags)] = [
            (56, .maskShift), (60, .maskShift),
            (59, .maskControl), (62, .maskControl),
            (58, .maskAlternate), (61, .maskAlternate),
            (55, .maskCommand), (54, .maskCommand),
            (57, .maskAlphaShift),
            (63, .maskSecondaryFn)
        ]

        for (code, flag) in keyFlagMap {
            if code == keyCode {
                if flags.contains(flag) || (code == 57 && flags.contains(.maskAlphaShift)) {
                    if !pressedModifiers.contains(code) {
                        pressedModifiers.insert(code)
                        onKeyPress?(code)
                    }
                } else {
                    if pressedModifiers.contains(code) {
                        pressedModifiers.remove(code)
                        onKeyUp?(code)
                    }
                }
                break
            }
        }
    }

    // MARK: - Local Monitor Implementation

    private func startLocalMonitor() -> Bool {
        localKeyDownMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            self?.onKeyPress?(event.keyCode)
            return nil
        }

        localKeyUpMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyUp) { [weak self] event in
            self?.onKeyUp?(event.keyCode)
            return nil
        }

        localFlagsMonitor = NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) { [weak self] event in
            self?.handleFlagsChangedLocalMonitor(event: event)
            return nil
        }

        return localKeyDownMonitor != nil
    }

    private func stopLocalMonitor() {
        if let monitor = localKeyDownMonitor {
            NSEvent.removeMonitor(monitor)
            localKeyDownMonitor = nil
        }
        if let monitor = localKeyUpMonitor {
            NSEvent.removeMonitor(monitor)
            localKeyUpMonitor = nil
        }
        if let monitor = localFlagsMonitor {
            NSEvent.removeMonitor(monitor)
            localFlagsMonitor = nil
        }
    }

    private func handleFlagsChangedLocalMonitor(event: NSEvent) {
        let keyCode = event.keyCode
        let flags = event.modifierFlags

        let keyFlagMap: [(UInt16, NSEvent.ModifierFlags)] = [
            (56, .shift), (60, .shift),
            (59, .control), (62, .control),
            (58, .option), (61, .option),
            (55, .command), (54, .command),
            (57, .capsLock),
            (63, .function)
        ]

        for (code, flag) in keyFlagMap {
            if code == keyCode {
                let isPressed = (code == 57) ? !pressedModifiers.contains(code) : flags.contains(flag)

                if isPressed {
                    if !pressedModifiers.contains(code) {
                        pressedModifiers.insert(code)
                        onKeyPress?(code)
                    }
                } else {
                    if pressedModifiers.contains(code) {
                        pressedModifiers.remove(code)
                        onKeyUp?(code)
                    }
                }
                break
            }
        }
    }

    deinit {
        stop()
    }
}
