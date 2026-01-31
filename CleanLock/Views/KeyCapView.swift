import SwiftUI

struct KeyCapView: View {
    let key: Key
    let isCleaned: Bool
    let baseSize: CGFloat

    @State private var isPressed = false

    private var keyWidth: CGFloat {
        baseSize * key.width + (key.width - 1) * 4
    }

    private var keyHeight: CGFloat {
        baseSize
    }

    var body: some View {
        Group {
            if key.isPlaceholder {
                // 占位符：透明空白，保持布局
                Color.clear
                    .frame(width: keyWidth, height: keyHeight)
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(isCleaned ? Color.accentColor : Color(nsColor: .controlBackgroundColor))
                        .shadow(color: .black.opacity(0.2), radius: 1, y: 1)

                    Text(key.label)
                        .font(.system(size: baseSize * 0.35, weight: .medium, design: .rounded))
                        .foregroundColor(isCleaned ? .white : .primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                }
                .frame(width: keyWidth, height: keyHeight)
                .scaleEffect(isPressed ? 0.95 : 1.0)
                .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
                .animation(.easeInOut(duration: 0.2), value: isCleaned)
            }
        }
    }

    func triggerPress() {
        isPressed = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            isPressed = false
        }
    }
}

#Preview {
    HStack(spacing: 8) {
        KeyCapView(key: Key(keyCode: 53, label: "esc"), isCleaned: false, baseSize: 50)
        KeyCapView(key: Key(keyCode: 49, label: "space", width: 3.0), isCleaned: true, baseSize: 50)
    }
    .padding()
    .background(Color(nsColor: .windowBackgroundColor))
}
