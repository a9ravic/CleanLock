import SwiftUI

struct KeyboardView: View {
    let layout: KeyboardLayout
    let cleanedKeys: Set<UInt16>
    let baseKeySize: CGFloat

    var body: some View {
        VStack(spacing: 4) {
            ForEach(Array(layout.rows.enumerated()), id: \.offset) { _, row in
                HStack(spacing: 4) {
                    ForEach(row) { key in
                        KeyCapView(
                            key: key,
                            isCleaned: cleanedKeys.contains(key.keyCode),
                            baseSize: baseKeySize
                        )
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(nsColor: .controlBackgroundColor))
        )
    }
}

#Preview {
    KeyboardView(
        layout: .macBook,
        cleanedKeys: [53, 18, 19, 20],
        baseKeySize: 40
    )
    .padding()
    .background(Color(nsColor: .windowBackgroundColor))
}
