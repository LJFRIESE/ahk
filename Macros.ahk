#SingleInstance

;----------------------- Autocomplete ----------------
; Move cursor inside paired brackets
~}::
~]:: {
	if A_PriorKey="[" {
		Send("{Left}")
	}
}

~):: {
	if A_PriorKey="9" {
		Send("{Left}")
	}
}

; When creating newline after brackets, move cursor up and tab
~Enter:: {
	if A_PriorKey="0" || A_PriorKey="]" {
		Send("{Enter}{Up}{Tab}")
	}
}


; Move inside paired quotes
~'::
~":: {
	if A_PriorKey="'" {
		Send("{Left}")
	}
}

~`:: {
	if A_PriorKey='``' {
		Send("{Left}")
	}
}

;------------------ Text/Files -----------------

; Work around for copy+paste on the SAG
; Save query to X:\Lucas F\tmp.txt
; Then you can read it out
F21:: {
	tmpFileName := "X:\Lucas F\tmp.txt"
	A_Clipboard := ""		                    	; Clear clipboard
	A_Clipboard := FileRead(tmpFileName)				; Read from tmp file
    Send('^v')                                      ; Send paste      
}


; Convert text to UPPER
F14:: {
    clip_bak := ClipboardAll()                      ; Backup current clipboard
    A_Clipboard := ''                               ; Clear clipboard
    Send('^c')                                      ; Send copy
    if ClipWait(1, 0)                               ; Wait up to 1 second for text to appear
        A_Clipboard := StrUpper(A_Clipboard)        ;   If it appeared, transform to uppercase
        ,Send('^v')                                 ;   And then paste
    while !DllCall('GetOpenClipboardWindow', 'Ptr') ; While clipboard is still in use
        if (A_Index < 20)                           ;   If less than 20 tries
            Sleep(100)                              ;     Sleep another 100ms
        else break                                  ;   Otherwise, break loop
    A_Clipboard := clip_bak                         ; Restore original clipboard contents
}

;----------------- Navigation ---------------------

+^!Up::Tabber.CycleClasses("prev")    
+^!Down::Tabber.CycleClasses("next")
+^!Left::Tabber.CycleWindows("prev")
+^!Right::Tabber.CycleWindows("next")

;----------------- Microsoft ---------------------
; Outlook
; Insert Signature

^+i::{
	sleep 250
	Send("{Alt}e2as{Enter}")
}
