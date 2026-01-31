import SwiftUI
import AppKit
import CoreGraphics

// MARK: - 主窗口视图

struct MainWindowView: View {
    @ObservedObject var hotKeyManager: HotKeyManager
    @AppStorage("launchAtLogin") private var launchAtLogin = false
    @AppStorage("hasRequestedAccessibility") private var hasRequestedAccessibility = false
    @State private var hasAccessibilityPermission = AXIsProcessTrusted()

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

            // Permission Status (if not granted)
            if !hasAccessibilityPermission {
                permissionStatusCard
                    .padding(.bottom, DesignSystem.Spacing.md)
            }

            // Settings Card
            settingsCard

            Spacer()
        }
        .padding(.horizontal, DesignSystem.Spacing.xxl)
        .padding(.bottom, DesignSystem.Spacing.xl)
        .frame(width: 420, height: hasAccessibilityPermission ? 520 : 680)
        .background(DesignSystem.Colors.windowBackground)
        .onAppear {
            startPermissionPolling()
        }
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

    // MARK: - Permission Status Card

    private var permissionStatusCard: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            // 标题行
            HStack(spacing: DesignSystem.Spacing.sm) {
                Image(systemName: "hand.raised.fill")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.orange)

                Text(String(localized: "permission_required_title"))
                    .font(DesignSystem.Typography.bodySemibold)
                    .foregroundColor(DesignSystem.Colors.primaryText)

                Spacer()
            }

            // 说明文字
            Text(String(localized: "permission_required_desc"))
                .font(DesignSystem.Typography.caption)
                .foregroundColor(DesignSystem.Colors.secondaryText)
                .fixedSize(horizontal: false, vertical: true)

            // 步骤指引
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                PermissionStepRow(number: 1, text: String(localized: "permission_step_1"))
                PermissionStepRow(number: 2, text: String(localized: "permission_step_2"))
                PermissionStepRow(number: 3, text: String(localized: "permission_step_3"))
            }

            // 按钮
            Button {
                requestAccessibilityPermission()
            } label: {
                HStack(spacing: DesignSystem.Spacing.xs) {
                    Image(systemName: "gear")
                        .font(.system(size: 13, weight: .medium))
                    Text(String(localized: "open_settings"))
                        .font(DesignSystem.Typography.captionMedium)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, DesignSystem.Spacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.button, style: .continuous)
                        .fill(Color.orange)
                )
            }
            .buttonStyle(.plain)
        }
        .padding(DesignSystem.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous)
                .fill(Color.orange.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous)
                        .strokeBorder(Color.orange.opacity(0.15), lineWidth: 1)
                )
        )
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

    // MARK: - Actions

    private func requestAccessibilityPermission() {
        print("🔵 requestAccessibilityPermission called")

        // 如果之前已经请求过权限，直接打开系统设置
        if hasRequestedAccessibility {
            openAccessibilitySettings()
            return
        }

        // 首次请求辅助功能权限 - 系统会弹出引导对话框
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        let result = AXIsProcessTrustedWithOptions(options)
        hasRequestedAccessibility = true

        print("🔵 AXIsProcessTrustedWithOptions result: \(result)")

        if result {
            // 已经有权限，直接更新状态
            withAnimation(DesignSystem.Animation.spring) {
                hasAccessibilityPermission = true
            }
        }
        // 首次调用时系统会弹出对话框引导用户到系统设置
    }

    private func openAccessibilitySettings() {
        // 打开系统设置 -> 隐私与安全性 -> 辅助功能
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
            NSWorkspace.shared.open(url)
        }
    }

    private func startPermissionPolling() {
        // 每 2 秒检查一次权限状态
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { timer in
            let granted = AXIsProcessTrusted()
            if granted != hasAccessibilityPermission {
                DispatchQueue.main.async {
                    withAnimation(DesignSystem.Animation.spring) {
                        hasAccessibilityPermission = granted
                    }
                }
                if granted {
                    timer.invalidate()
                }
            }
        }
    }
}

// MARK: - Permission Step Row

private struct PermissionStepRow: View {
    let number: Int
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: DesignSystem.Spacing.sm) {
            // 步骤编号
            Text("\(number)")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .frame(width: 18, height: 18)
                .background(Circle().fill(Color.orange.opacity(0.8)))

            // 步骤文字
            Text(text)
                .font(DesignSystem.Typography.caption)
                .foregroundColor(DesignSystem.Colors.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
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

// MARK: - Permission Status Badge (for Menu Bar)

struct PermissionStatusBadge: View {
    let hasPermission: Bool

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            Circle()
                .fill(hasPermission ? Color.green : Color.orange)
                .frame(width: 6, height: 6)

            Text(hasPermission
                 ? String(localized: "permission_full")
                 : String(localized: "permission_basic"))
                .font(DesignSystem.Typography.caption)
                .foregroundColor(DesignSystem.Colors.secondaryText)
        }
    }
}

// MARK: - Preview

#Preview("Main Window") {
    MainWindowView(
        hotKeyManager: HotKeyManager(),
        onStartCleaning: {}
    )
}

#Preview("Permission Badge") {
    VStack(spacing: 20) {
        PermissionStatusBadge(hasPermission: true)
        PermissionStatusBadge(hasPermission: false)
    }
    .padding()
}
