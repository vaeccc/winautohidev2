## EdgeHide v0.1.0 — Windows 贴边自动隐藏（预览版）

EdgeHide 是一款独立的 Windows 通用窗口贴边隐藏工具，基于 AutoHotkey v2，**不需要单独安装 AutoHotkey**。

### 下载

- **EdgeHide-Setup-0.1.0-win-x64.exe**：Windows x64 安装包（推荐），安装时可选择开机自启。
- **EdgeHide.exe**：Windows x64 便携版，直接双击运行。

### 功能

- 当前窗口按 `Ctrl + ↑`、`Ctrl + ←`、`Ctrl + →` 分别隐藏到屏幕顶部、左侧、右侧。
- 将普通窗口拖到屏幕边缘附近松开，也可自动隐藏。
- 鼠标碰到预留的边缘区域自动展开，离开约 800 毫秒自动收起。
- `Ctrl + F4` 或系统托盘菜单可恢复全部隐藏窗口。
- 支持窗口滑动动画、关闭拖动吸附以及退出时尝试恢复窗口。

### 安装与使用

1. 先退出其他 WinAutoHide 实例，避免快捷键冲突。
2. 下载安装版或便携版并启动。
3. 打开记事本，按 `Ctrl + ↑` 测试顶部隐藏；再将鼠标移到上边缘触发展开。
4. 如果遇到异常，使用 `Ctrl + F4` 或系统托盘菜单恢复所有窗口。

### 版本状态与限制

**这是预览版。** GitHub Actions 已验证可生成独立 EXE 和安装包，且脚本已嵌入 EXE；但尚未通过真实 Windows 桌面的窗口交互测试，Microsoft To Do、多个显示器、不同 DPI 及 Snap 布局的兼容性仍待验证。部分管理员权限窗口可能无法正常操作。请先用记事本测试，再用于重要应用。

本版本 EdgeHide 代码与原仓库的无许可证代码分开维护在 `EdgeHide/`，详细的版权和依赖声明请见 [EdgeHide 说明](https://github.com/vaeccc/winautohidev2/tree/main/EdgeHide)。
