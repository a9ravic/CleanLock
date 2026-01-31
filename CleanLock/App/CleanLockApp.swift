import SwiftUI

@main
struct CleanLockApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // 使用空的 Settings scene（SwiftUI App 必须有至少一个 scene）
        // 但通过 commands 移除设置菜单项，禁用 Command + ,
        Settings {
            EmptyView()
        }
        .commands {
            // 移除 "设置..." 菜单项 (Command + ,)
            CommandGroup(replacing: .appSettings) { }
        }
    }
}
