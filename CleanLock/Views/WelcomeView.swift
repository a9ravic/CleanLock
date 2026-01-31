import SwiftUI

// MARK: - 欢迎视图

struct WelcomeView: View {
    let onDismiss: () -> Void

    @State private var showIcon = false
    @State private var showTitle = false
    @State private var showFeatures = false
    @State private var showButton = false

    var body: some View {
        VStack(spacing: 0) {
            // 内容区域
            VStack(spacing: DesignSystem.Spacing.xxl) {
                // App Icon
                appIcon
                    .opacity(showIcon ? 1 : 0)
                    .scaleEffect(showIcon ? 1 : 0.9)

                // Title
                titleSection
                    .opacity(showTitle ? 1 : 0)
                    .offset(y: showTitle ? 0 : 8)

                // Features
                featuresSection
                    .opacity(showFeatures ? 1 : 0)
                    .offset(y: showFeatures ? 0 : 10)
            }
            .padding(.top, DesignSystem.Spacing.xxxl)

            Spacer()

            // Button
            startButton
                .opacity(showButton ? 1 : 0)
                .offset(y: showButton ? 0 : 8)
                .padding(.bottom, DesignSystem.Spacing.xxl)
        }
        .padding(.horizontal, DesignSystem.Spacing.xxxl)
        .frame(width: 420, height: 480)
        .background(DesignSystem.Colors.windowBackground)
        .onAppear {
            startAnimations()
        }
    }

    // MARK: - App Icon

    private var appIcon: some View {
        AppIconView(size: .large)
    }

    // MARK: - Title Section

    private var titleSection: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            Text("CleanLock")
                .font(DesignSystem.Typography.largeTitle)
                .foregroundColor(DesignSystem.Colors.primaryText)

            Text("清洁 MacBook 键盘时锁定键盘防止误触")
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.secondaryText)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Features Section

    private var featuresSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            FeatureInfoRow(
                icon: "sparkles",
                iconColor: .yellow,
                title: "可视化清洁",
                description: "按下的键会亮起表示已清洁"
            )

            FeatureInfoRow(
                icon: "checkmark.circle.fill",
                iconColor: .green,
                title: "自动解锁",
                description: "全部清洁完成后自动退出"
            )

            FeatureInfoRow(
                icon: "command",
                iconColor: DesignSystem.Colors.brand,
                title: "快捷启动",
                description: "按下 ⌘⇧K 快速启动清洁模式"
            )
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

    // MARK: - Start Button

    private var startButton: some View {
        BrandButton(title: "开始使用", showArrow: true, action: onDismiss)
            .keyboardShortcut(.defaultAction)
    }

    // MARK: - Animations

    private func startAnimations() {
        withAnimation(DesignSystem.Animation.smooth) {
            showIcon = true
        }
        withAnimation(DesignSystem.Animation.smooth.delay(0.1)) {
            showTitle = true
        }
        withAnimation(DesignSystem.Animation.smooth.delay(0.2)) {
            showFeatures = true
        }
        withAnimation(DesignSystem.Animation.smooth.delay(0.35)) {
            showButton = true
        }
    }
}

// MARK: - Preview

#Preview {
    WelcomeView(onDismiss: {})
}
