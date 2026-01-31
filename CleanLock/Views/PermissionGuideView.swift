import SwiftUI

// MARK: - 权限引导视图

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
            withAnimation(DesignSystem.Animation.smooth) {
                showContent = true
            }
            // 启动脉冲动画
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
                .frame(width: 92, height: 92)
                .scaleEffect(pulseAnimation ? 1.15 : 1.0)
                .opacity(pulseAnimation ? 0.3 : 0.7)

            // 内圈
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            DesignSystem.Colors.brand.opacity(0.18),
                            DesignSystem.Colors.brand.opacity(0.05)
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 40
                    )
                )
                .frame(width: 84, height: 84)

            // 图标
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 40, weight: .medium))
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
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, .white.opacity(0.85)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            Text("为了在清洁时拦截键盘输入防止误触，\n请在系统设置中授予辅助功能权限")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.5))
                .multilineTextAlignment(.center)
                .lineSpacing(3)
        }
    }

    // MARK: - Button Section

    private var buttonSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            BrandButton(
                title: "打开系统设置",
                icon: "gearshape.fill",
                action: { permissionManager.openAccessibilitySettings() }
            )

            Button(action: onDismiss) {
                Text("稍后再说")
                    .font(DesignSystem.Typography.bodyMedium)
                    .foregroundColor(.white.opacity(0.4))
            }
            .buttonStyle(.plain)
        }
        .frame(width: 240)
    }

    // MARK: - Card Background

    private var cardBackground: some View {
        ImmersiveCardBackground()
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        DesignSystem.Colors.immersiveBackground
            .ignoresSafeArea()

        PermissionGuideView(
            permissionManager: PermissionManager(),
            onDismiss: {}
        )
    }
}
