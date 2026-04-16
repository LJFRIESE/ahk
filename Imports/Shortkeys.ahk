#SingleInstance

::idk::¯\_(ツ)_/¯

::fml::(╯°□°)╯︵ ┻━┻

::ctd::{
	Send(FormatTime(, "yyyy-MM-dd"))
}

::^tm::™


;-------------------------------------------------------------------------------
;  VIM
;-------------------------------------------------------------------------------

; Rename with current date
:XEnter::rnctd::
	renameFileCTD(hs)
	{
		Send("{alt}f")
		sleep 500
		Send("{alt}a")
		sleep 1000
		Send("y9")
		sleep 1000
		Send("^c")
		sleep 250
		
		if InStr(A_Clipboard, "YYYY-MM-DD") {
			A_Clipboard := StrReplace(A_Clipboard, "YYYY-MM-DD", FormatTime(, "yyyy-MM-dd"))
		} else {
			A_Clipboard := FormatTime(, "yyyy-MM-dd") . A_Clipboard 
		}
		Send("^v") ; Paste the modified clipboard content
	}

:XEnter::rn::
	renameFile(hs)
	{
		Send("{alt}f")
		sleep 500
		Send("{alt}a")
		sleep 1000
		Send("y9")
	}

