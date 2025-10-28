#Requires AutoHotkey v2.0
#WinActivateForce
#SingleInstance
#Warn
#HotIfTimeout 250

#Include Imports.ahk

DetectHiddenWindows true

global A_Local := "C:\Users\" . A_UserName . "\AppData\Local"

; Keyboard Layer 2
HotkeyGuide.RegisterHotkey("AHK Control", "~","Layer Switch (Hold)")

HotkeyGuide.RegisterHotkey("Layer 2 - Numpad", "^1-9","21, F22, F13-19")
HotkeyGuide.RegisterHotkey("Layer 2 - Alpha", "x","Copy whole line")
HotkeyGuide.RegisterHotkey("Layer 2 - Alpha", "c","Cut whole line")
HotkeyGuide.RegisterHotkey("Layer 2 - Alpha", "d","Delete whole line")
HotkeyGuide.RegisterHotkey("Layer 2 - Alpha", "d","Delete whole li/ne")
HotkeyGuide.RegisterHotkey("Layer 2 - Arrows", "^Left","Previous application")
HotkeyGuide.RegisterHotkey("Layer 2 - Arrows", "^Right","Next Song")
HotkeyGuide.RegisterHotkey("Layer 2 - Arrows", "^Up/Down","Volume Up/Down")

; Macro record
;HotkeyGuide.RegisterHotkey("Macros", "F1{short hold}", "Record")
;HotkeyGuide.RegisterHotkey("Macros", "F1{long hold}", "Inspect recording")


HotkeyGuide.RegisterHotkey("AHK Control", "Esc&&Space", "␣ (Leader)")
HotkeyGuide.RegisterHotkey("AHK Control", "␣Space", "Open Action Menu") 

HotkeyGuide.RegisterHotkey("Top layer - Misc", "␣h", "Show keymap guide")


; Leader
!+^Space:: {
    ActionMenu.Menu_Main()
}


!+^#n::{
	runOrActivate("notepad++.exe")
}

!+^#e::{
	name := "File Explorer"
	if !WinExist(name){
		run("explorer.exe")
	} else {
		winActivate(name) 
	}
	winWaitActive(name)
}

!+^#o::{
	runOrActivate("OUTLOOK.EXE")
}
!+^#t::{
	runOrActivate("ms-teams.exe")
} 

!+^#c::{ 
	runOrActivate("chrome.exe")
}

!+^#s::{ 
	exe := "SnippingTool.exe"
	if !WinExist("ahk_exe " . exe){
		run("SnippingTool.exe")
	} else {
		winActivate("ahk_exe " . exe) 
	}
	winWaitActive("ahk_exe " . exe)
	Send("^n")
}  
 
!+^#h::{
	runOrActivate("C:\Program Files\Omnissa\Omnissa Horizon Client\horizon-client.exe")
}

!+^#v::{
	RemoteWork.toggleVPN()
}
