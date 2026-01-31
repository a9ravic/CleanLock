import SwiftUI
import AppKit

// MARK: - macOS Native Design System

/// CleanLock 设计系统 - macOS 原生风格
/// 遵循 Apple Human Interface Guidelines (HIG)
enum DesignSystem {

    // MARK: - Colors

    enum Colors {
        // 语义化颜色 - 自动适应暗色/亮色模式
        static let primaryText = Color(nsColor: .labelColor)
        static let secondaryText = Color(nsColor: .secondaryLabelColor)
        static let tertiaryText = Color(nsColor: .tertiaryLabelColor)
        static let quaternaryText = Color(nsColor: .quaternaryLabelColor)

        // 背景色
        static let windowBackground = Color(nsColor: .windowBackgroundColor)
        static let controlBackground = Color(nsColor: .controlBackgroundColor)
        static let underPageBackground = Color(nsColor: .underPageBackgroundColor)

        // 分隔线和边框
        static let separator = Color(nsColor: .separatorColor)
        static let border = Color(nsColor: .separatorColor)

        // 强调色 - 跟随系统设置
        static let accent = Color.accentColor

        // 品牌色 - 清洁蓝
        static let brand = Color(red: 0.25, green: 0.60, blue: 1.0)
        static let brandLight = Color(red: 0.30, green: 0.65, blue: 1.0)
        static let brandDark = Color(red: 0.20, green: 0.50, blue: 0.90)

        // 状态色
        static let success = Color.green
        static let warning = Color.orange
        static let error = Color.red

        // 键盘专用色
        static let keyboardBase = Color(red: 0.08, green: 0.08, blue: 0.10)
        static let keyBackground = Color(red: 0.16, green: 0.16, blue: 0.18)
        static let keyBackgroundLight = Color(red: 0.22, green: 0.22, blue: 0.24)
        static let keyBorder = Color(red: 0.12, green: 0.12, blue: 0.14)
        static let keyText = Color(red: 0.85, green: 0.85, blue: 0.87)
        static let keyCleaned = brand
        static let keyCleanedGlow = brandLight

        // 全屏清洁模式专用（沉浸式深色）
        static let immersiveBackground = Color(red: 0.04, green: 0.04, blue: 0.06)
        static let immersiveSecondary = Color(red: 0.08, green: 0.08, blue: 0.12)
    }

    // MARK: - Typography

    enum Typography {
        // 大标题
        static let largeTitle = Font.system(size: 26, weight: .bold, design: .rounded)
        static let title = Font.system(size: 22, weight: .bold, design: .rounded)
        static let title2 = Font.system(size: 17, weight: .semibold)
        static let title3 = Font.system(size: 15, weight: .semibold)

        // 正文
        static let body = Font.system(size: 13, weight: .regular)
        static let bodyMedium = Font.system(size: 13, weight: .medium)
        static let bodySemibold = Font.system(size: 13, weight: .semibold)

        // 辅助文字
        static let callout = Font.system(size: 12, weight: .regular)
        static let caption = Font.system(size: 11, weight: .regular)
        static let captionMedium = Font.system(size: 11, weight: .medium)

        // 等宽字体（快捷键显示）
        static let monospaced = Font.system(size: 12, weight: .medium, design: .monospaced)
        static let monospacedSmall = Font.system(size: 11, weight: .medium, design: .monospaced)
    }

    // MARK: - Spacing

    enum Spacing {
        static let xxs: CGFloat = 2
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 24
        static let xxxl: CGFloat = 32

        // 窗口内边距
        static let windowPadding: CGFloat = 20
        static let sectionSpacing: CGFloat = 16
    }

    // MARK: - Corner Radius

    enum CornerRadius {
        static let small: CGFloat = 4
        static let medium: CGFloat = 8
        static let large: CGFloat = 12
        static let xlarge: CGFloat = 16

        // macOS 标准控件圆角
        static let button: CGFloat = 6
        static let textField: CGFloat = 6
        static let popover: CGFloat = 10
        static let window: CGFloat = 10
    }

    // MARK: - Shadows

    enum Shadows {
        static let small = Shadow(color: .black.opacity(0.1), radius: 2, y: 1)
        static let medium = Shadow(color: .black.opacity(0.15), radius: 8, y: 4)
        static let large = Shadow(color: .black.opacity(0.2), radius: 16, y: 8)

        // 发光效果
        static func glow(color: Color, radius: CGFloat = 10) -> Shadow {
            Shadow(color: color.opacity(0.4), radius: radius, y: 0)
        }
    }

    // MARK: - Animation

    enum Animation {
        // 微交互
        static let micro = SwiftUI.Animation.easeOut(duration: 0.15)
        static let quick = SwiftUI.Animation.easeOut(duration: 0.2)
        static let standard = SwiftUI.Animation.easeOut(duration: 0.3)
        static let smooth = SwiftUI.Animation.easeInOut(duration: 0.35)

        // 弹簧动画
        static let spring = SwiftUI.Animation.spring(response: 0.35, dampingFraction: 0.7)
        static let bouncy = SwiftUI.Animation.spring(response: 0.4, dampingFraction: 0.6)
    }
}

// MARK: - Shadow Helper

struct Shadow {
    let color: Color
    let radius: CGFloat
    let y: CGFloat

    init(color: Color, radius: CGFloat, y: CGFloat) {
        self.color = color
        self.radius = radius
        self.y = y
    }
}

extension View {
    func shadow(_ shadow: Shadow) -> some View {
        self.shadow(color: shadow.color, radius: shadow.radius, y: shadow.y)
    }
}

// MARK: - macOS Native Button Styles

/// 主要按钮样式 - 带背景色
struct PrimaryButtonStyle: ButtonStyle {
    var color: Color = DesignSystem.Colors.brand

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DesignSystem.Typography.bodySemibold)
            .foregroundColor(.white)
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.button, style: .continuous)
                    .fill(configuration.isPressed ? color.opacity(0.8) : color)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(DesignSystem.Animation.micro, value: configuration.isPressed)
    }
}

/// 次要按钮样式 - 边框样式
struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DesignSystem.Typography.bodyMedium)
            .foregroundColor(DesignSystem.Colors.primaryText)
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.button, style: .continuous)
                    .fill(DesignSystem.Colors.controlBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.button, style: .continuous)
                            .strokeBorder(DesignSystem.Colors.separator, lineWidth: 0.5)
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(DesignSystem.Animation.micro, value: configuration.isPressed)
    }
}

/// 文字按钮样式
struct TextButtonStyle: ButtonStyle {
    var color: Color = DesignSystem.Colors.accent

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DesignSystem.Typography.bodyMedium)
            .foregroundColor(configuration.isPressed ? color.opacity(0.6) : color)
            .animation(DesignSystem.Animation.micro, value: configuration.isPressed)
    }
}

/// 菜单项按钮样式
struct MenuItemButtonStyle: ButtonStyle {
    var isDestructive: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DesignSystem.Typography.body)
            .foregroundColor(isDestructive ? DesignSystem.Colors.error : DesignSystem.Colors.primaryText)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small, style: .continuous)
                    .fill(configuration.isPressed ? DesignSystem.Colors.accent.opacity(0.15) : Color.clear)
            )
            .contentShape(Rectangle())
    }
}

// MARK: - macOS Native Components

/// 标准卡片容器
struct CardView<Content: View>: View {
    let content: Content
    var padding: CGFloat = DesignSystem.Spacing.lg

    init(padding: CGFloat = DesignSystem.Spacing.lg, @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous)
                    .fill(DesignSystem.Colors.controlBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous)
                            .strokeBorder(DesignSystem.Colors.separator.opacity(0.5), lineWidth: 0.5)
                    )
            )
    }
}

/// 设置行组件
struct SettingRow<Accessory: View>: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String?
    let accessory: Accessory

    init(
        icon: String,
        iconColor: Color = DesignSystem.Colors.accent,
        title: String,
        subtitle: String? = nil,
        @ViewBuilder accessory: () -> Accessory
    ) {
        self.icon = icon
        self.iconColor = iconColor
        self.title = title
        self.subtitle = subtitle
        self.accessory = accessory()
    }

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            // 图标
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(iconColor)
                .frame(width: 20)

            // 文字
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(DesignSystem.Typography.bodyMedium)
                    .foregroundColor(DesignSystem.Colors.primaryText)

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                }
            }

            Spacer()

            accessory
        }
    }
}

extension SettingRow where Accessory == EmptyView {
    init(
        icon: String,
        iconColor: Color = DesignSystem.Colors.accent,
        title: String,
        subtitle: String? = nil
    ) {
        self.init(icon: icon, iconColor: iconColor, title: title, subtitle: subtitle) {
            EmptyView()
        }
    }
}

/// 功能介绍行
struct FeatureInfoRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: DesignSystem.Spacing.md) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.12))
                    .frame(width: 32, height: 32)

                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(iconColor)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(DesignSystem.Typography.bodySemibold)
                    .foregroundColor(DesignSystem.Colors.primaryText)

                Text(description)
                    .font(DesignSystem.Typography.callout)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
            }

            Spacer(minLength: 0)
        }
    }
}

/// 快捷键显示组件
struct ShortcutBadge: View {
    let text: String

    var body: some View {
        Text(text)
            .font(DesignSystem.Typography.monospacedSmall)
            .foregroundColor(DesignSystem.Colors.secondaryText)
            .padding(.horizontal, DesignSystem.Spacing.sm)
            .padding(.vertical, DesignSystem.Spacing.xs)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small, style: .continuous)
                    .fill(DesignSystem.Colors.separator.opacity(0.3))
            )
    }
}

/// 沉浸式卡片背景（用于全屏清洁模式）
struct ImmersiveCardBackground: View {
    var cornerRadius: CGFloat = DesignSystem.CornerRadius.xlarge + 4

    var body: some View {
        ZStack {
            // 毛玻璃背景
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(.ultraThinMaterial)
                .environment(\.colorScheme, .dark)

            // 边框高光
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.18),
                            Color.white.opacity(0.05),
                            Color.clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        }
    }
}

/// 应用图标组件（可配置尺寸）
struct AppIconView: View {
    enum Size {
        case small   // 32x32 for menu bar
        case medium  // 52x52 for main window
        case large   // 72x72 for welcome screen

        var iconSize: CGFloat {
            switch self {
            case .small: return 32
            case .medium: return 52
            case .large: return 72
            }
        }

        var cornerRadius: CGFloat {
            switch self {
            case .small: return 6
            case .medium: return 16
            case .large: return 20
            }
        }

        var symbolSize: CGFloat {
            switch self {
            case .small: return 14
            case .medium: return 24
            case .large: return 32
            }
        }

        var glowSize: CGFloat {
            switch self {
            case .small: return 0 // no glow for small
            case .medium: return 64
            case .large: return 88
            }
        }
    }

    let size: Size
    var showGlow: Bool = true

    var body: some View {
        ZStack {
            // 光晕效果（仅 medium 和 large）
            if showGlow && size.glowSize > 0 {
                Circle()
                    .fill(DesignSystem.Colors.brand.opacity(0.1))
                    .frame(width: size.glowSize, height: size.glowSize)
                    .blur(radius: size == .large ? 16 : 12)
            }

            // 图标背景
            RoundedRectangle(cornerRadius: size.cornerRadius, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            DesignSystem.Colors.controlBackground,
                            DesignSystem.Colors.windowBackground
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size.iconSize, height: size.iconSize)
                .overlay(
                    RoundedRectangle(cornerRadius: size.cornerRadius, style: .continuous)
                        .strokeBorder(DesignSystem.Colors.separator.opacity(0.5), lineWidth: 0.5)
                )
                .shadow(DesignSystem.Shadows.small)

            // 键盘图标
            Image(systemName: "keyboard.fill")
                .font(.system(size: size.symbolSize, weight: .medium))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            DesignSystem.Colors.brand,
                            DesignSystem.Colors.brandLight
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
    }
}

/// 品牌主按钮（带阴影效果）
struct BrandButton: View {
    let title: String
    var icon: String? = nil
    var showArrow: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 13, weight: .semibold))
                }

                Text(title)
                    .font(DesignSystem.Typography.bodySemibold)

                if showArrow {
                    Image(systemName: "arrow.right")
                        .font(.system(size: 13, weight: .semibold))
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSystem.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
                    .fill(DesignSystem.Colors.brand)
            )
            .shadow(color: DesignSystem.Colors.brand.opacity(0.3), radius: 8, y: 4)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - View Extensions

extension View {
    /// 应用标准窗口样式
    func standardWindowStyle() -> some View {
        self
            .frame(minWidth: 320, minHeight: 200)
            .background(DesignSystem.Colors.windowBackground)
    }

    /// 应用卡片阴影
    func cardShadow() -> some View {
        self.shadow(DesignSystem.Shadows.medium)
    }
}
