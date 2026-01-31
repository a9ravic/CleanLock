import SwiftUI

struct MenuBarView: View {
    @ObservedObject var hotKeyManager: HotKeyManager
    @AppStorage("launchAtLogin") private var launchAtLogin = false

    let onStartCleaning: () -> Void
    let onQuit: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            Text("CleanLock")
                .font(.system(size: 14, weight: .semibold))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)

            Divider()

            // Start cleaning
            Button(action: onStartCleaning) {
                HStack {
                    Image(systemName: "play.fill")
                    Text("开始清洁")
                    Spacer()
                    Text(hotKeyManager.currentHotKey.displayString)
                        .foregroundColor(.secondary)
                }
            }
            .buttonStyle(MenuItemButtonStyle())

            Divider()
                .padding(.vertical, 4)

            // Settings
            Toggle(isOn: $launchAtLogin) {
                Text("开机启动")
            }
            .toggleStyle(.checkbox)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)

            Button(action: {
                // TODO: Open hotkey settings
            }) {
                HStack {
                    Text("快捷键设置...")
                    Spacer()
                }
            }
            .buttonStyle(MenuItemButtonStyle())

            Divider()
                .padding(.vertical, 4)

            // About & Quit
            Button(action: {
                NSApplication.shared.orderFrontStandardAboutPanel()
            }) {
                Text("关于 CleanLock")
            }
            .buttonStyle(MenuItemButtonStyle())

            Button(action: onQuit) {
                Text("退出")
            }
            .buttonStyle(MenuItemButtonStyle())
        }
        .frame(width: 220)
        .padding(.vertical, 8)
    }
}

struct MenuItemButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(configuration.isPressed ? Color.accentColor.opacity(0.2) : Color.clear)
            .foregroundColor(.primary)
            .contentShape(Rectangle())
    }
}

#Preview {
    MenuBarView(
        hotKeyManager: HotKeyManager(),
        onStartCleaning: {},
        onQuit: {}
    )
    .background(Color(nsColor: .windowBackgroundColor))
}
