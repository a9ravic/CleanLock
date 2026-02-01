<div align="center">

# CleanLock

**专为 MacBook 设计的键盘清洁助手**

锁定键盘，放心擦拭每一个按键

[![Platform](https://img.shields.io/badge/platform-macOS%2013.0+-blue.svg)](https://www.apple.com/macos/)
[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

[English](README_EN.md) | 简体中文

<img src="assets/icon.png" width="128" height="128" alt="CleanLock Icon">

</div>

---

## 截图

<div align="center">
<img src="assets/screenshot-cleaning.png" width="600" alt="清洁模式">
</div>

## 功能特性

- **一键锁定** - 启动清洁模式后，所有按键输入被拦截，避免误触导致的意外操作
- **可视化进度** - 按下的按键会亮起显示已清洁，确保不遗漏任何一个按键
- **快捷启动** - 使用 `⌘⇧K` 全局快捷键，无需打开窗口即可快速进入清洁模式
- **智能退出** - 全部按键清洁完成后自动退出，也可随时长按 ESC 提前退出
- **多语言支持** - 支持简体中文、English、Español、हिंदी、العربية、Français、Português
- **原生体验** - 纯 SwiftUI + AppKit 构建，无第三方依赖，体积小巧

## 系统要求

- macOS 13.0 (Ventura) 或更高版本
- 支持 Apple Silicon 和 Intel Mac

## 安装

### App Store

[![Download on the App Store](https://developer.apple.com/assets/elements/badges/download-on-the-app-store.svg)](https://apps.apple.com/app/cleanlock)

### 手动构建

```bash
# 克隆仓库
git clone https://github.com/a9ravic/CleanLock.git
cd CleanLock

# 配置签名（首次构建需要）
cp local.xcconfig.template local.xcconfig
# 编辑 local.xcconfig，填入你的开发者团队 ID

# 生成 Xcode 项目
make generate

# 构建
make build

# 或在 Xcode 中打开
make open
```

## 使用方法

1. 启动 CleanLock，应用将在菜单栏显示图标
2. 点击菜单栏图标，选择「开始清洁」或使用快捷键 `⌘⇧K`
3. 屏幕将显示键盘布局，开始擦拭键盘
4. 按下的按键会亮起，表示已清洁
5. 清洁完所有按键后自动退出，或长按 ESC 提前退出

## 技术架构

```
CleanLock
├── App/                    # 应用入口
│   ├── CleanLockApp.swift  # SwiftUI App 入口
│   └── AppDelegate.swift   # 窗口和生命周期管理
├── Views/                  # SwiftUI 视图
│   ├── CleaningView.swift  # 清洁模式主界面
│   ├── KeyboardView.swift  # 键盘布局视图
│   └── KeyCapView.swift    # 单个按键视图
├── Services/               # 核心服务
│   ├── SandboxKeyInterceptor.swift  # 键盘事件拦截
│   └── HotKeyManager.swift          # 全局快捷键
├── Models/                 # 数据模型
│   ├── KeyboardLayout.swift    # 键盘布局定义
│   └── CleaningState.swift     # 清洁状态管理
└── Theme/                  # 设计系统
    └── DesignSystem.swift  # 颜色、字体、动画
```

### 设计亮点

- **App Sandbox 兼容** - 使用 `NSEvent.addLocalMonitorForEvents` 拦截键盘，无需辅助功能权限
- **状态机驱动** - 清洁流程通过状态机管理：`idle → cleaning → completed → exiting`
- **SwiftUI + AppKit 混合架构** - AppKit 管理窗口，SwiftUI 构建界面

## 开发

```bash
# 运行测试
make test

# 清理构建产物
make clean

# 重新生成项目
make generate
```

## 贡献

欢迎提交 Issue 和 Pull Request！

1. Fork 本仓库
2. 创建功能分支 (`git checkout -b feature/amazing-feature`)
3. 提交更改 (`git commit -m 'Add amazing feature'`)
4. 推送到分支 (`git push origin feature/amazing-feature`)
5. 提交 Pull Request

## 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情

## 链接

- [官方网站](https://cleanlock.agravic.dev)
- [问题反馈](https://github.com/a9ravic/CleanLock/issues)
