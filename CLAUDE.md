# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands

```bash
# Generate Xcode project (uses XcodeGen)
make generate

# Open project in Xcode
make open

# Build the app
make build

# Run tests
make test

# Clean build artifacts
make clean
```

Direct xcodebuild commands:
```bash
# Build
xcodebuild -project CleanLock.xcodeproj -scheme CleanLock -configuration Debug build

# Run specific test class
xcodebuild -project CleanLock.xcodeproj -scheme CleanLockTests -only-testing:CleanLockTests/KeyboardLayoutTests test

# Run specific test method
xcodebuild -project CleanLock.xcodeproj -scheme CleanLockTests -only-testing:CleanLockTests/CleaningStateTests/testMarkKeyCleaned test
```

## Architecture Overview

CleanLock is a macOS keyboard cleaning utility that locks keyboard input during cleaning and provides visual feedback for pressed keys.

### Hybrid SwiftUI + AppKit Architecture

The app uses **AppKit for window management** and **SwiftUI for views**:

- `CleanLockApp.swift` - SwiftUI App entry point, delegates to AppDelegate via `@NSApplicationDelegateAdaptor`
- `AppDelegate.swift` - Central controller managing windows, services, and lifecycle
- `KeyableWindow` - Custom NSWindow subclass enabling borderless windows to become key window

### Core Services (in Services/)

| Service | Purpose |
|---------|---------|
| `SandboxKeyInterceptor` | NSEvent.addLocalMonitorForEvents for keyboard event interception. App Sandbox compatible. Handles keyDown, keyUp, flagsChanged |
| `HotKeyManager` | Global hotkey registration via NSEvent.addGlobalMonitorForEvents |

### State Management

`CleaningStateManager` drives the UI with a state machine:
```
.idle → .cleaning → .completed → .exiting
```

Cleaned keys are tracked separately in `cleanedKeys: Set<UInt16>` to optimize SwiftUI updates. State changes automatically trigger SwiftUI updates via `@Published`.

### Key Data Flow

```
User triggers cleaning (hotkey/button)
    → AppDelegate.startCleaning()
    → showCleaningWindow()
    → SandboxKeyInterceptor.start()
    → onKeyPress callback → stateManager.markKeyCleaned(keyCode)
    → CleaningView updates → KeyboardView highlights key
```

### Design System

`Theme/DesignSystem.swift` provides:
- `DesignSystem.Colors` - Semantic colors including keyboard-specific palette
- `DesignSystem.Typography` - Font definitions
- `DesignSystem.Spacing` - Spacing constants
- `DesignSystem.Animation` - Standard animations
- Reusable components: `PrimaryButtonStyle`, `CardView`, `SettingRow`, `ShortcutBadge`

### Keyboard Layout Model

`KeyboardLayout.macBook` defines the complete MacBook keyboard with:
- 6 rows (row0=function keys through row5=bottom row with arrows)
- `Key.placeholder()` for F3-F6 (system-intercepted, cannot be captured)
- Arrow keys use inverted-T layout handled specially in `KeyboardView`

## Important Implementation Details

- **App Sandbox enabled** (`CleanLock.entitlements`) - App Store compatible
- **No special permissions required** - Uses NSEvent local monitor instead of CGEvent Tap
- **Window level `.screenSaver`** - Cleaning window appears above all content
- **Automatic focus recovery** - Window regains focus if user clicks outside
- **73 cleanable keys** - Total minus 5 placeholder keys (F3-F6 + TouchID)

## Target Platform

- macOS 13.0+
- Swift 5.9
- Xcode 15.0+
