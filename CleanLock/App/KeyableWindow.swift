import AppKit

// MARK: - 可成为 Key Window 的无边框窗口

/// 自定义 NSWindow 子类，允许无边框窗口成为 key window 和 main window。
/// macOS 默认情况下，使用 `.borderless` 样式的窗口不能成为 key window。
/// 这个类通过重写 `canBecomeKey` 和 `canBecomeMain` 属性来解决这个问题。
///
/// 用途：
/// - 清洁模式窗口需要全屏无边框显示
/// - 同时需要接收键盘事件
/// - 必须成为 key window 以获得焦点
final class KeyableWindow: NSWindow {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}
