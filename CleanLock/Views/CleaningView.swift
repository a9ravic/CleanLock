import SwiftUI

struct CleaningView: View {
    @ObservedObject var stateManager: CleaningStateManager
    @ObservedObject var permissionManager: PermissionManager

    let onExit: () -> Void

    @State private var escPressStartTime: Date?
    @State private var escHoldProgress: CGFloat = 0
    @State private var escTimer: Timer?

    private var cleanedKeys: Set<UInt16> {
        if case .cleaning(let keys) = stateManager.state {
            return keys
        }
        return []
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background - adapts to light/dark mode
                Color(nsColor: .windowBackgroundColor)
                    .ignoresSafeArea()

                // Content based on state
                switch stateManager.state {
                case .idle:
                    if !permissionManager.hasAccessibilityPermission {
                        PermissionGuideView(
                            permissionManager: permissionManager,
                            onDismiss: onExit
                        )
                    }

                case .cleaning:
                    cleaningContent(geometry: geometry)
                        .onChange(of: stateManager.isEscPressed) { isPressed in
                            if isPressed {
                                handleEscPress()
                            } else {
                                handleEscRelease()
                            }
                        }

                case .completed:
                    CompletionView(onComplete: onExit)

                case .exiting:
                    EmptyView()
                }
            }
        }
    }

    @ViewBuilder
    private func cleaningContent(geometry: GeometryProxy) -> some View {
        VStack(spacing: 32) {
            // Header with exit button
            HStack {
                Spacer()
                Button(action: onExit) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .padding()
            }

            Spacer()

            // Title and progress
            VStack(spacing: 16) {
                Text("CleanLock")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)

                Text("擦拭键盘，按下的键会亮起")
                    .font(.system(size: 18))
                    .foregroundColor(.secondary)

                Text("进度: \(stateManager.cleanedCount)/\(stateManager.totalKeys) 键")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.accentColor)
            }

            // Keyboard
            let baseKeySize = min(geometry.size.width / 18, 50.0)
            KeyboardView(
                layout: .macBook,
                cleanedKeys: cleanedKeys,
                baseKeySize: baseKeySize
            )

            Spacer()

            // Esc hold indicator
            VStack(spacing: 8) {
                if escHoldProgress > 0 {
                    ZStack {
                        Circle()
                            .stroke(Color.secondary.opacity(0.3), lineWidth: 4)
                            .frame(width: 40, height: 40)

                        Circle()
                            .trim(from: 0, to: escHoldProgress)
                            .stroke(Color.accentColor, lineWidth: 4)
                            .frame(width: 40, height: 40)
                            .rotationEffect(.degrees(-90))
                    }
                }

                Text("长按 Esc 3秒可退出")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 32)
        }
    }

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
        escTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            guard let startTime = escPressStartTime else { return }
            let elapsed = Date().timeIntervalSince(startTime)
            let progress = min(elapsed / 3.0, 1.0)

            withAnimation(.linear(duration: 0.05)) {
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

#Preview {
    CleaningView(
        stateManager: CleaningStateManager(),
        permissionManager: PermissionManager(),
        onExit: {}
    )
}
