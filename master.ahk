#Requires AutoHotkey v2.0
#WinActivateForce
#SingleInstance
#Warn
#HotIfTimeout 250

#Include Imports.ahk

DetectHiddenWindows true

global A_Local := "C:\Users\" . A_UserName . "\AppData\Local"

; Macro record
;HotkeyGuide.RegisterHotkey("Macros", "F1{short hold}", "Record")
;HotkeyGuide.RegisterHotkey("Macros", "F1{long hold}", "Inspect recording")

; Leader
!+^Space:: {
    ActionMenu.Menu_Main()
}

+#n::{
	runOrActivate("notepad++.exe")
}


+#.::{
	explorerTitle := "ahk_exe explorer.exe"
	if WinExist(explorerTitle) {
		WinActivate(explorerTitle)
	} else {
		Run("explorer.exe")
	}
	WinWaitActive(explorerTitle)
}

+#o::{
	runOrActivate("OUTLOOK.EXE")
}
+#t::{
	runOrActivate("ms-teams.exe")
} 

+#Enter::{
	runOrActivate("wt.exe")
} 

+#b::{ 
	runOrActivate("chrome.exe")
}

+#s::{ 
	exe := "SnippingTool.exe"
	if !WinExist("ahk_exe " . exe){
		run("SnippingTool.exe")
	} else {
		winActivate("ahk_exe " . exe) 
	}
	winWaitActive("ahk_exe " . exe)
	Send("^n")
}  
 
+#h::{
	runOrActivate("C:\Program Files\Omnissa\Omnissa Horizon Client\horizon-client.exe")
}

+#v::{
	RemoteWork.toggleVPN()
}

#Requires AutoHotkey v2.0

; Disable certain shortcuts when Chrome tab title contains "Omnissa Horizon"
#HotIf WinActive("ahk_exe chrome.exe") && InStr(WinGetTitle("A"), "Omnissa Horizon")
^w::
{
        ; Pass Ctrl+W into the VM by releasing Ctrl and pressing w directly
        ; This prevents Chrome from intercepting it
        Send "{Ctrl up}w{Ctrl down}" 
}
^n::Send "{Ctrl up}n{Ctrl down}"
^t::Send "{Ctrl up}t{Ctrl down}"


#HotIf

; Excel hotkey: Ctrl+Shift+S → Save As
#HotIf WinActive("ahk_exe excel.exe")
^+s::Send("!fa")
#HotIf

  
