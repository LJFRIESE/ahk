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

; Disable certain shortcuts when Chrome tab title contains "Omnissa Horizon"
#HotIf WinActive("ahk_exe chrome.exe") && InStr(gLastWinTitle, "Omnissa Horizon")
	^w::{
		; Pass Ctrl+W into the VM by releasing Ctrl and pressing w directly.
		Send "{Ctrl up}w{Ctrl down}"
	}

	^n::Send "{Ctrl up}n{Ctrl down}"
	^t::Send "{Ctrl up}t{Ctrl down}"
#HotIf

