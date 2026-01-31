import SwiftUI

// MARK: - 菜单栏下拉视图

struct MenuBarView: View {
    @ObservedObject var hotKeyManager: HotKeyManager
    @AppStorage("launchAtLogin") private var launchAtLogin = false

    let onStartCleaning: () -> Void
    let onOpenSettings: () -> Void
    let onOpenWelcome: () -> Void
    let onQuit: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            headerSection
                .padding(.bottom, DesignSystem.Spacing.sm)

            Divider()
                .padding(.horizontal, DesignSystem.Spacing.sm)

            // Start cleaning - 主要操作
            MenuItemButton(
                icon: "play.fill",
                title: "开始清洁",
                shortcut: hotKeyManager.currentHotKey.displayString,
                action: onStartCleaning
            )
            .padding(.top, DesignSystem.Spacing.xs)

            Divider()
                .padding(.horizontal, DesignSystem.Spacing.sm)
                .padding(.vertical, DesignSystem.Spacing.xs)

            // Settings section
            VStack(spacing: 0) {
                // Launch at login toggle
                HStack(spacing: DesignSystem.Spacing.sm) {
                    Image(systemName: "power")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                        .frame(width: 16)

                    Text("开机启动")
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(DesignSystem.Colors.primaryText)

                    Spacer()

                    Toggle("", isOn: $launchAtLogin)
                        .toggleStyle(.checkbox)
                        .labelsHidden()
                }
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.vertical, DesignSystem.Spacing.sm)

                MenuItemButton(
                    icon: "command",
                    title: "快捷键设置...",
                    action: onOpenSettings
                )
            }

            Divider()
                .padding(.horizontal, DesignSystem.Spacing.sm)
                .padding(.vertical, DesignSystem.Spacing.xs)

            // About & Help section
            VStack(spacing: 0) {
                MenuItemButton(
                    icon: "book.closed",
                    title: "使用说明",
                    action: onOpenWelcome
                )

                MenuItemButton(
                    icon: "info.circle",
                    title: "关于 CleanLock",
                    action: {
                        NSApplication.shared.orderFrontStandardAboutPanel()
                    }
                )
            }

            Divider()
                .padding(.horizontal, DesignSystem.Spacing.sm)
                .padding(.vertical, DesignSystem.Spacing.xs)

            // Quit
            MenuItemButton(
                icon: "power",
                title: "退出",
                isDestructive: true,
                action: onQuit
            )
            .padding(.bottom, DesignSystem.Spacing.xs)
        }
        .frame(width: 220)
        .padding(.vertical, DesignSystem.Spacing.sm)
    }

    // MARK: - Header Section

    private var headerSection: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            // App icon
            AppIconView(size: .small, showGlow: false)

            VStack(alignment: .leading, spacing: 1) {
                Text("CleanLock")
                    .font(DesignSystem.Typography.bodySemibold)
                    .foregroundColor(DesignSystem.Colors.primaryText)

                Text("键盘清洁助手")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
            }

            Spacer()
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.sm)
    }
}

// MARK: - Menu Item Button

private struct MenuItemButton: View {
    let icon: String
    let title: String
    var shortcut: String? = nil
    var isDestructive: Bool = false
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(isDestructive ? DesignSystem.Colors.error : DesignSystem.Colors.secondaryText)
                    .frame(width: 16)

                Text(title)
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(isDestructive ? DesignSystem.Colors.error : DesignSystem.Colors.primaryText)

                Spacer()

                if let shortcut = shortcut {
                    ShortcutBadge(text: shortcut)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small, style: .continuous)
                    .fill(isHovered ? Color.accentColor.opacity(0.1) : Color.clear)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(DesignSystem.Animation.micro) {
                isHovered = hovering
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.xs)
    }
}

// MARK: - Preview

#Preview {
    MenuBarView(
        hotKeyManager: HotKeyManager(),
        onStartCleaning: {},
        onOpenSettings: {},
        onOpenWelcome: {},
        onQuit: {}
    )
    .background(Color(nsColor: .windowBackgroundColor))
}
