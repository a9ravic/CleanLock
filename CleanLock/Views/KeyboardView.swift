import SwiftUI

// MARK: - 完整键盘视图

struct KeyboardView: View {
    let layout: KeyboardLayout
    let cleanedKeys: Set<UInt16>
    let baseKeySize: CGFloat

    // 键间距（键大小的百分比）
    private var keySpacing: CGFloat {
        baseKeySize * 0.06
    }

    // 功能键高度比例（相对于普通键）
    private let functionKeyHeightRatio: CGFloat = 0.52

    var body: some View {
        VStack(spacing: 0) {
            // 功能键行（Row 0）- 矮键设计
            functionRow
                .padding(.bottom, keySpacing * 1.5)

            // 主键盘区域（Row 1-5）
            mainKeyboardArea
        }
        .padding(.horizontal, baseKeySize * 0.35)
        .padding(.vertical, baseKeySize * 0.3)
        .background(keyboardBackground)
    }

    // MARK: - Function Row（功能键行 - 矮键）

    private var functionRow: some View {
        HStack(spacing: keySpacing) {
            ForEach(layout.rows[0]) { key in
                KeyCapView(
                    key: key,
                    isCleaned: cleanedKeys.contains(key.keyCode),
                    baseSize: baseKeySize,
                    heightMultiplier: functionKeyHeightRatio
                )
            }
        }
    }

    // MARK: - Main Keyboard Area

    private var mainKeyboardArea: some View {
        VStack(spacing: keySpacing) {
            // Row 1: Number row
            standardRow(rowIndex: 1)

            // Row 2: QWERTY row
            standardRow(rowIndex: 2)

            // Row 3: Home row
            standardRow(rowIndex: 3)

            // Row 4: Shift row
            standardRow(rowIndex: 4)

            // Row 5: Bottom row with special arrow keys layout
            bottomRowWithArrows
        }
    }

    // MARK: - Standard Row

    private func standardRow(rowIndex: Int) -> some View {
        HStack(spacing: keySpacing) {
            ForEach(layout.rows[rowIndex]) { key in
                KeyCapView(
                    key: key,
                    isCleaned: cleanedKeys.contains(key.keyCode),
                    baseSize: baseKeySize
                )
            }
        }
    }

    // MARK: - Bottom Row with Inverted-T Arrow Keys

    private var bottomRowWithArrows: some View {
        let row = layout.rows[5]
        let modifierKeys = Array(row.dropLast(4))
        let arrowKeys = Array(row.suffix(4))

        return HStack(spacing: keySpacing) {
            // 修饰键区域
            ForEach(modifierKeys) { key in
                KeyCapView(
                    key: key,
                    isCleaned: cleanedKeys.contains(key.keyCode),
                    baseSize: baseKeySize
                )
            }

            // 箭头键区域 - 倒 T 形布局
            arrowKeysView(keys: arrowKeys)
        }
    }

    // MARK: - Arrow Keys (Inverted-T Layout)

    @ViewBuilder
    private func arrowKeysView(keys: [Key]) -> some View {
        if keys.count == 4 {
            let leftArrow = keys[0]
            let upArrow = keys[1]
            let downArrow = keys[2]
            let rightArrow = keys[3]

            let halfKeySpacing = keySpacing * 0.5

            HStack(spacing: keySpacing) {
                // 左箭头（全高）
                KeyCapView(
                    key: leftArrow,
                    isCleaned: cleanedKeys.contains(leftArrow.keyCode),
                    baseSize: baseKeySize
                )

                // 上下箭头（垂直堆叠，各占半高）
                VStack(spacing: halfKeySpacing) {
                    KeyCapView(
                        key: Key(
                            keyCode: upArrow.keyCode,
                            label: upArrow.label,
                            width: 1.0,
                            height: 0.47,
                            symbolName: upArrow.symbolName
                        ),
                        isCleaned: cleanedKeys.contains(upArrow.keyCode),
                        baseSize: baseKeySize
                    )

                    KeyCapView(
                        key: Key(
                            keyCode: downArrow.keyCode,
                            label: downArrow.label,
                            width: 1.0,
                            height: 0.47,
                            symbolName: downArrow.symbolName
                        ),
                        isCleaned: cleanedKeys.contains(downArrow.keyCode),
                        baseSize: baseKeySize
                    )
                }

                // 右箭头（全高）
                KeyCapView(
                    key: rightArrow,
                    isCleaned: cleanedKeys.contains(rightArrow.keyCode),
                    baseSize: baseKeySize
                )
            }
        } else {
            EmptyView()
        }
    }

    // MARK: - Keyboard Background

    private var keyboardBackground: some View {
        ZStack {
            // 键盘底座主体
            RoundedRectangle(cornerRadius: baseKeySize * 0.25, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            DesignSystem.Colors.keyboardBase.opacity(0.95),
                            DesignSystem.Colors.keyboardBase
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            // 顶部微光边框
            RoundedRectangle(cornerRadius: baseKeySize * 0.25, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.06),
                            Color.white.opacity(0.02),
                            Color.clear
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 1
                )
        }
    }
}

// MARK: - Preview

#Preview("MacBook Keyboard") {
    ScrollView {
        VStack(spacing: 40) {
            // 默认尺寸
            KeyboardView(
                layout: .macBook,
                cleanedKeys: [],
                baseKeySize: 44
            )

            // 部分清洁状态
            KeyboardView(
                layout: .macBook,
                cleanedKeys: [53, 18, 19, 20, 0, 1, 2],
                baseKeySize: 44
            )

            // 更多清洁
            KeyboardView(
                layout: .macBook,
                cleanedKeys: [53, 18, 19, 20, 21, 22, 23, 0, 1, 2, 3, 49, 123, 124, 125, 126],
                baseKeySize: 44
            )
        }
        .padding(40)
    }
    .frame(width: 900, height: 900)
    .background(DesignSystem.Colors.immersiveBackground)
}
