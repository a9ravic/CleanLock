import SwiftUI

// MARK: - macOS Native Permission Guide View

struct PermissionGuideView: View {
    @ObservedObject var permissionManager: PermissionManager
    let onDismiss: () -> Void

    @State private var showContent = false
    @State private var pulseAnimation = false

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xxl) {
            // Icon
            iconSection
                .scaleEffect(showContent ? 1 : 0.85)
                .opacity(showContent ? 1 : 0)

            // Text content
            textSection
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 8)

            // Buttons
            buttonSection
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 8)
        }
        .padding(DesignSystem.Spacing.xxxl)
        .background(cardBackground)
        .onAppear {
            permissionManager.startMonitoringPermission()
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                showContent = true
            }
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true).delay(0.3)) {
                pulseAnimation = true
            }
        }
        .onDisappear {
            permissionManager.stopMonitoringPermission()
        }
    }

    // MARK: - Icon Section

    private var iconSection: some View {
        ZStack {
            // 外圈脉冲
            Circle()
                .stroke(DesignSystem.Colors.brand.opacity(0.2), lineWidth: 2)
                .frame(width: 88, height: 88)
                .scaleEffect(pulseAnimation ? 1.15 : 1.0)
                .opacity(pulseAnimation ? 0.3 : 0.7)

            // 内圈背景
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            DesignSystem.Colors.brand.opacity(0.15),
                            DesignSystem.Colors.brand.opacity(0.05)
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 40
                    )
                )
                .frame(width: 80, height: 80)

            // 图标
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 36, weight: .medium))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            DesignSystem.Colors.brand,
                            DesignSystem.Colors.brandLight
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
    }

    // MARK: - Text Section

    private var textSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            Text("需要辅助功能权限")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(DesignSystem.Colors.primaryText)

            Text("为了在清洁时拦截键盘输入防止误触，\n请在系统设置中授予辅助功能权限")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(DesignSystem.Colors.secondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
        }
    }

    // MARK: - Button Section

    private var buttonSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            // 主按钮
            Button(action: { permissionManager.openAccessibilitySettings() }) {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 13, weight: .semibold))

                    Text("打开系统设置")
                        .font(.system(size: 13, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, DesignSystem.Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
                        .fill(DesignSystem.Colors.brand)
                )
                .shadow(color: DesignSystem.Colors.brand.opacity(0.25), radius: 8, y: 4)
            }
            .buttonStyle(.plain)

            // 次要按钮
            Button(action: onDismiss) {
                Text("稍后再说")
                    .font(DesignSystem.Typography.bodyMedium)
                    .foregroundColor(DesignSystem.Colors.tertiaryText)
            }
            .buttonStyle(.plain)
        }
        .frame(width: 220)
    }

    // MARK: - Card Background

    private var cardBackground: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.regularMaterial)

            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.2),
                            Color.white.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.5
                )
        }
        .shadow(color: Color.black.opacity(0.15), radius: 20, y: 8)
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Rectangle()
            .fill(.ultraThinMaterial)
            .ignoresSafeArea()

        PermissionGuideView(
            permissionManager: PermissionManager(),
            onDismiss: {}
        )
    }
}
