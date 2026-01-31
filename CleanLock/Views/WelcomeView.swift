import SwiftUI

// MARK: - 欢迎视图

struct WelcomeView: View {
    let onDismiss: () -> Void

    @State private var currentStep: WelcomeStep = .intro
    @State private var showContent = false
    @State private var hasAccessibilityPermission = AXIsProcessTrusted()

    private enum WelcomeStep {
        case intro
        case permission
    }

    var body: some View {
        VStack(spacing: 0) {
            // 步骤指示器
            stepIndicator
                .padding(.top, DesignSystem.Spacing.lg)

            // 内容区域
            Group {
                switch currentStep {
                case .intro:
                    introContent
                case .permission:
                    permissionContent
                }
            }
            .opacity(showContent ? 1 : 0)
            .offset(y: showContent ? 0 : 10)

            Spacer()

            // 按钮区域
            buttonSection
                .padding(.bottom, DesignSystem.Spacing.xxl)
        }
        .padding(.horizontal, DesignSystem.Spacing.xxxl)
        .frame(width: 450, height: 520)
        .background(DesignSystem.Colors.windowBackground)
        .onAppear {
            withAnimation(DesignSystem.Animation.smooth) {
                showContent = true
            }
        }
    }

    // MARK: - Step Indicator

    private var stepIndicator: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            ForEach(0..<2) { index in
                Capsule()
                    .fill(stepIndex >= index ? DesignSystem.Colors.brand : DesignSystem.Colors.separator)
                    .frame(width: stepIndex == index ? 24 : 8, height: 8)
                    .animation(DesignSystem.Animation.spring, value: currentStep)
            }
        }
    }

    private var stepIndex: Int {
        switch currentStep {
        case .intro: return 0
        case .permission: return 1
        }
    }

    // MARK: - Intro Content

    private var introContent: some View {
        VStack(spacing: DesignSystem.Spacing.xxl) {
            // App Icon
            AppIconView(size: .large)
                .padding(.top, DesignSystem.Spacing.xl)

            // Title
            VStack(spacing: DesignSystem.Spacing.sm) {
                Text("CleanLock")
                    .font(DesignSystem.Typography.largeTitle)
                    .foregroundColor(DesignSystem.Colors.primaryText)

                Text(String(localized: "welcome_subtitle"))
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
                    .multilineTextAlignment(.center)
            }

            // Features
            VStack(spacing: DesignSystem.Spacing.md) {
                FeatureInfoRow(
                    icon: "sparkles",
                    iconColor: .yellow,
                    title: String(localized: "feature_visual_title"),
                    description: String(localized: "feature_visual_desc")
                )

                FeatureInfoRow(
                    icon: "checkmark.circle.fill",
                    iconColor: .green,
                    title: String(localized: "feature_auto_title"),
                    description: String(localized: "feature_auto_desc")
                )

                FeatureInfoRow(
                    icon: "command",
                    iconColor: DesignSystem.Colors.brand,
                    title: String(localized: "feature_shortcut_title"),
                    description: String(localized: "feature_shortcut_desc")
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
    }

    // MARK: - Permission Content

    private var permissionContent: some View {
        VStack(spacing: DesignSystem.Spacing.xxl) {
            // 权限图标
            ZStack {
                Circle()
                    .fill(hasAccessibilityPermission ? Color.green.opacity(0.1) : DesignSystem.Colors.brand.opacity(0.1))
                    .frame(width: 100, height: 100)

                Image(systemName: hasAccessibilityPermission ? "checkmark.shield.fill" : "hand.raised.fill")
                    .font(.system(size: 44, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: hasAccessibilityPermission
                                ? [.green, .green.opacity(0.8)]
                                : [DesignSystem.Colors.brand, DesignSystem.Colors.brandLight],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .padding(.top, DesignSystem.Spacing.xl)

            // 标题和说明
            VStack(spacing: DesignSystem.Spacing.md) {
                Text(hasAccessibilityPermission
                     ? String(localized: "permission_granted")
                     : String(localized: "permission_setup_title"))
                    .font(DesignSystem.Typography.title)
                    .foregroundColor(DesignSystem.Colors.primaryText)

                Text(hasAccessibilityPermission
                     ? String(localized: "permission_granted_desc")
                     : String(localized: "permission_setup_desc"))
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }

            // 权限说明卡片
            if !hasAccessibilityPermission {
                VStack(spacing: DesignSystem.Spacing.md) {
                    PermissionBenefitRow(
                        icon: "keyboard.fill",
                        title: String(localized: "permission_benefit_1_title"),
                        description: String(localized: "permission_benefit_1_desc")
                    )

                    PermissionBenefitRow(
                        icon: "sparkles",
                        title: String(localized: "permission_benefit_2_title"),
                        description: String(localized: "permission_benefit_2_desc")
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

                // 授权按钮
                Button(action: requestPermission) {
                    HStack(spacing: DesignSystem.Spacing.sm) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 13, weight: .medium))
                        Text(String(localized: "open_system_settings"))
                    }
                    .font(DesignSystem.Typography.bodySemibold)
                    .foregroundColor(DesignSystem.Colors.brand)
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                    .padding(.vertical, DesignSystem.Spacing.sm)
                    .background(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
                            .fill(DesignSystem.Colors.brand.opacity(0.1))
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Button Section

    private var buttonSection: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            if currentStep == .permission && !hasAccessibilityPermission {
                // 跳过按钮
                Button(action: onDismiss) {
                    Text(String(localized: "skip_for_now"))
                        .font(DesignSystem.Typography.bodyMedium)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                        .padding(.horizontal, DesignSystem.Spacing.lg)
                        .padding(.vertical, DesignSystem.Spacing.md)
                }
                .buttonStyle(.plain)
            }

            // 主按钮
            BrandButton(
                title: buttonTitle,
                showArrow: currentStep == .intro || hasAccessibilityPermission,
                action: handlePrimaryAction
            )
            .keyboardShortcut(.defaultAction)
        }
    }

    private var buttonTitle: String {
        switch currentStep {
        case .intro:
            return String(localized: "continue")
        case .permission:
            return hasAccessibilityPermission
                ? String(localized: "get_started")
                : String(localized: "i_have_enabled")
        }
    }

    // MARK: - Actions

    private func handlePrimaryAction() {
        switch currentStep {
        case .intro:
            withAnimation(DesignSystem.Animation.smooth) {
                showContent = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                currentStep = .permission
                withAnimation(DesignSystem.Animation.smooth) {
                    showContent = true
                }
            }
        case .permission:
            // 刷新权限状态
            let granted = AXIsProcessTrusted()
            if granted {
                withAnimation(DesignSystem.Animation.spring) {
                    hasAccessibilityPermission = true
                }
                // 短暂延迟后关闭，让用户看到成功状态
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    onDismiss()
                }
            } else {
                // 权限未授予，再次请求
                requestPermission()
            }
        }
    }

    private func requestPermission() {
        // 请求权限 - 系统会弹出对话框，用户点击后自动打开设置并添加应用到列表
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        let result = AXIsProcessTrustedWithOptions(options)

        // 如果已经有权限，直接更新状态
        if result {
            withAnimation(DesignSystem.Animation.spring) {
                hasAccessibilityPermission = true
            }
            return
        }

        // 开始轮询检查权限状态
        startPermissionPolling()
    }

    private func startPermissionPolling() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            let granted = AXIsProcessTrusted()
            if granted {
                timer.invalidate()
                DispatchQueue.main.async {
                    withAnimation(DesignSystem.Animation.spring) {
                        hasAccessibilityPermission = true
                    }
                }
            }
        }
    }
}

// MARK: - Permission Benefit Row

private struct PermissionBenefitRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: DesignSystem.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(DesignSystem.Colors.brand)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(DesignSystem.Typography.bodySemibold)
                    .foregroundColor(DesignSystem.Colors.primaryText)

                Text(description)
                    .font(DesignSystem.Typography.callout)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
            }

            Spacer(minLength: 0)
        }
    }
}

// MARK: - Preview

#Preview("Welcome Flow") {
    WelcomeView(onDismiss: {})
}
