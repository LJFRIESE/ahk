#Requires AutoHotkey v2.0
#WinActivateForce
#SingleInstance
#Warn
#HotIfTimeout 250

#Include Imports.ahk

global A_Local := "C:\Users\" . A_UserName . "\AppData\Local"

; Keyboard Layer 2
HotkeyGuide.RegisterHotkey("AHK Control", "~","Layer Switch (Hold)")

HotkeyGuide.RegisterHotkey("Layer 2 - Numpad", "^1-9","21, F22, F13-19")
HotkeyGuide.RegisterHotkey("Layer 2 - Alpha", "x","Copy whole line")
HotkeyGuide.RegisterHotkey("Layer 2 - Alpha", "c","Cut whole line")
HotkeyGuide.RegisterHotkey("Layer 2 - Alpha", "d","Delete whole line")
HotkeyGuide.RegisterHotkey("Layer 2 - Alpha", "d","Delete whole line")
HotkeyGuide.RegisterHotkey("Layer 2 - Arrows", "^Left","Previous application")
HotkeyGuide.RegisterHotkey("Layer 2 - Arrows", "^Right","Next Song")
HotkeyGuide.RegisterHotkey("Layer 2 - Arrows", "^Up/Down","Volume Up/Down")

; Macro record
;HotkeyGuide.RegisterHotkey("Macros", "F1{short hold}", "Record")
;HotkeyGuide.RegisterHotkey("Macros", "F1{long hold}", "Inspect recording")


HotkeyGuide.RegisterHotkey("AHK Control", "Esc&&Space", "␣ (Leader)")
HotkeyGuide.RegisterHotkey("AHK Control", "␣Space", "Open Action Menu")
; Leader
~Esc & Space:: {
    SetScrollLockState 1
    ; Waits for the user to press any key.
    KeyWaitAny()
     SetScrollLockState 0
}

;HotkeyGuide.RegisterHotkey("Top layer - Misc", "␣x", "Close window")
HotkeyGuide.RegisterHotkey("Top layer - Misc", "␣h", "Show keymap guide")
;HotkeyGuide.RegisterHotkey("Top layer - Misc", "␣Arrows", "Win+Arrows")
#HotIf GetKeyState("ScrollLock", "T")
	; Everything is passed through with ~ and then eaten by KeyWaitAny to toggle off ScrollLock
	~Space:: ActionMenu.Menu_Main()
	~h:: HotkeyGuide.Show() ; Show help poppup
	
	;Unneeded if keeping komorebi
	;~x:: WinClose("A")

	; Window Control
	;*~Left:: Send "{Blind}#{Left}"
	;*~Up:: Send "{Blind}#{Up}"
	;*~Down:: Send "{Blind}#{Down}"
	;*~Right:: Send "{Blind}#{Right}"
#HotIf
