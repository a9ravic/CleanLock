import Foundation
import CoreGraphics
import Combine
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

final class KeyInterceptor {
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var pressedModifiers: Set<UInt16> = []

    var onKeyPress: ((UInt16) -> Void)?
    var onKeyUp: ((UInt16) -> Void)?

    var isRunning: Bool {
        eventTap != nil
    }

    func start() -> Bool {
        guard eventTap == nil else { return true }

        // Include systemDefined to intercept special function keys (brightness, volume, etc.)
        let eventMask = (1 << CGEventType.keyDown.rawValue)
            | (1 << CGEventType.keyUp.rawValue)
            | (1 << CGEventType.flagsChanged.rawValue)
            | (1 << EventConstants.systemDefinedEventType)

        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(eventMask),
            callback: { proxy, type, event, refcon in
                guard let refcon = refcon else { return Unmanaged.passRetained(event) }
                let interceptor = Unmanaged<KeyInterceptor>.fromOpaque(refcon).takeUnretainedValue()
                return interceptor.handleEvent(proxy: proxy, type: type, event: event)
            },
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        ) else {
            return false
        }

        eventTap = tap
        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)

        if let source = runLoopSource {
            // Use main RunLoop to ensure thread safety
            CFRunLoopAddSource(CFRunLoopGetMain(), source, .commonModes)
            CGEvent.tapEnable(tap: tap, enable: true)
        }

        return true
    }

    func stop() {
        if let tap = eventTap {
            CGEvent.tapEnable(tap: tap, enable: false)
            if let source = runLoopSource {
                // Use main RunLoop to match start()
                CFRunLoopRemoveSource(CFRunLoopGetMain(), source, .commonModes)
            }
            CFMachPortInvalidate(tap)
        }
        eventTap = nil
        runLoopSource = nil
        pressedModifiers.removeAll()
    }

    private func handleEvent(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent) -> Unmanaged<CGEvent>? {
        // Handle special function keys (NX_SYSDEFINED)
        // These are brightness, volume, keyboard backlight, etc.
        if type.rawValue == EventConstants.systemDefinedEventType {
            handleSystemDefinedEvent(event: event)
            // Block special function key events
            return nil
        }

        let keyCode = UInt16(event.getIntegerValueField(.keyboardEventKeycode))

        switch type {
        case .keyDown:
            onKeyPress?(keyCode)

        case .keyUp:
            onKeyUp?(keyCode)

        case .flagsChanged:
            // Handle modifier keys (Shift, Control, Option, Command, Fn, Caps Lock)
            handleFlagsChanged(event: event, keyCode: keyCode)

        default:
            break
        }

        // Return nil to block the event from propagating
        return nil
    }

    private func handleSystemDefinedEvent(event: CGEvent) {
        // NX_SYSDEFINED events use NSEvent to extract data
        guard let nsEvent = NSEvent(cgEvent: event) else { return }

        // Check if it's an auxiliary control button event
        guard nsEvent.subtype.rawValue == EventConstants.auxiliaryControlSubtype else { return }

        let data1 = nsEvent.data1

        // Extract key flavor (bits 16-31) and key state (bits 8-15)
        let keyFlavor = (data1 & 0xFFFF0000) >> 16
        let keyState = (data1 & 0x0000FF00) >> 8
        let isKeyDown = keyState == EventConstants.keyDownState

        // Map special function key flavor to F1-F2, F7-F12 keyCodes
        // F3-F6 无法拦截，已从键盘布局中移除
        // Based on NX_KEYTYPE definitions from IOKit/hidsystem/ev_keymap.h
        let flavorToKeyCode: [Int: UInt16] = [
            // F1-F2: 亮度控制
            3: 122,    // NX_KEYTYPE_BRIGHTNESS_DOWN -> F1
            2: 120,    // NX_KEYTYPE_BRIGHTNESS_UP -> F2

            // F7-F9: 媒体控制
            18: 98,    // NX_KEYTYPE_PREVIOUS -> F7
            20: 98,    // NX_KEYTYPE_REWIND -> F7
            16: 100,   // NX_KEYTYPE_PLAY -> F8
            17: 101,   // NX_KEYTYPE_NEXT -> F9
            19: 101,   // NX_KEYTYPE_FAST -> F9

            // F10-F12: 音量控制
            7: 109,    // NX_KEYTYPE_MUTE -> F10
            1: 103,    // NX_KEYTYPE_SOUND_DOWN -> F11
            0: 111,    // NX_KEYTYPE_SOUND_UP -> F12
        ]

        if let keyCode = flavorToKeyCode[keyFlavor] {
            if isKeyDown {
                onKeyPress?(keyCode)
            } else {
                onKeyUp?(keyCode)
            }
        }
    }

    private func handleFlagsChanged(event: CGEvent, keyCode: UInt16) {
        let flags = event.flags

        // Map keyCode to corresponding flag
        let keyFlagMap: [(UInt16, CGEventFlags)] = [
            (56, .maskShift),      // Left Shift
            (60, .maskShift),      // Right Shift
            (59, .maskControl),    // Left Control
            (62, .maskControl),    // Right Control
            (58, .maskAlternate),  // Left Option
            (61, .maskAlternate),  // Right Option
            (55, .maskCommand),    // Left Command
            (54, .maskCommand),    // Right Command
            (57, .maskAlphaShift), // Caps Lock
            (63, .maskSecondaryFn) // Fn
        ]

        // Check if this modifier is now pressed or released
        for (code, flag) in keyFlagMap {
            if code == keyCode {
                if flags.contains(flag) || (code == 57 && flags.contains(.maskAlphaShift)) {
                    // Modifier pressed
                    if !pressedModifiers.contains(code) {
                        pressedModifiers.insert(code)
                        onKeyPress?(code)
                    }
                } else {
                    // Modifier released
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
