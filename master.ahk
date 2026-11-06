#Requires AutoHotkey v2.0
#WinActivateForce
#SingleInstance
#HotIfTimeout 250
#Warn

;SetTitleMatchMode("RegEx")

DetectHiddenWindows false

InstallKeybdHook
InstallMouseHook

#Include Imports/Functions.ahk
#Include Imports/VimMode.ahk
#Include Imports/AppLaunchers.ahk
#Include Imports/ActionMenu.ahk
#Include Imports/RemoteWork.ahk
#Include Imports/Macros.ahk

; #Include Imports/F24WinBridge.ahk
;#Include Imports/komorebi.ahk


global A_Local := "C:\Users\" . A_UserName . "\AppData\Local"

; Leader
!+^Space:: {
    ActionMenu.Menu_Main()
}

#Hotstring EndChars `n`tG 
#Hotstring o

::idk::¯\_(ツ)_/¯

::fml::(╯°□°)╯︵ ┻━┻

::_(::🙃

::chr::Cheers,`n`nLucas

::ctd::{
	Send(FormatTime(, "yyyy-MM-dd"))
}
	
::tm::™
 
