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

;tt := "ahk ahk_class CabinetWClass"
;WinWait(tt)
;if (!WinActive(tt))
;  WinActivate(tt)

;Sleep(234)

Send "{Blind}asd"


}
ExitApp()

F1::ExitApp()
