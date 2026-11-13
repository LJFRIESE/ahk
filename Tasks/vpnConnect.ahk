#SingleInstance
#Requires AutoHotkey v2.0
#Include ..\Imports\RemoteWork.ahk
SetTitleMatchMode 3

; Kills any stale client UI, starts a fresh one and surfaces its dialog.
if !(dlg := RemoteWork.openDialog()) {
	RemoteWork.notify("VPN window not found")
	Exit
}
try WinActivate("ahk_id " dlg)

; Connect-only helper: leave an existing connection alone.
if (ControlGetText("Button1", "ahk_id " dlg) = "Connect") {
	ControlClick("Button1", "ahk_id " dlg, , , , "NA")
	if (prompt := WinWaitActive(RemoteWork.vpnName, "Accept", 10))
		ControlClick("Button1", "ahk_id " prompt, , , , "NA")
}

Exit
