; Focus a window on the monitor to the left/right of the active window.
; Takes over Windows' own Win+Shift+Arrow "snap window to monitor" shortcut.

$#+Left::FocusMonitor(-1)
$#+Right::FocusMonitor(1)

FocusMonitor(dir) {
	active := WinGetID("A")
	if !active
		return

	count := MonitorGetCount()

	; Which monitor is the active window on? Use the work area so the taskbar
	; does not skew containment, and the window's centre so spans are handled.
	try WinGetPos(&ax, &ay, &aw, &ah, "ahk_id " active)
	catch
		return
	acx := ax + aw / 2
	acy := ay + ah / 2

	curIdx := 0
	Loop count {
		MonitorGetWorkArea(A_Index, &l, &t, &r, &b)
		if (acx >= l && acx < r && acy >= t && acy < b) {
			curIdx := A_Index
			curL := l
			curR := r
			break
		}
	}
	if !curIdx
		return

	; Nearest monitor whose centre lies further in the requested direction.
	curCx := (curL + curR) / 2
	target := 0
	best := 0
	Loop count {
		if (A_Index = curIdx)
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

	; WinGetList is in z-order, so the first match is the topmost window there.
	for hw in WinGetList() {
		if (hw = active)
			continue
		if !DllCall("IsWindowVisible", "Ptr", hw)
			continue
		try {
			if !WinGetTitle("ahk_id " hw)
				continue
			cloaked := 0
			DllCall("Dwmapi\DwmGetWindowAttribute", "Ptr", hw, "UInt", 14, "Int*", &cloaked, "UInt", 4)
			if cloaked
				continue
			WinGetPos(&wx, &wy, &ww, &wh, "ahk_id " hw)
		} catch
			continue
		cx := wx + ww / 2
		cy := wy + wh / 2
		if (cx >= tl && cx < tr && cy >= tt && cy < tb) {
			WinActivate("ahk_id " hw)
			return
		}
	}
}
