;----------------- Microsoft ---------------------
;System
; Lock
;Win + L is protected by Windows. It cannot be sent using Send or remapped. To lock the computer, use this instead:
>!l::{
	DllCall("LockWorkStation")
}

;-----------------  Outlook ---------------------
; Insert Signature
#HotIf WinActive("ahk_exe OUTLOOK.EXE") 
	^+i::{
		sleep 250
		Send("{Alt}e2as{Enter}")
	}
#HotIf


;----------------- Excel ---------------------
#HotIf WinActive("ahk_exe EXCEL.EXE")
	; Redo
	^+z::^y

	; Find and replace
	^+r::^h

	^+s::{
			Send("!fa")
				sleep 2000
			Send("y9")
		}

	^+;::{
		Send("^a")
		Sleep(50)
		try xl := ComObjActive("Excel.Application")
		catch
			return
		alerts := xl.DisplayAlerts
		try {
			xl.DisplayAlerts := false
			sel := xl.Selection
			sel.TextToColumns(sel, 1, 1, false, false, true, false, false, false)
		} finally {
			xl.DisplayAlerts := alerts
		}
	}
#HotIf


;-----------------  Notepad++ ---------------------
#HotIf WinActive("ahk_exe notepad++.exe")
	^r::^h
#HotIf

;----------------- Omnissa ---------------------

; True when the active window is a Chrome window whose last tracked title
; belongs to the Horizon VM. #HotIf expressions are assume-local, so the
; global title has to be read through a function.
IsOmnissaWindow() {
	global gLastWinTitle
	return WinActive("ahk_exe chrome.exe") && InStr(gLastWinTitle, "Omnissa Horizon")
}

; Disable certain shortcuts when Chrome tab title contains "Omnissa Horizon"
#HotIf IsOmnissaWindow()
	; Pass Ctrl+W/N/T into the VM by releasing Ctrl and pressing the key
	; directly. {Blind} prevents Send from pressing Ctrl back down at the end
	; of the send; doing that used to leave a synthetic Ctrl-down behind when
	; Ctrl was released during the hotkey, which is the stuck-Ctrl bug.
	^w::Send "{Blind}{Ctrl up}w"
	^n::Send "{Blind}{Ctrl up}n"
	^t::Send "{Blind}{Ctrl up}t"
#HotIf

