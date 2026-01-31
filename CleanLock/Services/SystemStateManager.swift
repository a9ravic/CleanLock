import Foundation
import AudioToolbox
import CoreGraphics

// MARK: - System State Manager

/// 管理系统状态（音量、亮度）的保存和恢复
/// 用于清洁模式结束后恢复按下功能键导致的系统变化
final class SystemStateManager {

    // MARK: - Singleton

    static let shared = SystemStateManager()

    // MARK: - Saved State

    private var savedVolume: Float?
    private var savedMuted: Bool?
    private var savedBrightness: Float?

    // MARK: - Public Methods

    /// 保存当前系统状态（清洁开始时调用）
    func saveCurrentState() {
        savedVolume = getSystemVolume()
        savedMuted = isSystemMuted()
        savedBrightness = getDisplayBrightness()

        #if DEBUG
        print("📦 SystemState saved - Volume: \(savedVolume ?? -1), Muted: \(savedMuted ?? false), Brightness: \(savedBrightness ?? -1)")
        #endif
    }

    /// 恢复保存的系统状态（清洁结束时调用）
    func restoreState() {
        if let volume = savedVolume {
            setSystemVolume(volume)
        }

        if let muted = savedMuted {
            setSystemMuted(muted)
        }

        if let brightness = savedBrightness {
            setDisplayBrightness(brightness)
        }

        #if DEBUG
        print("📦 SystemState restored - Volume: \(savedVolume ?? -1), Muted: \(savedMuted ?? false), Brightness: \(savedBrightness ?? -1)")
        #endif

        clearSavedState()
    }

    /// 清除保存的状态
    func clearSavedState() {
        savedVolume = nil
        savedMuted = nil
        savedBrightness = nil
    }

    // MARK: - Volume Control (CoreAudio)

    private func getDefaultOutputDevice() -> AudioDeviceID? {
        var deviceID = AudioDeviceID(0)
        var size = UInt32(MemoryLayout<AudioDeviceID>.size)

        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultOutputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        let status = AudioObjectGetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &address,
            0,
            nil,
            &size,
            &deviceID
        )

        return status == noErr ? deviceID : nil
    }

    func getSystemVolume() -> Float? {
        guard let deviceID = getDefaultOutputDevice() else { return nil }

        var volume: Float32 = 0
        var size = UInt32(MemoryLayout<Float32>.size)

        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwareServiceDeviceProperty_VirtualMainVolume,
            mScope: kAudioDevicePropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMain
        )

        let status = AudioObjectGetPropertyData(deviceID, &address, 0, nil, &size, &volume)
        return status == noErr ? volume : nil
    }

    func setSystemVolume(_ volume: Float) {
        guard let deviceID = getDefaultOutputDevice() else { return }

        var newVolume = max(0, min(1, volume))
        let size = UInt32(MemoryLayout<Float32>.size)

        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwareServiceDeviceProperty_VirtualMainVolume,
            mScope: kAudioDevicePropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMain
        )

        AudioObjectSetPropertyData(deviceID, &address, 0, nil, size, &newVolume)
    }

    func isSystemMuted() -> Bool? {
        guard let deviceID = getDefaultOutputDevice() else { return nil }

        var muted: UInt32 = 0
        var size = UInt32(MemoryLayout<UInt32>.size)

        var address = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyMute,
            mScope: kAudioDevicePropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMain
        )

        let status = AudioObjectGetPropertyData(deviceID, &address, 0, nil, &size, &muted)
        return status == noErr ? (muted != 0) : nil
    }

    func setSystemMuted(_ muted: Bool) {
        guard let deviceID = getDefaultOutputDevice() else { return }

        var muteValue: UInt32 = muted ? 1 : 0
        let size = UInt32(MemoryLayout<UInt32>.size)

        var address = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyMute,
            mScope: kAudioDevicePropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMain
        )

        AudioObjectSetPropertyData(deviceID, &address, 0, nil, size, &muteValue)
    }

    // MARK: - Brightness Control (IOKit - may not work in sandbox)

    /// 获取显示器亮度（使用 IOKit，沙盒中可能不可用）
    func getDisplayBrightness() -> Float? {
        // 尝试通过 IOKit 获取亮度
        // 注意：这在沙盒应用中可能不可用
        let service = IOServiceGetMatchingService(kIOMainPortDefault, IOServiceMatching("IODisplayConnect"))
        guard service != 0 else { return nil }

        defer { IOObjectRelease(service) }

        var brightnessValue: Float = 0
        let result = IODisplayGetFloatParameter(service, 0, kIODisplayBrightnessKey as CFString, &brightnessValue)

        return result == kIOReturnSuccess ? brightnessValue : nil
    }

    /// 设置显示器亮度（使用 IOKit，沙盒中可能不可用）
    func setDisplayBrightness(_ brightness: Float) {
        let service = IOServiceGetMatchingService(kIOMainPortDefault, IOServiceMatching("IODisplayConnect"))
        guard service != 0 else { return }

        defer { IOObjectRelease(service) }

        let clampedBrightness = max(0, min(1, brightness))
        IODisplaySetFloatParameter(service, 0, kIODisplayBrightnessKey as CFString, clampedBrightness)
    }
}
