#Requires AutoHotkey v2.0
#SingleInstance Force
#Warn
Persistent()

; EdgeHide - 三方向贴边自动隐藏 (AutoHotkey v2)
; 独立编写，不需要任何外部 .ahk 库。
; Ctrl+Left  左侧隐藏 / Ctrl+Up 顶部隐藏 / Ctrl+Right 右侧隐藏
; Ctrl+F4 恢复全部窗口；托盘菜单也可恢复。

CoordMode("Mouse", "Screen")
SetWinDelay(-1)

; 可自定义的参数（单位：像素 / 毫秒）
global edgeStrip := 6        ; 隐藏后保留在屏幕内的触发窄边
global mouseTolerance := 3   ; 鼠标触发允许的额外边距
global closeDelay := 800    ; 鼠标离开后多久收起
global frameCount := 8      ; 动画步数；设为 1 可禁用动画
global frameDelay := 12     ; 每帧的等待时间
global docked := Map()      ; 记录所有被管理的窗口
global autoDockEnabled := true ; 拖动窗口到边缘自动隐藏

A_TrayMenu.Add()
A_TrayMenu.Add("恢复全部隐藏窗口 (Ctrl+F4)", RestoreAll)
A_TrayMenu.Add("打开使用说明", ShowHelp)
A_TrayMenu.Add("拖动到屏幕边缘自动隐藏", ToggleAutoDock)
A_TrayMenu.Check("拖动到屏幕边缘自动隐藏")
OnExit(RestoreOnExit)
SetTimer(CheckMouse, 100)
SetTimer(CheckDragToEdge, 70)

^Left::DockActive("left")
^Up::DockActive("top")
^Right::DockActive("right")
^F4::RestoreAll()

ShowHelp(*) {
    MsgBox("激活要管理的普通窗口，按快捷键：`n`n"
        . "Ctrl + ←：贴左侧隐藏`n"
        . "Ctrl + ↑：贴顶部隐藏`n"
        . "Ctrl + →：贴右侧隐藏`n"
        . "Ctrl + F4：恢复全部窗口`n`n"
        . "鼠标碰到屏幕边缘的小窄条即可展开；移开约 0.8 秒后收起。`n"
        . "拖动已展开的窗口离开边缘，可取消管理。`n"
        . "退出脚本时，也会尝试恢复所有窗口。", "EdgeHide - 使用说明")
}

DockActive(side) {
    global docked, edgeStrip
    try {
        id := WinGetID("A")
        if (!id)
            return
        spec := "ahk_id " id
        if (WinGetMinMax(spec) != 0) {
            ShowNotice("请先还原窗口（不能对最大化或最小化窗口进行贴边隐藏）。")
            return
        }
        ; 不移动桌面、任务栏及本脚本自己的对话框。
        cls := WinGetClass(spec)
        if (cls = "Progman" || cls = "WorkerW" || cls = "Shell_TrayWnd" || cls = "#32768")
            return

        if (docked.Has(id))
            RestoreOne(id)
        WinGetPos(&x, &y, &w, &h, spec)
        monitor := MonitorForWindow(x, y, w, h)
        if (w > monitor.r - monitor.l || h > monitor.b - monitor.t) {
            ShowNotice("窗口尺寸超过所在显示器，请先缩小窗口再隐藏。")
            return
        }
        originalTopmost := !!(WinGetExStyle(spec) & 0x8)
        if (side = "left") {
            sx := monitor.l
            sy := Clamp(y, monitor.t, monitor.b - h)
            hx := monitor.l - w + edgeStrip
            hy := sy
        } else if (side = "right") {
            sx := monitor.r - w
            sy := Clamp(y, monitor.t, monitor.b - h)
            hx := monitor.r - edgeStrip
            hy := sy
        } else { ; top
            sx := Clamp(x, monitor.l, monitor.r - w)
            sy := monitor.t
            hx := sx
            hy := monitor.t - h + edgeStrip
        }
        item := {
            id: id, side: side, w: w, h: h,
            origX: x, origY: y, wasTopmost: originalTopmost,
            showX: sx, showY: sy, hideX: hx, hideY: hy,
            state: "moving", leaveTick: 0,
            suppressUntil: A_TickCount + 500
        }
        WinSetAlwaysOnTop(1, spec)
        WinMove(sx, sy, , , spec)
        docked[id] := item
        SlideWindow(item, hx, hy)
        item.state := "hidden"
    } catch Error as err {
        ShowNotice("贴边失败：" err.Message)
    }
}

CheckMouse() {
    global docked, closeDelay
    static running := false
    if (running)
        return
    running := true
    try {
        MouseGetPos(&mx, &my)
        ids := []
        for id, item in docked
            ids.Push(id)
        for , id in ids {
            if (!docked.Has(id))
                continue
            item := docked[id]
            spec := "ahk_id " id
            if (!WinExist(spec)) {
                docked.Delete(id)
                continue
            }
            try {
                if (item.state = "hidden") {
                    if (A_TickCount >= item.suppressUntil && InTriggerArea(item, mx, my)) {
                        item.state := "moving"
                        SlideWindow(item, item.showX, item.showY)
                        item.state := "shown"
                        item.leaveTick := 0
                        WinActivate(spec)
                    }
                } else if (item.state = "shown") {
                    WinGetPos(&currentX, &currentY, , , spec)
                    ; 用户拖离边缘时取消管理，保留拖动后的当前位置。
                    if (Abs(currentX - item.showX) > 35 || Abs(currentY - item.showY) > 35) {
                        RestoreOne(id, false)
                        continue
                    }
                    if (PointInRect(mx, my, currentX, currentY, item.w, item.h)
                        || GetKeyState("LButton", "P") || GetKeyState("RButton", "P")) {
                        item.leaveTick := 0
                    } else {
                        if (!item.leaveTick)
                            item.leaveTick := A_TickCount
                        if (A_TickCount - item.leaveTick >= closeDelay) {
                            item.state := "moving"
                            SlideWindow(item, item.hideX, item.hideY)
                            item.state := "hidden"
                            item.suppressUntil := A_TickCount + 350
                            item.leaveTick := 0
                        }
                    }
                }
            } catch Error {
                ; 出现窗口异常时，不丢失记录；使用 Ctrl+F4 或托盘恢复。
            }
        }
    } finally {
        running := false
    }
}

InTriggerArea(item, mx, my) {
    global mouseTolerance, edgeStrip
    if (item.side = "left") {
        return (mx >= item.showX - mouseTolerance && mx <= item.showX + edgeStrip + mouseTolerance
            && my >= item.showY && my < item.showY + item.h)
    }
    if (item.side = "right") {
        return (mx >= item.hideX - mouseTolerance && mx <= item.hideX + edgeStrip + mouseTolerance
            && my >= item.showY && my < item.showY + item.h)
    }
    return (my >= item.showY - mouseTolerance && my <= item.showY + edgeStrip + mouseTolerance
        && mx >= item.showX && mx < item.showX + item.w)
}

PointInRect(px, py, x, y, w, h) {
    return (px >= x && px < x + w && py >= y && py < y + h)
}

SlideWindow(item, targetX, targetY) {
    global frameCount, frameDelay
    spec := "ahk_id " item.id
    WinGetPos(&startX, &startY, , , spec)
    Loop frameCount {
        t := A_Index / frameCount
        t := 1 - (1 - t) ** 3 ; Ease-out cubic
        nx := Round(startX + (targetX - startX) * t)
        ny := Round(startY + (targetY - startY) * t)
        WinMove(nx, ny, , , spec)
        if (A_Index < frameCount)
            Sleep(frameDelay)
    }
}

RestoreOne(id, moveBack := true) {
    global docked
    if (!docked.Has(id))
        return
    item := docked[id]
    docked.Delete(id)
    spec := "ahk_id " id
    try {
        if (!WinExist(spec))
            return
        if (moveBack)
            WinMove(item.origX, item.origY, , , spec)
        WinSetAlwaysOnTop(item.wasTopmost ? 1 : 0, spec)
    } catch Error {
    }
}

RestoreAll(*) {
    global docked
    ids := []
    for id, item in docked
        ids.Push(id)
    for , id in ids
        RestoreOne(id)
}

RestoreOnExit(*) {
    RestoreAll()
}

MonitorForWindow(x, y, w, h) {
    bestOverlap := -1
    best := ""
    Loop MonitorGetCount() {
        MonitorGet(A_Index, &l, &t, &r, &b)
        overlapWidth := Max(0, Min(x + w, r) - Max(x, l))
        overlapHeight := Max(0, Min(y + h, b) - Max(y, t))
        overlap := overlapWidth * overlapHeight
        if (overlap > bestOverlap) {
            bestOverlap := overlap
            best := {l: l, t: t, r: r, b: b}
        }
    }
    return best
}

Clamp(number, low, high) {
    return Max(low, Min(number, high))
}

ShowNotice(message) {
    ToolTip(message)
    SetTimer(() => ToolTip(), -1800)
}
; 窗口贴近顶部/左侧/右侧后，鼠标松开时自动吸附。
ToggleAutoDock(*) {
    global autoDockEnabled
    autoDockEnabled := !autoDockEnabled
    if (autoDockEnabled)
        A_TrayMenu.Check("拖动到屏幕边缘自动隐藏")
    else
        A_TrayMenu.Uncheck("拖动到屏幕边缘自动隐藏")
}

CheckDragToEdge() {
    global autoDockEnabled, docked
    static wasDown := false, startId := 0
    static startMX := 0, startMY := 0, startX := 0, startY := 0
    if (!autoDockEnabled)
        return
    down := GetKeyState("LButton", "P")
    if (down && !wasDown) {
        wasDown := true
        startId := 0
        try {
            MouseGetPos(&startMX, &startMY, &startId)
            if (!startId)
                return
            spec := "ahk_id " startId
            if (docked.Has(startId) || WinGetMinMax(spec) != 0) {
                startId := 0
                return
            }
            cls := WinGetClass(spec)
            if (cls = "Progman" || cls = "WorkerW" || cls = "Shell_TrayWnd" || cls = "#32768") {
                startId := 0
                return
            }
            WinGetPos(&startX, &startY, , , spec)
        } catch Error {
            startId := 0
        }
    } else if (!down && wasDown) {
        wasDown := false
        if (!startId)
            return
        id := startId
        startId := 0
        try {
            spec := "ahk_id " id
            if (!WinExist(spec) || WinGetMinMax(spec) != 0)
                return
            MouseGetPos(&mx, &my)
            WinGetPos(&x, &y, &w, &h, spec)
            if (Abs(mx - startMX) + Abs(my - startMY) < 60)
                return
            if (Abs(x - startX) + Abs(y - startY) < 20)
                return
            mon := MonitorForWindow(x, y, w, h)
            if (w > mon.r - mon.l || h > mon.b - mon.t)
                return
            tolerance := 18
            side := ""
            if (Abs(y - mon.t) <= tolerance)
                side := "top"
            else if (Abs(x - mon.l) <= tolerance)
                side := "left"
            else if (Abs(x + w - mon.r) <= tolerance)
                side := "right"
            if (side != "")
                DockWindow(id, side)
        } catch Error {
        }
    }
}
