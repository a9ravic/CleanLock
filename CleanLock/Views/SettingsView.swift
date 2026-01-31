import SwiftUI

// MARK: - 设置视图

struct SettingsView: View {
    @ObservedObject var hotKeyManager: HotKeyManager
    @State private var editingHotKey: HotKeyManager.HotKey = .default
    @State private var hasChanges = false

    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Header
            Text(String(localized: "settings_title"))
                .font(DesignSystem.Typography.title3)
                .foregroundColor(DesignSystem.Colors.primaryText)
                .padding(.top, DesignSystem.Spacing.xl)
                .padding(.bottom, DesignSystem.Spacing.lg)

            Divider()

            // Content
            VStack(spacing: DesignSystem.Spacing.lg) {
                // 快捷键录制器
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                    Text(String(localized: "shortcut_label"))
                        .font(DesignSystem.Typography.callout)
                        .foregroundColor(DesignSystem.Colors.secondaryText)

                    HotKeyRecorderView(hotKey: $editingHotKey)
                        .onChange(of: editingHotKey) { newValue in
                            hasChanges = newValue != hotKeyManager.currentHotKey
                        }
                }

                // 恢复默认按钮
                HStack {
                    Button(String(localized: "restore_default")) {
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
                Button(String(localized: "cancel")) {
                    onDismiss()
                }
                .keyboardShortcut(.cancelAction)
                .buttonStyle(SecondaryButtonStyle())

                Spacer()

                Button(String(localized: "save")) {
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
