import SwiftUI

struct PermissionGuideView: View {
    @ObservedObject var permissionManager: PermissionManager
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "lock.shield")
                .font(.system(size: 64))
                .foregroundColor(.accentColor)

            Text("CleanLock 需要辅助功能权限")
                .font(.system(size: 24, weight: .semibold, design: .rounded))
                .foregroundColor(.primary)

            Text("为了拦截键盘输入防止清洁时误触，\n请在系统设置中授予辅助功能权限。")
                .font(.system(size: 16))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            VStack(spacing: 12) {
                Button(action: {
                    permissionManager.openAccessibilitySettings()
                }) {
                    Text("打开系统设置...")
                        .font(.system(size: 16, weight: .medium))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                Button(action: onDismiss) {
                    Text("稍后再说")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .frame(width: 240)
        }
        .padding(48)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .onAppear {
            permissionManager.startMonitoringPermission()
        }
        .onDisappear {
            permissionManager.stopMonitoringPermission()
        }
    }
}

#Preview {
    ZStack {
        Color.black.opacity(0.5)
        PermissionGuideView(
            permissionManager: PermissionManager(),
            onDismiss: {}
        )
    }
}
