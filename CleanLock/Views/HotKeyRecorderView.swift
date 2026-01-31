import SwiftUI
import AppKit

// MARK: - 快捷键录制视图

struct HotKeyRecorderView: View {
    @Binding var hotKey: HotKeyManager.HotKey
    @State private var isRecording = false
    @State private var eventMonitor: Any?
    @State private var isHovered = false

    var body: some View {
        Button(action: toggleRecording) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                if isRecording {
                    // 录制状态
                    Circle()
                        .fill(Color.red)
                        .frame(width: 6, height: 6)

                    Text(String(localized: "press_shortcut"))
                        .font(DesignSystem.Typography.callout)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                } else {
                    // 显示当前快捷键
                    Text(hotKey.displayString)
                        .font(DesignSystem.Typography.monospaced)
                        .foregroundColor(DesignSystem.Colors.primaryText)
                }
            }
            .frame(minWidth: 110)
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.button, style: .continuous)
                    .fill(DesignSystem.Colors.controlBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.button, style: .continuous)
                            .strokeBorder(
                                isRecording ? DesignSystem.Colors.brand : (isHovered ? DesignSystem.Colors.separator : DesignSystem.Colors.separator.opacity(0.5)),
                                lineWidth: isRecording ? 1.5 : 0.5
                            )
                    )
            )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(DesignSystem.Animation.micro) {
                isHovered = hovering
            }
        }
        .onDisappear {
            stopRecording()
        }
    }

    private func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }

    private func startRecording() {
        withAnimation(DesignSystem.Animation.quick) {
            isRecording = true
        }

        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            let modifiers = event.modifierFlags.intersection([.command, .shift, .option, .control])

            // 必须至少有一个修饰键
            guard !modifiers.isEmpty else {
                return nil
            }

            // 忽略仅按下修饰键
            let modifierKeyCodes: Set<UInt16> = [54, 55, 56, 57, 58, 59, 60, 61, 62, 63]
            guard !modifierKeyCodes.contains(event.keyCode) else {
                return nil
            }

            // 更新快捷键
            hotKey = HotKeyManager.HotKey(keyCode: event.keyCode, modifiers: modifiers)
            stopRecording()

            return nil
        }
    }

    private func stopRecording() {
        withAnimation(DesignSystem.Animation.quick) {
            isRecording = false
        }
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        HotKeyRecorderView(hotKey: .constant(.default))

        HotKeyRecorderView(
            hotKey: .constant(
                HotKeyManager.HotKey(
                    keyCode: 40,
                    modifiers: [.command, .shift]
                )
            )
        )
    }
    .padding(DesignSystem.Spacing.xxl)
    .background(DesignSystem.Colors.windowBackground)
    .frame(width: 300, height: 150)
}
