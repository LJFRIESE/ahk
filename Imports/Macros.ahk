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

;----------------- Microsoft ---------------------
;System
; Lock

;Win + L is protected by Windows. It cannot be sent using Send or remapped. To lock the computer, use this instead:
>!l::{
	DllCall("LockWorkStation")
}

; Outlook
; Insert Signature
HotIfWinActive "ahk_exe OUTLOOK.EXE"
^+i::{
	sleep 250
	Send("{Alt}e2as{Enter}")
}
HotIfWinActive


; Excel 
; Redo
HotIfWinActive "ahk_exe EXCEL.EXE"
^+z::^y
HotIfWinActive

hotif

;-------------------- Misc --------------------


~^!+#F19::{
    WinSetAlwaysOnTop -1, "A"
}


;------------------ Mouse ----------------------
