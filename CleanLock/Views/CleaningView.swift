import SwiftUI
import Combine

// MARK: - macOS Native Cleaning View

struct CleaningView: View {
    @ObservedObject var stateManager: CleaningStateManager
    @ObservedObject var permissionManager: PermissionManager

    let onExit: () -> Void

    @State private var escPressStartTime: Date?
    @State private var escHoldProgress: CGFloat = 0
    @State private var escTimer: Timer?
    @State private var showContent = false

    @Environment(\.colorScheme) private var colorScheme

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
                // macOS 原生毛玻璃背景
                nativeBackground

                // Content based on state
                switch stateManager.state {
                case .idle:
                    if !permissionManager.hasAccessibilityPermission {
                        PermissionGuideView(
                            permissionManager: permissionManager,
                            onDismiss: onExit
                        )
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
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
                            print("🟡 [CleaningView] .cleaning case appeared")
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                showContent = true
                            }
                        }
                        .onDisappear {
                            print("🟡 [CleaningView] .cleaning case disappeared")
                            escTimer?.invalidate()
                            escTimer = nil
                        }

                case .completed:
                    CompletionView(onComplete: {
                        print("🟡 [CleaningView] CompletionView onComplete triggered, calling onExit")
                        onExit()
                    })
                        .id(stateManager.completionId)  // 强制 SwiftUI 每次创建新实例
                        .transition(.scale(scale: 0.9).combined(with: .opacity))
                        .onAppear {
                            print("🟡 [CleaningView] .completed case appeared, completionId=\(stateManager.completionId)")
                        }

                case .exiting:
                    EmptyView()
                        .onAppear {
                            print("🟡 [CleaningView] .exiting case appeared")
                        }
                }
            }
            .animation(.easeInOut(duration: 0.3), value: stateManager.state)
        }
    }

    // MARK: - Native Background

    private var nativeBackground: some View {
        ZStack {
            // 基础毛玻璃层
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()

            // 微妙的品牌色渐变叠加
            RadialGradient(
                colors: [
                    DesignSystem.Colors.brand.opacity(0.08),
                    Color.clear
                ],
                center: .center,
                startRadius: 100,
                endRadius: 500
            )
            .ignoresSafeArea()
        }
    }

    // MARK: - Cleaning Content

    @ViewBuilder
    private func cleaningContent(geometry: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            Spacer()

            // 标题和进度
            headerSection
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)

            Spacer().frame(height: DesignSystem.Spacing.xxxl)

            // 键盘视图
            keyboardSection(geometry: geometry)
                .opacity(showContent ? 1 : 0)
                .scaleEffect(showContent ? 1 : 0.95)

            Spacer()

            // 底部退出提示
            exitHintSection
                .padding(.bottom, DesignSystem.Spacing.xxl)
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            // App 标题
            HStack(spacing: DesignSystem.Spacing.sm) {
                Image(systemName: "keyboard.fill")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundStyle(DesignSystem.Colors.brand)

                Text("CleanLock")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(DesignSystem.Colors.primaryText)
            }

            // 说明文字
            Text("擦拭键盘，按下的键会亮起")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(DesignSystem.Colors.secondaryText)

            // 进度指示器
            progressIndicator
        }
    }

    // MARK: - Progress Indicator

    private var progressIndicator: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            // 进度条
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    // 轨道
                    RoundedRectangle(cornerRadius: 3)
                        .fill(DesignSystem.Colors.separator.opacity(0.3))

                    // 填充
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
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: progressPercentage)
                }
            }
            .frame(width: 200, height: 6)

            // 计数
            HStack(spacing: DesignSystem.Spacing.xs) {
                Text("\(stateManager.cleanedCount)")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(DesignSystem.Colors.brand)

                Text("/")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(DesignSystem.Colors.tertiaryText)

                Text("\(stateManager.totalKeys)")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(DesignSystem.Colors.secondaryText)

                Text("键")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(DesignSystem.Colors.tertiaryText)
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
        .shadow(color: Color.black.opacity(0.2), radius: 20, y: 8)
    }

    // MARK: - Exit Hint Section

    private var exitHintSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            // ESC 长按进度
            if escHoldProgress > 0 {
                ZStack {
                    Circle()
                        .stroke(DesignSystem.Colors.separator.opacity(0.3), lineWidth: 3)
                        .frame(width: 48, height: 48)

                    Circle()
                        .trim(from: 0, to: escHoldProgress)
                        .stroke(
                            DesignSystem.Colors.brand,
                            style: StrokeStyle(lineWidth: 3, lineCap: .round)
                        )
                        .frame(width: 48, height: 48)
                        .rotationEffect(.degrees(-90))

                    Text("esc")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                }
                .transition(.scale.combined(with: .opacity))
            }

            // 提示文字
            HStack(spacing: DesignSystem.Spacing.xs) {
                Image(systemName: "escape")
                    .font(.system(size: 11, weight: .medium))

                Text("长按 ESC 3秒退出")
                    .font(.system(size: 12, weight: .medium))
            }
            .foregroundColor(DesignSystem.Colors.tertiaryText)
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .background(
                Capsule()
                    .fill(.regularMaterial)
            )
            .overlay(
                Capsule()
                    .strokeBorder(DesignSystem.Colors.separator.opacity(0.3), lineWidth: 0.5)
            )
        }
        .animation(.easeInOut(duration: 0.2), value: escHoldProgress > 0)
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
        withAnimation(.easeOut(duration: 0.2)) {
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

#Preview("Cleaning Mode") {
    CleaningView(
        stateManager: {
            let manager = CleaningStateManager()
            manager.startCleaning()
            return manager
        }(),
        permissionManager: PermissionManager(),
        onExit: {}
    )
}
