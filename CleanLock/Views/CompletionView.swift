import SwiftUI

// MARK: - macOS Native Completion View

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
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(DesignSystem.Colors.primaryText)

                Text("即将退出... (\(countdown))")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(DesignSystem.Colors.secondaryText)
            }
            .opacity(showText ? 1 : 0)
            .offset(y: showText ? 0 : 8)
        }
        .padding(DesignSystem.Spacing.xxxl + DesignSystem.Spacing.md)
        .background(cardBackground)
        .onAppear {
            print("🟢 [CompletionView] onAppear called!")
            // 重置所有状态，确保第二次及后续使用时状态正确
            resetState()
            startAnimations()
        }
        .onDisappear {
            print("🟢 [CompletionView] onDisappear called!")
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
                    DesignSystem.Colors.success.opacity(0.3),
                    lineWidth: 2
                )
                .frame(width: 88, height: 88)
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
                .frame(width: 72, height: 72)
                .shadow(color: DesignSystem.Colors.success.opacity(0.3), radius: 12, y: 4)

            // 对勾
            Image(systemName: "checkmark")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.white)
        }
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

    // MARK: - State Management

    private func resetState() {
        print("🟢 [CompletionView] resetState() called")
        // 确保每次显示时状态都是初始值
        showCheckmark = false
        showRing = false
        showText = false
        countdown = 3
        pulseScale = 1.0
        countdownTimer?.invalidate()
        countdownTimer = nil
        print("🟢 [CompletionView] State reset complete, countdown=\(countdown)")
    }

    // MARK: - Animations

    private func startAnimations() {
        // 对勾弹出
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            showCheckmark = true
        }

        // 光环出现
        withAnimation(.easeOut(duration: 0.3).delay(0.2)) {
            showRing = true
        }

        // 文字淡入
        withAnimation(.easeOut(duration: 0.3).delay(0.3)) {
            showText = true
        }

        // 脉冲动画
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true).delay(0.5)) {
            pulseScale = 1.1
        }

        // 倒计时
        startCountdown()
    }

    private func startCountdown() {
        print("🟢 [CompletionView] startCountdown() called, creating timer...")
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            print("🟢 [CompletionView] Timer fired! countdown=\(countdown)")
            if countdown > 1 {
                countdown -= 1
                print("🟢 [CompletionView] Countdown decremented to \(countdown)")
            } else {
                print("🟢 [CompletionView] Countdown finished, invalidating timer and calling onComplete...")
                timer.invalidate()
                countdownTimer = nil
                print("🟢 [CompletionView] About to call onComplete()")
                onComplete()
                print("🟢 [CompletionView] onComplete() returned")
            }
        }
        print("🟢 [CompletionView] Timer created: \(String(describing: countdownTimer))")
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Rectangle()
            .fill(.ultraThinMaterial)
            .ignoresSafeArea()

        CompletionView(onComplete: {})
    }
}
