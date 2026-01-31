import SwiftUI

// MARK: - 单个键帽视图

struct KeyCapView: View {
    let key: Key
    let isCleaned: Bool
    let baseSize: CGFloat
    var heightMultiplier: CGFloat = 1.0  // 用于功能键的矮键设计

    @State private var isPressed = false

    // MARK: - 尺寸计算

    private var keyWidth: CGFloat {
        baseSize * key.width + (key.width - 1) * keySpacing
    }

    private var keyHeight: CGFloat {
        baseSize * key.height * heightMultiplier
    }

    private var keySpacing: CGFloat {
        baseSize * 0.06
    }

    private var cornerRadius: CGFloat {
        baseSize * 0.1
    }

    private var fontSize: CGFloat {
        let baseFontSize: CGFloat
        if key.isFunctionKey {
            baseFontSize = baseSize * 0.24
        } else if key.isModifier {
            baseFontSize = baseSize * 0.22
        } else if key.symbolName != nil && key.label.count > 3 {
            baseFontSize = baseSize * 0.2
        } else {
            baseFontSize = baseSize * 0.36
        }
        return baseFontSize * (heightMultiplier < 1.0 ? 0.9 : 1.0)
    }

    // MARK: - Body

    var body: some View {
        Group {
            if key.isPlaceholder {
                placeholderKey
            } else {
                realKey
            }
        }
    }

    // MARK: - 占位符键

    private var placeholderKey: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(DesignSystem.Colors.keyboardBase.opacity(0.4))
            .frame(width: keyWidth, height: keyHeight)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(DesignSystem.Colors.keyBorder.opacity(0.2), lineWidth: 0.5)
            )
    }

    // MARK: - 真实按键

    private var realKey: some View {
        ZStack {
            // 键帽底层阴影（模拟键帽深度）
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(DesignSystem.Colors.keyBorder)
                .offset(y: baseSize * 0.03)

            // 键帽主体
            keyBody
                .overlay(keyLabel)
        }
        .frame(width: keyWidth, height: keyHeight)
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .animation(DesignSystem.Animation.keyPress, value: isPressed)
    }

    // MARK: - 键帽主体

    @ViewBuilder
    private var keyBody: some View {
        let backgroundColor = isCleaned ? DesignSystem.Colors.keyCleaned :
            (key.isFunctionKey ? DesignSystem.Colors.keyBackground.opacity(0.7) : DesignSystem.Colors.keyBackground)

        // 使用 Canvas 替代多层 ZStack 以提升性能
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        backgroundColor,
                        backgroundColor.opacity(0.9)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .overlay(
                // 顶部高光 - 合并为单一 overlay
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(isCleaned ? 0.15 : 0.05),
                                Color.clear
                            ],
                            startPoint: .top,
                            endPoint: .center
                        )
                    )
            )
            .overlay(
                // 边框
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.06),
                                DesignSystem.Colors.keyBorder.opacity(0.8)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 0.5
                    )
            )
            // 清洁后的发光效果 - 使用 shadow 替代 blur（GPU 更高效）
            .shadow(
                color: isCleaned ? DesignSystem.Colors.keyCleanedGlow.opacity(0.4) : .clear,
                radius: baseSize * 0.08
            )
            // 仅对颜色变化应用动画，不影响子视图
            .animation(.easeOut(duration: 0.15), value: isCleaned)
    }

    // MARK: - 键帽标签

    @ViewBuilder
    private var keyLabel: some View {
        let textColor = isCleaned ? Color.white : DesignSystem.Colors.keyText

        if let symbolName = key.symbolName, !key.label.isEmpty || key.isFunctionKey {
            // 功能键或修饰键 - 显示符号
            functionOrModifierKeyLabel(symbolName: symbolName, textColor: textColor)
        } else if key.label.isEmpty {
            // 空格键 - 无标签
            EmptyView()
        } else if let secondary = key.secondaryLabel {
            // 双标签键（如数字键）
            dualLabelKey(primary: key.label, secondary: secondary, textColor: textColor)
        } else {
            // 单标签键
            singleLabelKey(label: key.label, textColor: textColor)
        }
    }

    // MARK: - 功能键/修饰键标签

    private func functionOrModifierKeyLabel(symbolName: String, textColor: Color) -> some View {
        Group {
            if key.isFunctionKey {
                // 功能键 - 只显示符号图标
                if let sfSymbol = functionKeySymbol(for: symbolName) {
                    Image(systemName: sfSymbol)
                        .font(.system(size: fontSize * 0.9, weight: .medium))
                        .foregroundColor(textColor.opacity(0.85))
                } else if symbolName == "fn" || key.label == "esc" {
                    Text(key.label)
                        .font(.system(size: fontSize * 0.85, weight: .medium))
                        .foregroundColor(textColor.opacity(0.85))
                } else {
                    Text(key.label)
                        .font(.system(size: fontSize * 0.8, weight: .medium))
                        .foregroundColor(textColor.opacity(0.85))
                }
            } else {
                // 修饰键 - 显示符号和文字
                modifierKeyLabel(symbolName: symbolName, textColor: textColor)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - 修饰键标签

    private func modifierKeyLabel(symbolName: String, textColor: Color) -> some View {
        HStack(spacing: baseSize * 0.04) {
            if symbolName == "globe" {
                // fn 键显示地球图标
                Image(systemName: "globe")
                    .font(.system(size: fontSize * 0.85, weight: .medium))
                    .foregroundColor(textColor)
            } else if let sfSymbol = modifierSymbol(for: symbolName) {
                Image(systemName: sfSymbol)
                    .font(.system(size: fontSize * 0.85, weight: .medium))
                    .foregroundColor(textColor)

                if !isSymbolOnlyKey(symbolName) && key.width > 1.1 {
                    Text(displayLabel(for: key.label))
                        .font(.system(size: fontSize * 0.75, weight: .regular))
                        .foregroundColor(textColor.opacity(0.75))
                }
            } else {
                Text(displayLabel(for: key.label))
                    .font(.system(size: fontSize * 0.85, weight: .medium))
                    .foregroundColor(textColor)
            }
        }
        .padding(.horizontal, baseSize * 0.08)
    }

    // MARK: - 双标签键

    private func dualLabelKey(primary: String, secondary: String, textColor: Color) -> some View {
        VStack(spacing: 0) {
            Text(secondary)
                .font(.system(size: fontSize * 0.55, weight: .regular))
                .foregroundColor(isCleaned ? textColor.opacity(0.8) : DesignSystem.Colors.keyText.opacity(0.5))

            Text(primary)
                .font(.system(size: fontSize * 0.9, weight: .medium))
                .foregroundColor(textColor)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - 单标签键

    private func singleLabelKey(label: String, textColor: Color) -> some View {
        Text(displayLabel(for: label))
            .font(.system(size: fontSize, weight: .medium, design: .default))
            .foregroundColor(textColor)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .lineLimit(1)
            .minimumScaleFactor(0.5)
    }

    // MARK: - Helper Methods

    private static let validFunctionKeySymbols: Set<String> = [
        "sun.min", "sun.max", "backward.fill", "playpause.fill",
        "forward.fill", "speaker.slash.fill", "speaker.wave.1.fill", "speaker.wave.3.fill"
    ]

    private func functionKeySymbol(for name: String) -> String? {
        Self.validFunctionKeySymbols.contains(name) ? name : nil
    }

    private func modifierSymbol(for name: String) -> String? {
        switch name {
        case "command": return "command"
        case "option": return "option"
        case "control": return "control"
        case "shift": return "shift"
        case "capslock": return "capslock"
        case "globe": return "globe"
        case "return": return "return"
        case "delete.left": return "delete.left"
        case "arrow.right.to.line": return "arrow.right.to.line"
        case "arrowtriangle.left.fill": return "arrowtriangle.left.fill"
        case "arrowtriangle.right.fill": return "arrowtriangle.right.fill"
        case "arrowtriangle.up.fill": return "arrowtriangle.up.fill"
        case "arrowtriangle.down.fill": return "arrowtriangle.down.fill"
        default: return nil
        }
    }

    private func isSymbolOnlyKey(_ symbolName: String) -> Bool {
        ["arrowtriangle.left.fill", "arrowtriangle.right.fill",
         "arrowtriangle.up.fill", "arrowtriangle.down.fill",
         "delete.left", "return", "arrow.right.to.line", "globe"].contains(symbolName)
    }

    private func displayLabel(for label: String) -> String {
        switch label.lowercased() {
        case "caps lock": return "caps"
        case "control": return "control"
        case "option": return "option"
        case "command": return "command"
        case "delete": return ""
        case "return": return ""
        case "tab": return ""
        case "fn": return "fn"
        default: return label
        }
    }

    func triggerPress() {
        isPressed = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            isPressed = false
        }
    }
}

// MARK: - Preview

#Preview("Single Keys") {
    VStack(spacing: 20) {
        // 功能键（矮）
        HStack(spacing: 8) {
            KeyCapView(
                key: Key(keyCode: 53, label: "esc", width: 1.58, isFunctionKey: true),
                isCleaned: false,
                baseSize: 50,
                heightMultiplier: 0.52
            )
            KeyCapView(
                key: Key(keyCode: 122, label: "F1", isFunctionKey: true, symbolName: "sun.min"),
                isCleaned: false,
                baseSize: 50,
                heightMultiplier: 0.52
            )
            KeyCapView(
                key: Key(keyCode: 122, label: "F1", isFunctionKey: true, symbolName: "sun.min"),
                isCleaned: true,
                baseSize: 50,
                heightMultiplier: 0.52
            )
        }

        // 普通键
        HStack(spacing: 8) {
            KeyCapView(
                key: Key(keyCode: 0, label: "A"),
                isCleaned: false,
                baseSize: 50
            )
            KeyCapView(
                key: Key(keyCode: 0, label: "A"),
                isCleaned: true,
                baseSize: 50
            )
        }

        // 修饰键
        HStack(spacing: 8) {
            KeyCapView(
                key: Key(keyCode: 55, label: "command", width: 1.31, isModifier: true, symbolName: "command"),
                isCleaned: false,
                baseSize: 50
            )
            KeyCapView(
                key: Key(keyCode: 55, label: "command", width: 1.31, isModifier: true, symbolName: "command"),
                isCleaned: true,
                baseSize: 50
            )
        }

        // 空格键
        KeyCapView(
            key: Key(keyCode: 49, label: "", width: 5.58),
            isCleaned: false,
            baseSize: 50
        )
    }
    .padding(40)
    .background(DesignSystem.Colors.keyboardBase)
}
