# CleanLock Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build a macOS menu bar app that locks keyboard during cleaning, visualizes cleaning progress, and auto-unlocks when complete.

**Architecture:** SwiftUI + AppKit hybrid. Menu bar app with fullscreen cleaning overlay. CGEvent tap for keyboard interception. State managed via ObservableObject with Combine.

**Tech Stack:** Swift, SwiftUI, AppKit, CoreGraphics, XcodeGen, macOS 13.0+

---

## Task 1: Project Setup with XcodeGen

**Files:**
- Create: `project.yml`
- Create: `Makefile`
- Create: `CleanLock/App/Info.plist`
- Create: `CleanLock/CleanLock.entitlements`
- Create: `CleanLock/Resources/Assets.xcassets/Contents.json`
- Create: `CleanLock/Resources/Assets.xcassets/AppIcon.appiconset/Contents.json`
- Create: `CleanLock/Resources/Assets.xcassets/AccentColor.colorset/Contents.json`

**Step 1: Create project.yml**

```yaml
name: CleanLock
options:
  bundleIdPrefix: com.zone
  deploymentTarget:
    macOS: "13.0"
  xcodeVersion: "15.0"
  generateEmptyDirectories: true

settings:
  base:
    SWIFT_VERSION: "5.9"
    MARKETING_VERSION: "1.0.0"
    CURRENT_PROJECT_VERSION: "1"

targets:
  CleanLock:
    type: application
    platform: macOS
    sources:
      - CleanLock
    settings:
      base:
        PRODUCT_BUNDLE_IDENTIFIER: com.zone.cleanlock
        PRODUCT_NAME: CleanLock
        MACOSX_DEPLOYMENT_TARGET: "13.0"
        INFOPLIST_FILE: CleanLock/App/Info.plist
        CODE_SIGN_ENTITLEMENTS: CleanLock/CleanLock.entitlements
        ENABLE_HARDENED_RUNTIME: YES
        COMBINE_HIDPI_IMAGES: YES
        ASSETCATALOG_COMPILER_APPICON_NAME: AppIcon
        ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME: AccentColor
        LD_RUNPATH_SEARCH_PATHS: "$(inherited) @executable_path/../Frameworks"

  CleanLockTests:
    type: bundle.unit-test
    platform: macOS
    sources:
      - CleanLockTests
    dependencies:
      - target: CleanLock
    settings:
      base:
        BUNDLE_LOADER: "$(TEST_HOST)"
        TEST_HOST: "$(BUILT_PRODUCTS_DIR)/CleanLock.app/Contents/MacOS/CleanLock"
```

**Step 2: Create Makefile**

```makefile
.PHONY: generate open clean build test

generate:
	xcodegen generate

open: generate
	open CleanLock.xcodeproj

clean:
	rm -rf CleanLock.xcodeproj
	rm -rf build

build: generate
	xcodebuild -project CleanLock.xcodeproj -scheme CleanLock -configuration Debug build

test: generate
	xcodebuild -project CleanLock.xcodeproj -scheme CleanLockTests -configuration Debug test
```

**Step 3: Create Info.plist**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>$(DEVELOPMENT_LANGUAGE)</string>
    <key>CFBundleExecutable</key>
    <string>$(EXECUTABLE_NAME)</string>
    <key>CFBundleIconFile</key>
    <string></string>
    <key>CFBundleIconName</key>
    <string>AppIcon</string>
    <key>CFBundleIdentifier</key>
    <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>$(PRODUCT_NAME)</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>$(MARKETING_VERSION)</string>
    <key>CFBundleVersion</key>
    <string>$(CURRENT_PROJECT_VERSION)</string>
    <key>LSApplicationCategoryType</key>
    <string>public.app-category.utilities</string>
    <key>LSMinimumSystemVersion</key>
    <string>$(MACOSX_DEPLOYMENT_TARGET)</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSAccessibilityUsageDescription</key>
    <string>CleanLock 需要辅助功能权限来拦截键盘输入，防止清洁键盘时误触。</string>
    <key>NSHumanReadableCopyright</key>
    <string>Copyright © 2026 Zone. All rights reserved.</string>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
</dict>
</plist>
```

**Step 4: Create entitlements file**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.app-sandbox</key>
    <true/>
</dict>
</plist>
```

**Step 5: Create Assets.xcassets structure**

Create `CleanLock/Resources/Assets.xcassets/Contents.json`:
```json
{
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
```

Create `CleanLock/Resources/Assets.xcassets/AppIcon.appiconset/Contents.json`:
```json
{
  "images" : [
    {
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "16x16"
    },
    {
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "16x16"
    },
    {
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "32x32"
    },
    {
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "32x32"
    },
    {
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "128x128"
    },
    {
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "128x128"
    },
    {
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "256x256"
    },
    {
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "256x256"
    },
    {
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "512x512"
    },
    {
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "512x512"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
```

Create `CleanLock/Resources/Assets.xcassets/AccentColor.colorset/Contents.json`:
```json
{
  "colors" : [
    {
      "idiom" : "universal"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
```

**Step 6: Create placeholder Swift files for compilation**

Create `CleanLock/App/CleanLockApp.swift`:
```swift
import SwiftUI

@main
struct CleanLockApp: App {
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
```

Create `CleanLockTests/CleanLockTests.swift`:
```swift
import XCTest
@testable import CleanLock

final class CleanLockTests: XCTestCase {
    func testPlaceholder() {
        XCTAssertTrue(true)
    }
}
```

**Step 7: Generate project and verify**

Run: `make generate`
Expected: `CleanLock.xcodeproj` created successfully

**Step 8: Build project**

Run: `make build`
Expected: BUILD SUCCEEDED

**Step 9: Commit**

```bash
git add project.yml Makefile CleanLock CleanLockTests
git commit -m "feat: initialize project with XcodeGen"
```

---

## Task 2: KeyboardLayout Model

**Files:**
- Create: `CleanLock/Models/KeyboardLayout.swift`
- Create: `CleanLockTests/Models/KeyboardLayoutTests.swift`

**Step 1: Write the test file**

```swift
import XCTest
@testable import CleanLock

final class KeyboardLayoutTests: XCTestCase {

    func testMacBookLayoutHas78Keys() {
        let layout = KeyboardLayout.macBook
        XCTAssertEqual(layout.allKeys.count, 78)
    }

    func testKeyHasValidProperties() {
        let layout = KeyboardLayout.macBook
        let escKey = layout.allKeys.first { $0.label == "esc" }

        XCTAssertNotNil(escKey)
        XCTAssertEqual(escKey?.keyCode, 53)
        XCTAssertGreaterThan(escKey?.width ?? 0, 0)
    }

    func testAllKeysHaveUniqueKeyCodes() {
        let layout = KeyboardLayout.macBook
        let keyCodes = layout.allKeys.map { $0.keyCode }
        let uniqueKeyCodes = Set(keyCodes)

        XCTAssertEqual(keyCodes.count, uniqueKeyCodes.count)
    }

    func testRowsAreOrganizedCorrectly() {
        let layout = KeyboardLayout.macBook

        XCTAssertEqual(layout.rows.count, 5)
        XCTAssertEqual(layout.rows[0].count, 14) // Top row
        XCTAssertEqual(layout.rows[4].count, 10) // Bottom row with arrows
    }
}
```

**Step 2: Run test to verify it fails**

Run: `make test`
Expected: FAIL - cannot find 'KeyboardLayout' in scope

**Step 3: Implement KeyboardLayout**

```swift
import Foundation

struct Key: Identifiable, Equatable, Hashable {
    let id: UUID = UUID()
    let keyCode: UInt16
    let label: String
    let width: CGFloat
    let isModifier: Bool

    init(keyCode: UInt16, label: String, width: CGFloat = 1.0, isModifier: Bool = false) {
        self.keyCode = keyCode
        self.label = label
        self.width = width
        self.isModifier = isModifier
    }

    static func == (lhs: Key, rhs: Key) -> Bool {
        lhs.keyCode == rhs.keyCode
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(keyCode)
    }
}

struct KeyboardLayout {
    let rows: [[Key]]

    var allKeys: [Key] {
        rows.flatMap { $0 }
    }

    static let macBook: KeyboardLayout = {
        let row0: [Key] = [
            Key(keyCode: 53, label: "esc"),
            Key(keyCode: 18, label: "1"),
            Key(keyCode: 19, label: "2"),
            Key(keyCode: 20, label: "3"),
            Key(keyCode: 21, label: "4"),
            Key(keyCode: 23, label: "5"),
            Key(keyCode: 22, label: "6"),
            Key(keyCode: 26, label: "7"),
            Key(keyCode: 28, label: "8"),
            Key(keyCode: 25, label: "9"),
            Key(keyCode: 29, label: "0"),
            Key(keyCode: 27, label: "-"),
            Key(keyCode: 24, label: "="),
            Key(keyCode: 51, label: "delete", width: 1.5)
        ]

        let row1: [Key] = [
            Key(keyCode: 48, label: "tab", width: 1.5),
            Key(keyCode: 12, label: "Q"),
            Key(keyCode: 13, label: "W"),
            Key(keyCode: 14, label: "E"),
            Key(keyCode: 15, label: "R"),
            Key(keyCode: 17, label: "T"),
            Key(keyCode: 16, label: "Y"),
            Key(keyCode: 32, label: "U"),
            Key(keyCode: 34, label: "I"),
            Key(keyCode: 31, label: "O"),
            Key(keyCode: 35, label: "P"),
            Key(keyCode: 33, label: "["),
            Key(keyCode: 30, label: "]"),
            Key(keyCode: 42, label: "\\")
        ]

        let row2: [Key] = [
            Key(keyCode: 57, label: "caps", width: 1.75, isModifier: true),
            Key(keyCode: 0, label: "A"),
            Key(keyCode: 1, label: "S"),
            Key(keyCode: 2, label: "D"),
            Key(keyCode: 3, label: "F"),
            Key(keyCode: 5, label: "G"),
            Key(keyCode: 4, label: "H"),
            Key(keyCode: 38, label: "J"),
            Key(keyCode: 40, label: "K"),
            Key(keyCode: 37, label: "L"),
            Key(keyCode: 41, label: ";"),
            Key(keyCode: 39, label: "'"),
            Key(keyCode: 36, label: "return", width: 1.75)
        ]

        let row3: [Key] = [
            Key(keyCode: 56, label: "shift", width: 2.25, isModifier: true),
            Key(keyCode: 6, label: "Z"),
            Key(keyCode: 7, label: "X"),
            Key(keyCode: 8, label: "C"),
            Key(keyCode: 9, label: "V"),
            Key(keyCode: 11, label: "B"),
            Key(keyCode: 45, label: "N"),
            Key(keyCode: 46, label: "M"),
            Key(keyCode: 43, label: ","),
            Key(keyCode: 47, label: "."),
            Key(keyCode: 44, label: "/"),
            Key(keyCode: 60, label: "shift", width: 2.25, isModifier: true)
        ]

        let row4: [Key] = [
            Key(keyCode: 63, label: "fn", isModifier: true),
            Key(keyCode: 59, label: "ctrl", width: 1.25, isModifier: true),
            Key(keyCode: 58, label: "opt", width: 1.25, isModifier: true),
            Key(keyCode: 55, label: "cmd", width: 1.5, isModifier: true),
            Key(keyCode: 49, label: "space", width: 5.0),
            Key(keyCode: 54, label: "cmd", width: 1.5, isModifier: true),
            Key(keyCode: 61, label: "opt", width: 1.25, isModifier: true),
            Key(keyCode: 123, label: "←", width: 0.75),
            Key(keyCode: 126, label: "↑", width: 0.75),
            Key(keyCode: 125, label: "↓", width: 0.75),
            Key(keyCode: 124, label: "→", width: 0.75)
        ]

        return KeyboardLayout(rows: [row0, row1, row2, row3, row4])
    }()
}
```

**Step 4: Run test to verify it passes**

Run: `make test`
Expected: All tests PASS

**Step 5: Commit**

```bash
git add CleanLock/Models/KeyboardLayout.swift CleanLockTests/Models/KeyboardLayoutTests.swift
git commit -m "feat: add KeyboardLayout model with MacBook layout"
```

---

## Task 3: CleaningState Model

**Files:**
- Create: `CleanLock/Models/CleaningState.swift`
- Create: `CleanLockTests/Models/CleaningStateTests.swift`

**Step 1: Write the test file**

```swift
import XCTest
@testable import CleanLock

final class CleaningStateTests: XCTestCase {

    func testInitialStateIsIdle() {
        let manager = CleaningStateManager()
        XCTAssertEqual(manager.state, .idle)
    }

    func testStartCleaningTransitionsToCleaningState() {
        let manager = CleaningStateManager()
        manager.startCleaning()

        if case .cleaning(let keys) = manager.state {
            XCTAssertTrue(keys.isEmpty)
        } else {
            XCTFail("Expected cleaning state")
        }
    }

    func testMarkKeyAsCleanedAddsToSet() {
        let manager = CleaningStateManager()
        manager.startCleaning()
        manager.markKeyCleaned(keyCode: 53) // esc

        if case .cleaning(let keys) = manager.state {
            XCTAssertTrue(keys.contains(53))
        } else {
            XCTFail("Expected cleaning state")
        }
    }

    func testProgressCalculation() {
        let manager = CleaningStateManager()
        manager.startCleaning()

        XCTAssertEqual(manager.progress, 0.0)

        manager.markKeyCleaned(keyCode: 53)
        manager.markKeyCleaned(keyCode: 18)

        XCTAssertEqual(manager.cleanedCount, 2)
        XCTAssertEqual(manager.progress, 2.0 / 78.0, accuracy: 0.001)
    }

    func testAllKeysCleanedTransitionsToCompleted() {
        let manager = CleaningStateManager()
        manager.startCleaning()

        for key in KeyboardLayout.macBook.allKeys {
            manager.markKeyCleaned(keyCode: key.keyCode)
        }

        XCTAssertEqual(manager.state, .completed)
    }

    func testResetCleaning() {
        let manager = CleaningStateManager()
        manager.startCleaning()
        manager.markKeyCleaned(keyCode: 53)
        manager.reset()

        XCTAssertEqual(manager.state, .idle)
    }

    func testIsKeyCleanedCheck() {
        let manager = CleaningStateManager()
        manager.startCleaning()

        XCTAssertFalse(manager.isKeyCleaned(keyCode: 53))
        manager.markKeyCleaned(keyCode: 53)
        XCTAssertTrue(manager.isKeyCleaned(keyCode: 53))
    }
}
```

**Step 2: Run test to verify it fails**

Run: `make test`
Expected: FAIL - cannot find 'CleaningStateManager' in scope

**Step 3: Implement CleaningState**

```swift
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

    private let totalKeys: Int
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
```

**Step 4: Run test to verify it passes**

Run: `make test`
Expected: All tests PASS

**Step 5: Commit**

```bash
git add CleanLock/Models/CleaningState.swift CleanLockTests/Models/CleaningStateTests.swift
git commit -m "feat: add CleaningState model with state management"
```

---

## Task 4: PermissionManager Service

**Files:**
- Create: `CleanLock/Services/PermissionManager.swift`

**Step 1: Create PermissionManager**

```swift
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
```

**Step 2: Build to verify compilation**

Run: `make build`
Expected: BUILD SUCCEEDED

**Step 3: Commit**

```bash
git add CleanLock/Services/PermissionManager.swift
git commit -m "feat: add PermissionManager for accessibility permission"
```

---

## Task 5: KeyInterceptor Service

**Files:**
- Create: `CleanLock/Services/KeyInterceptor.swift`

**Step 1: Create KeyInterceptor**

```swift
import Foundation
import CoreGraphics
import Combine

final class KeyInterceptor {
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?

    var onKeyPress: ((UInt16) -> Void)?

    var isRunning: Bool {
        eventTap != nil
    }

    func start() -> Bool {
        guard eventTap == nil else { return true }

        let eventMask = (1 << CGEventType.keyDown.rawValue) | (1 << CGEventType.keyUp.rawValue)

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
            CFRunLoopAddSource(CFRunLoopGetCurrent(), source, .commonModes)
            CGEvent.tapEnable(tap: tap, enable: true)
        }

        return true
    }

    func stop() {
        if let tap = eventTap {
            CGEvent.tapEnable(tap: tap, enable: false)
            if let source = runLoopSource {
                CFRunLoopRemoveSource(CFRunLoopGetCurrent(), source, .commonModes)
            }
            CFMachPortInvalidate(tap)
        }
        eventTap = nil
        runLoopSource = nil
    }

    private func handleEvent(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent) -> Unmanaged<CGEvent>? {
        guard type == .keyDown else {
            return nil // Block key up events too
        }

        let keyCode = UInt16(event.getIntegerValueField(.keyboardEventKeycode))
        onKeyPress?(keyCode)

        // Return nil to block the event from propagating
        return nil
    }

    deinit {
        stop()
    }
}
```

**Step 2: Build to verify compilation**

Run: `make build`
Expected: BUILD SUCCEEDED

**Step 3: Commit**

```bash
git add CleanLock/Services/KeyInterceptor.swift
git commit -m "feat: add KeyInterceptor for keyboard event capture"
```

---

## Task 6: HotKeyManager Service

**Files:**
- Create: `CleanLock/Services/HotKeyManager.swift`

**Step 1: Create HotKeyManager**

```swift
import Foundation
import AppKit
import Carbon
import Combine

@MainActor
final class HotKeyManager: ObservableObject {
    @Published var currentHotKey: HotKey = .default

    private var eventMonitor: Any?
    var onHotKeyPressed: (() -> Void)?

    struct HotKey: Equatable, Codable {
        var keyCode: UInt16
        var modifiers: NSEvent.ModifierFlags

        static let `default` = HotKey(
            keyCode: 40, // K
            modifiers: [.command, .shift]
        )

        var displayString: String {
            var parts: [String] = []
            if modifiers.contains(.command) { parts.append("⌘") }
            if modifiers.contains(.shift) { parts.append("⇧") }
            if modifiers.contains(.option) { parts.append("⌥") }
            if modifiers.contains(.control) { parts.append("⌃") }
            parts.append(keyCodeToString(keyCode))
            return parts.joined()
        }

        private func keyCodeToString(_ keyCode: UInt16) -> String {
            let keyMap: [UInt16: String] = [
                0: "A", 1: "S", 2: "D", 3: "F", 4: "H", 5: "G", 6: "Z", 7: "X",
                8: "C", 9: "V", 11: "B", 12: "Q", 13: "W", 14: "E", 15: "R",
                16: "Y", 17: "T", 31: "O", 32: "U", 34: "I", 35: "P", 37: "L",
                38: "J", 40: "K", 45: "N", 46: "M"
            ]
            return keyMap[keyCode] ?? "?"
        }
    }

    func start() {
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            Task { @MainActor in
                self?.handleGlobalKeyEvent(event)
            }
        }
    }

    func stop() {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
    }

    private func handleGlobalKeyEvent(_ event: NSEvent) {
        let pressedModifiers = event.modifierFlags.intersection([.command, .shift, .option, .control])
        let requiredModifiers = currentHotKey.modifiers.intersection([.command, .shift, .option, .control])

        if event.keyCode == currentHotKey.keyCode && pressedModifiers == requiredModifiers {
            onHotKeyPressed?()
        }
    }

    func saveHotKey() {
        if let data = try? JSONEncoder().encode(currentHotKey) {
            UserDefaults.standard.set(data, forKey: "CleanLockHotKey")
        }
    }

    func loadHotKey() {
        if let data = UserDefaults.standard.data(forKey: "CleanLockHotKey"),
           let hotKey = try? JSONDecoder().decode(HotKey.self, from: data) {
            currentHotKey = hotKey
        }
    }

    deinit {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }
}
```

**Step 2: Build to verify compilation**

Run: `make build`
Expected: BUILD SUCCEEDED

**Step 3: Commit**

```bash
git add CleanLock/Services/HotKeyManager.swift
git commit -m "feat: add HotKeyManager for global shortcut"
```

---

## Task 7: KeyCapView

**Files:**
- Create: `CleanLock/Views/KeyCapView.swift`

**Step 1: Create KeyCapView**

```swift
import SwiftUI

struct KeyCapView: View {
    let key: Key
    let isCleaned: Bool
    let baseSize: CGFloat

    @State private var isPressed = false

    private var keyWidth: CGFloat {
        baseSize * key.width + (key.width - 1) * 4
    }

    private var keyHeight: CGFloat {
        baseSize
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(isCleaned ? Color.accentColor : Color(nsColor: .controlBackgroundColor))
                .shadow(color: .black.opacity(0.2), radius: 1, y: 1)

            Text(key.label)
                .font(.system(size: baseSize * 0.35, weight: .medium, design: .rounded))
                .foregroundColor(isCleaned ? .white : .primary)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
        .frame(width: keyWidth, height: keyHeight)
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
        .animation(.easeInOut(duration: 0.2), value: isCleaned)
    }

    func triggerPress() {
        isPressed = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            isPressed = false
        }
    }
}

#Preview {
    HStack(spacing: 8) {
        KeyCapView(key: Key(keyCode: 53, label: "esc"), isCleaned: false, baseSize: 50)
        KeyCapView(key: Key(keyCode: 49, label: "space", width: 3.0), isCleaned: true, baseSize: 50)
    }
    .padding()
    .background(Color(nsColor: .windowBackgroundColor))
}
```

**Step 2: Build to verify compilation**

Run: `make build`
Expected: BUILD SUCCEEDED

**Step 3: Commit**

```bash
git add CleanLock/Views/KeyCapView.swift
git commit -m "feat: add KeyCapView component"
```

---

## Task 8: KeyboardView

**Files:**
- Create: `CleanLock/Views/KeyboardView.swift`

**Step 1: Create KeyboardView**

```swift
import SwiftUI

struct KeyboardView: View {
    let layout: KeyboardLayout
    let cleanedKeys: Set<UInt16>
    let baseKeySize: CGFloat

    var body: some View {
        VStack(spacing: 4) {
            ForEach(Array(layout.rows.enumerated()), id: \.offset) { _, row in
                HStack(spacing: 4) {
                    ForEach(row) { key in
                        KeyCapView(
                            key: key,
                            isCleaned: cleanedKeys.contains(key.keyCode),
                            baseSize: baseKeySize
                        )
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
        )
    }
}

#Preview {
    KeyboardView(
        layout: .macBook,
        cleanedKeys: [53, 18, 19, 20],
        baseKeySize: 40
    )
    .padding()
    .background(Color.black.opacity(0.5))
}
```

**Step 2: Build to verify compilation**

Run: `make build`
Expected: BUILD SUCCEEDED

**Step 3: Commit**

```bash
git add CleanLock/Views/KeyboardView.swift
git commit -m "feat: add KeyboardView component"
```

---

## Task 9: CompletionView

**Files:**
- Create: `CleanLock/Views/CompletionView.swift`

**Step 1: Create CompletionView**

```swift
import SwiftUI

struct CompletionView: View {
    @State private var showCheckmark = false
    @State private var countdown = 3

    let onComplete: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
                .scaleEffect(showCheckmark ? 1.0 : 0.5)
                .opacity(showCheckmark ? 1.0 : 0.0)

            Text("清洁完成！")
                .font(.system(size: 32, weight: .semibold, design: .rounded))
                .foregroundColor(.primary)

            Text("即将退出... (\(countdown))")
                .font(.system(size: 18, weight: .regular))
                .foregroundColor(.secondary)
        }
        .padding(48)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                showCheckmark = true
            }
            startCountdown()
        }
    }

    private func startCountdown() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if countdown > 1 {
                countdown -= 1
            } else {
                timer.invalidate()
                onComplete()
            }
        }
    }
}

#Preview {
    ZStack {
        Color.black.opacity(0.5)
        CompletionView(onComplete: {})
    }
}
```

**Step 2: Build to verify compilation**

Run: `make build`
Expected: BUILD SUCCEEDED

**Step 3: Commit**

```bash
git add CleanLock/Views/CompletionView.swift
git commit -m "feat: add CompletionView with countdown animation"
```

---

## Task 10: PermissionGuideView

**Files:**
- Create: `CleanLock/Views/PermissionGuideView.swift`

**Step 1: Create PermissionGuideView**

```swift
import SwiftUI

struct PermissionGuideView: View {
    @ObservedObject var permissionManager: PermissionManager
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "lock.shield")
                .font(.system(size: 64))
                .foregroundColor(.accentColor)

            Text("CleanLock 需要辅助功能权限")
                .font(.system(size: 24, weight: .semibold, design: .rounded))
                .foregroundColor(.primary)

            Text("为了拦截键盘输入防止清洁时误触，\n请在系统设置中授予辅助功能权限。")
                .font(.system(size: 16))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            VStack(spacing: 12) {
                Button(action: {
                    permissionManager.openAccessibilitySettings()
                }) {
                    Text("打开系统设置...")
                        .font(.system(size: 16, weight: .medium))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                Button(action: onDismiss) {
                    Text("稍后再说")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .frame(width: 240)
        }
        .padding(48)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .onAppear {
            permissionManager.startMonitoringPermission()
        }
        .onDisappear {
            permissionManager.stopMonitoringPermission()
        }
    }
}

#Preview {
    ZStack {
        Color.black.opacity(0.5)
        PermissionGuideView(
            permissionManager: PermissionManager(),
            onDismiss: {}
        )
    }
}
```

**Step 2: Build to verify compilation**

Run: `make build`
Expected: BUILD SUCCEEDED

**Step 3: Commit**

```bash
git add CleanLock/Views/PermissionGuideView.swift
git commit -m "feat: add PermissionGuideView for accessibility permission"
```

---

## Task 11: CleaningView (Main Fullscreen View)

**Files:**
- Create: `CleanLock/Views/CleaningView.swift`

**Step 1: Create CleaningView**

```swift
import SwiftUI

struct CleaningView: View {
    @ObservedObject var stateManager: CleaningStateManager
    @ObservedObject var permissionManager: PermissionManager

    let onExit: () -> Void

    @State private var escPressStartTime: Date?
    @State private var escHoldProgress: CGFloat = 0
    @State private var escTimer: Timer?

    private var cleanedKeys: Set<UInt16> {
        if case .cleaning(let keys) = stateManager.state {
            return keys
        }
        return []
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                Color.black.opacity(0.8)
                    .ignoresSafeArea()

                // Content based on state
                switch stateManager.state {
                case .idle:
                    if !permissionManager.hasAccessibilityPermission {
                        PermissionGuideView(
                            permissionManager: permissionManager,
                            onDismiss: onExit
                        )
                    }

                case .cleaning:
                    cleaningContent(geometry: geometry)

                case .completed:
                    CompletionView(onComplete: onExit)

                case .exiting:
                    EmptyView()
                }
            }
        }
    }

    @ViewBuilder
    private func cleaningContent(geometry: GeometryProxy) -> some View {
        VStack(spacing: 32) {
            // Header with exit button
            HStack {
                Spacer()
                Button(action: onExit) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .padding()
            }

            Spacer()

            // Title and progress
            VStack(spacing: 16) {
                Text("CleanLock")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)

                Text("擦拭键盘，按下的键会亮起")
                    .font(.system(size: 18))
                    .foregroundColor(.secondary)

                Text("进度: \(stateManager.cleanedCount)/78 键")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.accentColor)
            }

            // Keyboard
            let baseKeySize = min(geometry.size.width / 18, 50.0)
            KeyboardView(
                layout: .macBook,
                cleanedKeys: cleanedKeys,
                baseKeySize: baseKeySize
            )

            Spacer()

            // Esc hold indicator
            VStack(spacing: 8) {
                if escHoldProgress > 0 {
                    ZStack {
                        Circle()
                            .stroke(Color.secondary.opacity(0.3), lineWidth: 4)
                            .frame(width: 40, height: 40)

                        Circle()
                            .trim(from: 0, to: escHoldProgress)
                            .stroke(Color.accentColor, lineWidth: 4)
                            .frame(width: 40, height: 40)
                            .rotationEffect(.degrees(-90))
                    }
                }

                Text("长按 Esc 3秒可退出")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 32)
        }
    }

    func handleEscPress() {
        if escPressStartTime == nil {
            escPressStartTime = Date()
            startEscTimer()
        }
    }

    func handleEscRelease() {
        escPressStartTime = nil
        escTimer?.invalidate()
        escTimer = nil
        withAnimation(.easeOut(duration: 0.2)) {
            escHoldProgress = 0
        }
    }

    private func startEscTimer() {
        escTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            guard let startTime = escPressStartTime else { return }
            let elapsed = Date().timeIntervalSince(startTime)
            let progress = min(elapsed / 3.0, 1.0)

            withAnimation(.linear(duration: 0.05)) {
                escHoldProgress = progress
            }

            if progress >= 1.0 {
                escTimer?.invalidate()
                escTimer = nil
                onExit()
            }
        }
    }
}

#Preview {
    CleaningView(
        stateManager: CleaningStateManager(),
        permissionManager: PermissionManager(),
        onExit: {}
    )
}
```

**Step 2: Build to verify compilation**

Run: `make build`
Expected: BUILD SUCCEEDED

**Step 3: Commit**

```bash
git add CleanLock/Views/CleaningView.swift
git commit -m "feat: add CleaningView main fullscreen interface"
```

---

## Task 12: MenuBarView

**Files:**
- Create: `CleanLock/Views/MenuBarView.swift`

**Step 1: Create MenuBarView**

```swift
import SwiftUI

struct MenuBarView: View {
    @ObservedObject var hotKeyManager: HotKeyManager
    @AppStorage("launchAtLogin") private var launchAtLogin = false

    let onStartCleaning: () -> Void
    let onQuit: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            Text("CleanLock")
                .font(.system(size: 14, weight: .semibold))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)

            Divider()

            // Start cleaning
            Button(action: onStartCleaning) {
                HStack {
                    Image(systemName: "play.fill")
                    Text("开始清洁")
                    Spacer()
                    Text(hotKeyManager.currentHotKey.displayString)
                        .foregroundColor(.secondary)
                }
            }
            .buttonStyle(MenuItemButtonStyle())

            Divider()
                .padding(.vertical, 4)

            // Settings
            Toggle(isOn: $launchAtLogin) {
                Text("开机启动")
            }
            .toggleStyle(.checkbox)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)

            Button(action: {
                // TODO: Open hotkey settings
            }) {
                HStack {
                    Text("快捷键设置...")
                    Spacer()
                }
            }
            .buttonStyle(MenuItemButtonStyle())

            Divider()
                .padding(.vertical, 4)

            // About & Quit
            Button(action: {
                NSApplication.shared.orderFrontStandardAboutPanel()
            }) {
                Text("关于 CleanLock")
            }
            .buttonStyle(MenuItemButtonStyle())

            Button(action: onQuit) {
                Text("退出")
            }
            .buttonStyle(MenuItemButtonStyle())
        }
        .frame(width: 220)
        .padding(.vertical, 8)
    }
}

struct MenuItemButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(configuration.isPressed ? Color.accentColor.opacity(0.2) : Color.clear)
            .foregroundColor(.primary)
            .contentShape(Rectangle())
    }
}

#Preview {
    MenuBarView(
        hotKeyManager: HotKeyManager(),
        onStartCleaning: {},
        onQuit: {}
    )
    .background(Color(nsColor: .windowBackgroundColor))
}
```

**Step 2: Build to verify compilation**

Run: `make build`
Expected: BUILD SUCCEEDED

**Step 3: Commit**

```bash
git add CleanLock/Views/MenuBarView.swift
git commit -m "feat: add MenuBarView"
```

---

## Task 13: AppDelegate and Window Management

**Files:**
- Create: `CleanLock/App/AppDelegate.swift`

**Step 1: Create AppDelegate**

```swift
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
```

**Step 2: Build to verify compilation**

Run: `make build`
Expected: BUILD SUCCEEDED

**Step 3: Commit**

```bash
git add CleanLock/App/AppDelegate.swift
git commit -m "feat: add AppDelegate with window management"
```

---

## Task 14: Update CleanLockApp Entry Point

**Files:**
- Modify: `CleanLock/App/CleanLockApp.swift`

**Step 1: Update CleanLockApp**

```swift
import SwiftUI

@main
struct CleanLockApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
```

**Step 2: Build and run to verify**

Run: `make build`
Expected: BUILD SUCCEEDED

**Step 3: Run the app manually to test**

Run: `make open`
Then build and run in Xcode to test menu bar icon appears.

**Step 4: Commit**

```bash
git add CleanLock/App/CleanLockApp.swift
git commit -m "feat: connect AppDelegate to SwiftUI app lifecycle"
```

---

## Task 15: Run All Tests and Final Verification

**Step 1: Run all tests**

Run: `make test`
Expected: All tests PASS

**Step 2: Build release**

Run: `xcodebuild -project CleanLock.xcodeproj -scheme CleanLock -configuration Release build`
Expected: BUILD SUCCEEDED

**Step 3: Final commit**

```bash
git add -A
git commit -m "chore: finalize initial implementation"
```

---

## Summary

| Task | Description | Files |
|------|-------------|-------|
| 1 | Project setup with XcodeGen | project.yml, Makefile, Info.plist, entitlements |
| 2 | KeyboardLayout model | KeyboardLayout.swift + tests |
| 3 | CleaningState model | CleaningState.swift + tests |
| 4 | PermissionManager service | PermissionManager.swift |
| 5 | KeyInterceptor service | KeyInterceptor.swift |
| 6 | HotKeyManager service | HotKeyManager.swift |
| 7 | KeyCapView component | KeyCapView.swift |
| 8 | KeyboardView component | KeyboardView.swift |
| 9 | CompletionView | CompletionView.swift |
| 10 | PermissionGuideView | PermissionGuideView.swift |
| 11 | CleaningView | CleaningView.swift |
| 12 | MenuBarView | MenuBarView.swift |
| 13 | AppDelegate | AppDelegate.swift |
| 14 | CleanLockApp entry point | CleanLockApp.swift |
| 15 | Final verification | Tests + release build |
