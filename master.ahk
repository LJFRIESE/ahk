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
#Include Imports/WindowManagement.ahk
#Include Imports/InputGuard.ahk
#Include Imports/VimMode.ahk
#Include Imports/AppLaunchers.ahk
#Include Imports/MenuEngine.ahk
#Include Imports/ActionMenu.ahk
#Include Imports/RemoteWork.ahk
#Include Imports/Macros.ahk
#Include Imports/MonitorFocus.ahk

#Include Imports/Leader.ahk
;#Include Imports/komorebi.ahk


global A_Local := "C:\Users\" . A_UserName . "\AppData\Local"

; Release modifier keys that a hotkey or Send leaves logically down.
InputGuard.Start()

; Leader
!+^Space:: {
    ActionMenu.Menu_Main()
}

F24::Leader.Toggle()

; While the leader is active, Ctrl+W drives the hidden Window entry, mirroring
; nvim's <C-w> prefix. Outside the leader, ^w keeps its normal behaviour.
#HotIf MenuEngine.Active && MenuEngine.Id = "Leader"
$^w::MenuEngine.Push(Leader.Window())
#HotIf

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
 
