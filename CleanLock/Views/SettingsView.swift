import SwiftUI
import Combine

// MARK: - 设置视图

struct SettingsView: View {
    @ObservedObject var hotKeyManager: HotKeyManager
    @State private var editingHotKey: HotKeyManager.HotKey = .default
    @State private var hasChanges = false

    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Header
            Text("快捷键设置")
                .font(DesignSystem.Typography.title3)
                .foregroundColor(DesignSystem.Colors.primaryText)
                .padding(.top, DesignSystem.Spacing.xl)
                .padding(.bottom, DesignSystem.Spacing.lg)

            Divider()

            // Content
            VStack(spacing: DesignSystem.Spacing.lg) {
                // 快捷键录制器
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                    Text("启动清洁模式的快捷键")
                        .font(DesignSystem.Typography.callout)
                        .foregroundColor(DesignSystem.Colors.secondaryText)

                    HotKeyRecorderView(hotKey: $editingHotKey)
                        .onReceive(Just(editingHotKey)) { newValue in
                            hasChanges = newValue != hotKeyManager.currentHotKey
                        }
                }

                // 恢复默认按钮
                HStack {
                    Button("恢复默认") {
                        withAnimation(DesignSystem.Animation.quick) {
                            editingHotKey = .default
                        }
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    .disabled(editingHotKey == .default)
                    .opacity(editingHotKey == .default ? 0.5 : 1)

                    Spacer()
                }
            }
            .padding(DesignSystem.Spacing.xl)

            Spacer()

            Divider()

            // Footer buttons
            HStack {
                Button("取消") {
                    onDismiss()
                }
                .keyboardShortcut(.cancelAction)
                .buttonStyle(SecondaryButtonStyle())

                Spacer()

                Button("保存") {
                    saveChanges()
                }
                .keyboardShortcut(.defaultAction)
                .buttonStyle(PrimaryButtonStyle())
                .disabled(!hasChanges)
                .opacity(hasChanges ? 1 : 0.5)
            }
            .padding(DesignSystem.Spacing.xl)
        }
        .frame(width: 340, height: 240)
        .background(DesignSystem.Colors.windowBackground)
        .onAppear {
            editingHotKey = hotKeyManager.currentHotKey
        }
    }

    private func saveChanges() {
        hotKeyManager.currentHotKey = editingHotKey
        hotKeyManager.saveHotKey()
        onDismiss()
    }
}

// MARK: - Preview

#Preview {
    SettingsView(
        hotKeyManager: HotKeyManager(),
        onDismiss: {}
    )
}
