import SwiftUI

// MARK: - 完成视图

struct CompletionView: View {
    @State private var showCheckmark = false
    @State private var showRing = false
    @State private var showText = false
    @State private var countdown = 3
    @State private var pulseScale: CGFloat = 1.0
    @State private var countdownTimer: Timer?

    let onComplete: () -> Void

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xxl) {
            // 成功图标
            successIcon
                .scaleEffect(showCheckmark ? 1.0 : 0.4)
                .opacity(showCheckmark ? 1.0 : 0.0)

            // 文字内容
            VStack(spacing: DesignSystem.Spacing.sm) {
                Text("清洁完成！")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, .white.opacity(0.85)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                Text("即将退出... (\(countdown))")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white.opacity(0.45))
            }
            .opacity(showText ? 1 : 0)
            .offset(y: showText ? 0 : 8)
        }
        .padding(DesignSystem.Spacing.xxxl + DesignSystem.Spacing.lg)
        .background(cardBackground)
        .onAppear {
            startAnimations()
        }
        .onDisappear {
            // Clean up timer when view disappears
            countdownTimer?.invalidate()
            countdownTimer = nil
        }
    }

    // MARK: - Success Icon

    private var successIcon: some View {
        ZStack {
            // 外圈脉冲动画
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [
                            DesignSystem.Colors.success.opacity(0.35),
                            DesignSystem.Colors.success.opacity(0.1)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 2.5
                )
                .frame(width: 92, height: 92)
                .scaleEffect(pulseScale)
                .opacity(showRing ? 1 : 0)

            // 主圆圈
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            DesignSystem.Colors.success,
                            DesignSystem.Colors.success.opacity(0.85)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 80, height: 80)
                .shadow(color: DesignSystem.Colors.success.opacity(0.35), radius: 16, y: 4)

            // 对勾
            Image(systemName: "checkmark")
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(.white)
        }
    }

    // MARK: - Card Background

    private var cardBackground: some View {
        ImmersiveCardBackground()
    }

    // MARK: - Animations

    private func startAnimations() {
        // 对勾弹出
        withAnimation(DesignSystem.Animation.bouncy) {
            showCheckmark = true
        }

        // 光环出现
        withAnimation(DesignSystem.Animation.standard.delay(0.2)) {
            showRing = true
        }

        // 文字淡入
        withAnimation(DesignSystem.Animation.standard.delay(0.3)) {
            showText = true
        }

        // 脉冲动画
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true).delay(0.5)) {
            pulseScale = 1.12
        }

        // 倒计时
        startCountdown()
    }

    private func startCountdown() {
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [self] timer in
            if countdown > 1 {
                countdown -= 1
            } else {
                timer.invalidate()
                countdownTimer = nil
                onComplete()
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        // 模拟清洁界面的背景
        DesignSystem.Colors.immersiveBackground
            .ignoresSafeArea()

        CompletionView(onComplete: {})
    }
}
