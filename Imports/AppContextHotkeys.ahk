; Disable certain shortcuts when Chrome tab title contains "Omnissa Horizon"
#HotIf WinActive("ahk_exe chrome.exe") && InStr(WinGetTitle("A"), "Omnissa Horizon")
^w::{
	; Pass Ctrl+W into the VM by releasing Ctrl and pressing w directly.
	Send "{Ctrl up}w{Ctrl down}"
}

^n::Send "{Ctrl up}n{Ctrl down}"
^t::Send "{Ctrl up}t{Ctrl down}"
#HotIf

; Excel hotkey: Ctrl+Shift+S -> Save As
#HotIf WinActive("ahk_exe excel.exe")
^+s::Send("!fa")
#HotIf
