; Window management helpers for the F24 leader menu.
; Layout changes use native Windows snapping where it exists and explicit
; work-area geometry for top/bottom halves, which Windows has no shortcut for.

SnapActiveWindow(dir) {
    if dir < 0
        Send("#{Left}")
    else
        Send("#{Right}")
}

SnapActiveWindowVertical(dir) {
    hwnd := WinGetID("A")
    if !hwnd
        return

    MonitorGetWorkArea(MonitorForWindow(hwnd), &l, &t, &r, &b)
    WinRestore("ahk_id " hwnd)

    half := (b - t) / 2
    if dir < 0
        WinMove(l, t, r - l, half, "ahk_id " hwnd)
    else
        WinMove(l, t + half, r - l, half, "ahk_id " hwnd)
    CenterMouse()
}

MonitorForWindow(hwnd) {
    try WinGetPos(&x, &y, &w, &h, "ahk_id " hwnd)
    catch
        return MonitorGetPrimary()

    cx := x + w / 2
    cy := y + h / 2
    Loop MonitorGetCount() {
        MonitorGetWorkArea(A_Index, &l, &t, &r, &b)
        if (cx >= l && cx < r && cy >= t && cy < b)
            return A_Index
    }
    return MonitorGetPrimary()
}

MoveActiveWindowToMonitor(dir) {
    hwnd := WinGetID("A")
    if !hwnd
        return
    try WinGetPos(&x, &y, &w, &h, "ahk_id " hwnd)
    catch
        return

    current := MonitorForWindow(hwnd)
    MonitorGetWorkArea(current, &cl, &ct, &cr, &cb)
    curCx := (cl + cr) / 2

    target := 0
    best := 0
    Loop MonitorGetCount() {
        if A_Index = current
            continue
        MonitorGetWorkArea(A_Index, &l, &t, &r, &b)
        cx := (l + r) / 2
        if (dir < 0 && cx < curCx) {
            if (!target || cx > best) {
                best := cx
                target := A_Index
            }
        } else if (dir > 0 && cx > curCx) {
            if (!target || cx < best) {
                best := cx
                target := A_Index
            }
        }
    }
    if !target
        return

    MonitorGetWorkArea(target, &tl, &tt, &tr, &tb)
    aw := tr - tl
    ah := tb - tt
    nw := (w < aw) ? w : aw
    nh := (h < ah) ? h : ah

    WinRestore("ahk_id " hwnd)
    WinMove(tl + (aw - nw) / 2, tt + (ah - nh) / 2, nw, nh, "ahk_id " hwnd)
    CenterMouse()
}

MaximizeActiveWindow() {
    WinMaximize("A")
    CenterMouse()
}

CloseActiveWindow() {
    WinClose("A")
}

MinimizeOtherWindows() {
    active := WinGetID("A")
    if !active
        return

    for hwnd in WinGetList() {
        if (hwnd = active)
            continue
        if !DllCall("IsWindowVisible", "Ptr", hwnd)
            continue
        try {
            if !WinGetTitle("ahk_id " hwnd)
                continue
            cloaked := 0
            DllCall("Dwmapi\DwmGetWindowAttribute", "Ptr", hwnd, "UInt", 14, "Int*", &cloaked, "UInt", 4)
            if cloaked
                continue
        } catch
            continue
        try WinMinimize("ahk_id " hwnd)
    }
}
