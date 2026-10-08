# EdgeHide — Windows 贴边自动隐藏工具

独立编写的 AutoHotkey v2 窗口管理工具，放置在此 Fork 的 `EdgeHide/` 目录。没有复用原仓库中未声明许可证的脚本。

## 下载与安装

打开 [Build EdgeHide Windows](../../actions/workflows/build-edgehide-windows.yml)，选择最新成功的工作流，在 **Artifacts** 下载 `EdgeHide-Windows-x64` 并解压。

- `EdgeHide-Setup-0.1.0-win-x64.exe`：安装版，支持可选开机启动。
- `EdgeHide.exe`：绿色单文件版，无需安装 AutoHotkey。

## 使用说明

先退出旧 WinAutoHide 以免冲突。激活需要隐藏的普通窗口：
- Ctrl + ↑：隐藏到顶部。
- Ctrl + ←：隐藏到左侧。
- Ctrl + →：隐藏到右侧。
- Ctrl + F4：恢复全部隐藏窗口。

也可直接拖动普通窗口到顶部、左侧或右侧边缘松开，窗口会自动隐藏。鼠标移入边缘保留的 6px 窄条可展开，离开约 800ms 后再次收起。系统托盘可恢复窗口、开关拖动贴边。

## 构建方式

Actions 下载官方 AutoHotkey v2.0.29 运行时，使用 `/Validate` 验证脚本语法，再将源脚本作为 RCDATA 资源 #1 嵌入运行时生成可双击的独立 EXE，最终使用 Inno Setup 构建安装包。此方式避免旧 Ahk2Exe 的 `/iLib` 处理对新版 AHK v2 的不兼容和编译超时。

## 许可及限制

- 此目录中的独立 EdgeHide 源码、打包脚本等采用 [MIT](LICENSE)。
- 自带的 AutoHotkey 运行时遵守[官方许可证](third_party/AutoHotkey-license.txt)，运行时源代码可在 [AutoHotkey/AutoHotkey](https://github.com/AutoHotkey/AutoHotkey/tree/v2.0.29) 获取。
- 中文安装语言资源来自 [kira-96/Inno-Setup-Chinese-Simplified-Translation](https://github.com/kira-96/Inno-Setup-Chinese-Simplified-Translation)（MIT）。
- MIT 仅适用于本目录独立创作的代码，不适用于 Fork 中原作者未声明许可证的代码。

Windows 多显示器、DPI、Snap、微软商店应用等交互仍需在真实桌面验证。最大化和最小化窗口须先还原，管理员权限的窗口可能无法操作。
