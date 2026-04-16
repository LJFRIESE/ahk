#Requires AutoHotkey v2.0
#WinActivateForce
#SingleInstance
#Warn
#HotIfTimeout 250

#Include Imports.ahk

DetectHiddenWindows true

global A_Local := "C:\Users\" . A_UserName . "\AppData\Local"

; Leader
!+^Space:: {
    ActionMenu.Menu_Main()
}
