import SwiftUI

struct CompletionView: View {
    @State private var showCheckmark = false
    @State private var countdown = 3

    let onComplete: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
                .scaleEffect(showCheckmark ? 1.0 : 0.5)
                .opacity(showCheckmark ? 1.0 : 0.0)

            Text("清洁完成！")
                .font(.system(size: 32, weight: .semibold, design: .rounded))
                .foregroundColor(.primary)

            Text("即将退出... (\(countdown))")
                .font(.system(size: 18, weight: .regular))
                .foregroundColor(.secondary)
        }
        .padding(48)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                showCheckmark = true
            }
            startCountdown()
        }
    }

    private func startCountdown() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if countdown > 1 {
                countdown -= 1
            } else {
                timer.invalidate()
                onComplete()
            }
        }
    }
}

#Preview {
    ZStack {
        Color.black.opacity(0.5)
        CompletionView(onComplete: {})
    }
}
