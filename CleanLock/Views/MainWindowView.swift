import SwiftUI

// MARK: - 主窗口视图

struct MainWindowView: View {
    @ObservedObject var hotKeyManager: HotKeyManager
    @AppStorage("launchAtLogin") private var launchAtLogin = false

    let onStartCleaning: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerSection
                .padding(.top, DesignSystem.Spacing.xxl)

            Spacer().frame(height: DesignSystem.Spacing.xxl)

            // Main Action
            actionSection

            Spacer().frame(height: DesignSystem.Spacing.xl)

            // Settings Card
            settingsCard

            Spacer()
        }
        .padding(.horizontal, DesignSystem.Spacing.xxl)
        .padding(.bottom, DesignSystem.Spacing.xl)
        .frame(width: 400, height: 520)
        .background(DesignSystem.Colors.windowBackground)
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            // App Icon
            AppIconView(size: .medium)

            VStack(spacing: DesignSystem.Spacing.xs) {
                Text("CleanLock")
                    .font(DesignSystem.Typography.title)
                    .foregroundColor(DesignSystem.Colors.primaryText)

                Text(String(localized: "welcome_subtitle"))
                    .font(DesignSystem.Typography.callout)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
            }
        }
    }

    // MARK: - Action Section

    private var actionSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            BrandButton(title: String(localized: "start_cleaning"), icon: "play.fill", action: onStartCleaning)

            // Hotkey hint
            HStack(spacing: DesignSystem.Spacing.xs) {
                Text(String(localized: "shortcut"))
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.tertiaryText)

                ShortcutBadge(text: hotKeyManager.currentHotKey.displayString)
            }
        }
    }

    // MARK: - Settings Card

    private var settingsCard: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            // Hotkey setting
            SettingRow(
                icon: "command",
                iconColor: DesignSystem.Colors.brand,
                title: String(localized: "shortcut")
            ) {
                HotKeyRecorderView(hotKey: Binding(
                    get: { hotKeyManager.currentHotKey },
                    set: { newValue in
                        hotKeyManager.currentHotKey = newValue
                        hotKeyManager.saveHotKey()
                    }
                ))
            }

            Divider()

            // Launch at login
            SettingRow(
                icon: "power",
                iconColor: .green,
                title: String(localized: "launch_at_login")
            ) {
                Toggle("", isOn: $launchAtLogin)
                    .toggleStyle(.switch)
                    .labelsHidden()
            }

            Divider()

            // Instructions
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                Text(String(localized: "instructions"))
                    .font(DesignSystem.Typography.captionMedium)
                    .foregroundColor(DesignSystem.Colors.tertiaryText)
                    .textCase(.uppercase)

                VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                    InstructionItem(icon: "sparkles", text: String(localized: "instruction_1"))
                    InstructionItem(icon: "checkmark.circle", text: String(localized: "instruction_2"))
                    InstructionItem(icon: "escape", text: String(localized: "instruction_3"))
                }
            }
        }
        .padding(DesignSystem.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous)
                .fill(DesignSystem.Colors.controlBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous)
                        .strokeBorder(DesignSystem.Colors.separator.opacity(0.5), lineWidth: 0.5)
                )
        )
    }
}

// MARK: - Instruction Item

private struct InstructionItem: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(DesignSystem.Colors.tertiaryText)
                .frame(width: 14)

            Text(text)
                .font(DesignSystem.Typography.callout)
                .foregroundColor(DesignSystem.Colors.secondaryText)
        }
    }
}

// MARK: - Preview

#Preview {
    MainWindowView(
        hotKeyManager: HotKeyManager(),
        onStartCleaning: {}
    )
}
