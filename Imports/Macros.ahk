#SingleInstance

;----------------------- Autocomplete ----------------
; Move cursor inside paired brackets
;~}::
;~]:: {
;	if A_PriorKey="[" {
;		Send("{Left}")
;	}
;}
;
;~):: {
;	if A_PriorKey="9" {
;		Send("{Left}")
;	}
;}

; When creating newline after brackets, move cursor up and tab
;~Enter:: {
;	if A_PriorKey="0" || A_PriorKey="]" {
;		Send("{Enter}{Up}{Tab}")
;	}
;}


; Move inside paired quotes
;~'::
;~":: {
;	if A_PriorKey="'" {
;		Send("{Left}")
;	}
;}
;
;~`:: {
;	if A_PriorKey='``' {
;		Send("{Left}")
;	}
;}

;------------------ Text/Files -----------------

; Work around for copy+paste on the SAG
; Save query to X:\Lucas F\tmp.txt
; Then you can read it out
;F21:: {
	;tmpFileName := "X:\Lucas F\tmp.txt"
	;A_Clipboard := ""		                    	; Clear clipboard
	;A_Clipboard := FileRead(tmpFileName)			; Read from tmp file
    ;Send('^v')                                      ; Send paste      
;}
;HotkeyGuide.RegisterHotkey("Layer 2 - Numpad", "^1","Read from tmp.txt")

; Convert text to UPPER
;F18::ToUpper()
;HotkeyGuide.RegisterHotkey("Layer 2 - Numpad", "^4","Convert to UPPER")

;----------------- Navigation ---------------------
;Unneeded if keeping komorebi
;+^!Up::Tabber.CycleClasses("prev")    
;+^!Down::Tabber.CycleClasses("next")
;+^!Left::Tabber.CycleWindows("prev")
;+^!Right::Tabber.CycleWindows("next")

;HotkeyGuide.RegisterHotkey("Navigation", "+^!+Up/Down", "Cycle between applications")
;HotkeyGuide.RegisterHotkey("Navigation", "+^!+Left/Right", "Select application window")

;----------------- Microsoft ---------------------
; Outlook
; Insert Signature

^+i::{
	sleep 250
	Send("{Alt}e2as{Enter}")
}

HotkeyGuide.RegisterHotkey("Outlook", "^+i","Insert Signature")

;System
; Lock

;Win + L is protected by Windows. It cannot be sent using Send or remapped. To lock the computer, use this instead:
>!l::{
	DllCall("LockWorkStation")
}

; Explorer
!e::{
	if WinExist("ahk_class CabinetWClass") {
        WinActivate("ahk_class CabinetWClass")
    } else {
        Run("explorer.exe")
    }
}


;-------------------- Misc --------------------


~^!+#F19::{
    WinSetAlwaysOnTop -1, "A"
}
HotkeyGuide.RegisterHotkey("Layer 2 - Numpad", "^!+#9","Set window Always on Top")


;------------------ Mouse ----------------------
