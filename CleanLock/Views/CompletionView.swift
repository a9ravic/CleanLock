import SwiftUI

// MARK: - macOS Native Completion View

struct CompletionView: View {
    @State private var showContent = false
    @State private var ringProgress: CGFloat = 0
    @State private var completionTask: Task<Void, Never>?

    private let duration: Double = 1.7
    let onComplete: () -> Void

    var body: some View {
        // 居中显示
        ZStack {
            // 成功图标 + 环形进度
            ZStack {
                // 环形进度轨道
                Circle()
                    .stroke(
                        DesignSystem.Colors.success.opacity(0.2),
                        lineWidth: 4
                    )
                    .frame(width: 96, height: 96)

                // 环形进度填充
                Circle()
                    .trim(from: 0, to: ringProgress)
                    .stroke(
                        DesignSystem.Colors.success.opacity(0.6),
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: 96, height: 96)
                    .rotationEffect(.degrees(-90))

                // 成功圆形背景
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
            .scaleEffect(showContent ? 1.0 : 0.5)
            .opacity(showContent ? 1.0 : 0.0)

            // 文字 - 位于圆形下方
            VStack {
                Spacer()
                    .frame(height: 130)

                Text(String(localized: "cleaning_complete"))
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(DesignSystem.Colors.secondaryText)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 8)
            }
        }
        .frame(width: 160, height: 180)
        .padding(DesignSystem.Spacing.xl)
        .background(cardBackground)
        .onAppear {
            resetState()
            startAnimations()
        }
        .onDisappear {
            completionTask?.cancel()
            completionTask = nil
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
        showContent = false
        ringProgress = 0
        completionTask?.cancel()
        completionTask = nil
    }

    // MARK: - Animations

    private func startAnimations() {
        // 内容弹出
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            showContent = true
        }

        // 环形进度动画 - 使用线性动画确保平滑
        withAnimation(.linear(duration: duration).delay(0.3)) {
            ringProgress = 1.0
        }

        // 完成回调 - 使用可取消的 Task 替代 asyncAfter
        let totalDelay = duration + 0.3
        completionTask = Task { @MainActor in
            do {
                try await Task.sleep(for: .seconds(totalDelay))
                guard !Task.isCancelled else { return }
                onComplete()
            } catch {
                // Task 被取消，不执行回调
            }
        }
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
