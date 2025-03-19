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

MouseClick("L", 821, 469) ;screen

;MouseClick("L", 401, 258) ;window

;MouseClick("L", 821, 469,,,, "R") ;relative

MouseClick("L", 824, 397) ;screen

;MouseClick("L", 404, 186) ;window

;MouseClick("L", 3, -72,,,, "R") ;relative

MouseClick("L", 813, 480) ;screen

;MouseClick("L", 393, 269) ;window

;MouseClick("L", -11, 83,,,, "R") ;relative

MouseClick("L", 818, 411) ;screen

;MouseClick("L", 398, 200) ;window

;MouseClick("L", 5, -69,,,, "R") ;relative

Send "{Blind}{Volume_Mute}"


}
ExitApp()

F1::ExitApp()
