;Press F1 to play. Hold to record. Long hold to edit
;#####SETTINGS#####
;What is the preferred method of recording mouse coordinates (screen,window,relative)
;MouseMode=screen
;Record sleep between input actions (true,false)
;RecordSleep=false
Loop(1)
{

StartingValue := 0
i := RegRead("HKEY_CURRENT_USER\SOFTWARE\" A_ScriptName, "i", StartingValue)
RegWrite(i + 1, "REG_DWORD", "HKEY_CURRENT_USER\SOFTWARE\" A_ScriptName, "i")

SetKeyDelay(30)
SendMode("Event")
SetTitleMatchMode(2)
CoordMode("Mouse", "Screen")
;CoordMode("Mouse", "Window")

;tt := "2025 Reporting Template.xlsx  -  1 - Excel ahk_class XLMAIN"
;WinWait(tt)
;if (!WinActive(tt))
;  WinActivate(tt)

Send "{Blind}{Alt Down}{Alt Up}jyg"

;tt := "ahk_class Net UI Tool Window"
;WinWait(tt)
;if (!WinActive(tt))
;  WinActivate(tt)

Send "{Blind}c"

;tt := "2025 Reporting Template.xlsx  -  1 - Excel ahk_class XLMAIN"
;WinWait(tt)
;if (!WinActive(tt))
;  WinActivate(tt)


}
ExitApp()

F1::ExitApp()
