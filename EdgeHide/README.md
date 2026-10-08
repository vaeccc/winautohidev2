# EdgeHide · Windows 贴边自动隐藏

EdgeHide 是独立开发的 AutoHotkey v2 窗口管理工具，置于本仓库的独立目录中。仅构建 EdgeHide，自带 Microsoft To Do 等普通窗口通用支持，不使用原仓库中未声明许可证的脚本。

## 下载及安装

前往 [GitHub Actions](../../actions/workflows/build-edgehide-windows.yml)，打开最新成功的 **Build EdgeHide Windows** 运行，在 **Artifacts** 下载 `EdgeHide-Windows-x64`，解压后获得：

- `EdgeHide-Setup-0.1.0-win-x64.exe`：Windows 安装程序，提供可选开机自启。
- `EdgeHide.exe`：绿色便携版，无需另外安装 AutoHotkey。

## 使用方法

首先退出旧的 WinAutoHide，以免快捷键冲突，然后双击运行 EdgeHide.exe 或通过安装程序启动。

| 功能 | 操作 |
|---|---|
| 当前窗口顶部隐藏 | Ctrl + ↑ |
| 当前窗口左侧隐藏 | Ctrl + ← |
| 当前窗口右侧隐藏 | Ctrl + → |
| 取消全部隐藏并恢复位置 | Ctrl + F4 |

也可以直接拖动普通窗口到屏幕顶部、左侧或右侧附近，松开后自动收起。鼠标移到屏幕边缘隐藏条时展开；鼠标移开约 800ms 后再次隐藏。托盘菜单包含“恢复全部隐藏窗口”和“拖动到屏幕边缘自动隐藏”开关。最大化/最小化窗口须先还原。

## 已知限制

- 这是一款通用窗口管理器，显示隐藏条需要临时置顶窗口；不是 Wallpaper/WorkerW 桌面层插件。
- 多显示器、不同缩放比例、Windows 11 Snap 和微软商店应用的窗口行为需要实际 Windows 桌面验收。
- GitHub Actions 构建成功并不等于已经完成 Microsoft To Do 的交互测试。
- 权限低的程序通常不能操作以管理员身份运行的窗口。

## 许可

此目录下**独立编写的 EdgeHide 代码**由 [MIT 许可证](LICENSE)授权。原始 `windwhim/winautohidev2` 仓库未声明代码许可证，本目录不从其复制源码，MIT 不适用于该仓库其他文件。

安装程序所用简体中文语言资源来自 [kira-96/Inno-Setup-Chinese-Simplified-Translation](https://github.com/kira-96/Inno-Setup-Chinese-Simplified-Translation)（MIT，保留原作者版权信息）；编译器及 AutoHotkey 运行时遵循各自许可证。
