import SwiftUI
import Combine

// MARK: - 清洁主界面

struct CleaningView: View {
    @ObservedObject var stateManager: CleaningStateManager
    @ObservedObject var permissionManager: PermissionManager

    let onExit: () -> Void

    @State private var escPressStartTime: Date?
    @State private var escHoldProgress: CGFloat = 0
    @State private var escTimer: Timer?
    @State private var showTitle = false
    @State private var showKeyboard = false

    private var cleanedKeys: Set<UInt16> {
        if case .cleaning(let keys) = stateManager.state {
            return keys
        }
        return []
    }

    private var progressPercentage: Double {
        guard stateManager.totalKeys > 0 else { return 0 }
        return Double(stateManager.cleanedCount) / Double(stateManager.totalKeys)
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 沉浸式深色背景
                backgroundGradient
                    .ignoresSafeArea()

                // Content based on state
                switch stateManager.state {
                case .idle:
                    if !permissionManager.hasAccessibilityPermission {
                        PermissionGuideView(
                            permissionManager: permissionManager,
                            onDismiss: onExit
                        )
                        .transition(.opacity)
                    }

                case .cleaning:
                    cleaningContent(geometry: geometry)
                        .onReceive(stateManager.$isEscPressed) { newValue in
                            if newValue {
                                handleEscPress()
                            } else {
                                handleEscRelease()
                            }
                        }
                        .onAppear {
                            withAnimation(DesignSystem.Animation.smooth.delay(0.1)) {
                                showTitle = true
                            }
                            withAnimation(DesignSystem.Animation.smooth.delay(0.3)) {
                                showKeyboard = true
                            }
                        }
                        .onDisappear {
                            // Clean up timer when view disappears
                            escTimer?.invalidate()
                            escTimer = nil
                        }

                case .completed:
                    CompletionView(onComplete: onExit)
                        .transition(.scale.combined(with: .opacity))

                case .exiting:
                    EmptyView()
                }
            }
        }
    }

    // MARK: - Background

    private var backgroundGradient: some View {
        ZStack {
            // 主背景色
            DesignSystem.Colors.immersiveBackground

            // 微妙的径向渐变
            RadialGradient(
                colors: [
                    DesignSystem.Colors.immersiveSecondary,
                    DesignSystem.Colors.immersiveBackground
                ],
                center: .center,
                startRadius: 100,
                endRadius: 600
            )

            // 顶部微光
            LinearGradient(
                colors: [
                    Color.white.opacity(0.015),
                    Color.clear
                ],
                startPoint: .top,
                endPoint: .center
            )
        }
    }

    // MARK: - Cleaning Content

    @ViewBuilder
    private func cleaningContent(geometry: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            Spacer()

            // Title and progress
            titleSection
                .opacity(showTitle ? 1 : 0)
                .offset(y: showTitle ? 0 : 15)

            Spacer().frame(height: DesignSystem.Spacing.xxxl)

            // Keyboard
            keyboardSection(geometry: geometry)
                .opacity(showKeyboard ? 1 : 0)
                .scaleEffect(showKeyboard ? 1 : 0.96)

            Spacer()

            // Bottom instructions
            bottomSection
                .padding(.bottom, DesignSystem.Spacing.xxxl)
        }
    }

    // MARK: - Title Section

    private var titleSection: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            // App title
            Text("CleanLock")
                .font(.system(size: 38, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, .white.opacity(0.85)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: DesignSystem.Colors.brand.opacity(0.25), radius: 16)

            // Instruction
            Text("擦拭键盘，按下的键会亮起")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.white.opacity(0.5))

            // Progress
            progressIndicator
        }
    }

    // MARK: - Progress Indicator

    private var progressIndicator: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    // Track
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.white.opacity(0.08))

                    // Fill
                    RoundedRectangle(cornerRadius: 3)
                        .fill(
                            LinearGradient(
                                colors: [
                                    DesignSystem.Colors.brand,
                                    DesignSystem.Colors.brandLight
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * progressPercentage)
                        .animation(DesignSystem.Animation.standard, value: progressPercentage)
                }
            }
            .frame(width: 180, height: 5)

            // Count text
            HStack(spacing: DesignSystem.Spacing.xs) {
                Text("\(stateManager.cleanedCount)")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(DesignSystem.Colors.brand)

                Text("/")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.3))

                Text("\(stateManager.totalKeys)")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.45))

                Text("键")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.3))
            }
        }
    }

    // MARK: - Keyboard Section

    private func keyboardSection(geometry: GeometryProxy) -> some View {
        let maxWidth = geometry.size.width - 80
        let maxHeight = geometry.size.height * 0.42
        let baseKeySize = min(maxWidth / 16.5, maxHeight / 7.5, 50)

        return KeyboardView(
            layout: .macBook,
            cleanedKeys: cleanedKeys,
            baseKeySize: baseKeySize
        )
        .shadow(color: Color.black.opacity(0.4), radius: 24, y: 12)
    }

    // MARK: - Bottom Section

    private var bottomSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            // Esc hold progress indicator
            if escHoldProgress > 0 {
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.1), lineWidth: 2.5)
                        .frame(width: 44, height: 44)

                    Circle()
                        .trim(from: 0, to: escHoldProgress)
                        .stroke(
                            DesignSystem.Colors.brand,
                            style: StrokeStyle(lineWidth: 2.5, lineCap: .round)
                        )
                        .frame(width: 44, height: 44)
                        .rotationEffect(.degrees(-90))

                    Text("esc")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.white.opacity(0.7))
                }
                .transition(.scale.combined(with: .opacity))
            }

            // Instruction text
            HStack(spacing: DesignSystem.Spacing.xs) {
                Image(systemName: "escape")
                    .font(.system(size: 11, weight: .medium))

                Text("长按 ESC 3秒退出")
                    .font(.system(size: 12, weight: .medium))
            }
            .foregroundColor(.white.opacity(0.35))
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .background(
                Capsule()
                    .fill(Color.white.opacity(0.04))
            )
        }
        .animation(DesignSystem.Animation.quick, value: escHoldProgress > 0)
    }

    // MARK: - Esc Key Handling

    func handleEscPress() {
        if escPressStartTime == nil {
            escPressStartTime = Date()
            startEscTimer()
        }
    }

    func handleEscRelease() {
        escPressStartTime = nil
        escTimer?.invalidate()
        escTimer = nil
        withAnimation(DesignSystem.Animation.quick) {
            escHoldProgress = 0
        }
    }

    private func startEscTimer() {
        escTimer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { _ in
            guard let startTime = escPressStartTime else { return }
            let elapsed = Date().timeIntervalSince(startTime)
            let progress = min(elapsed / 3.0, 1.0)

            withAnimation(.linear(duration: 0.03)) {
                escHoldProgress = progress
            }

            if progress >= 1.0 {
                escTimer?.invalidate()
                escTimer = nil
                onExit()
            }
        }
    }
}

// MARK: - Preview

#Preview {
    CleaningView(
        stateManager: CleaningStateManager(),
        permissionManager: PermissionManager(),
        onExit: {}
    )
}
