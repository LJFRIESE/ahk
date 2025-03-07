#Requires AutoHotkey v2.0
#WinActivateForce
#SingleInstance
#Warn
#HotIfTimeout 250

#Include Imports.ahk

; AHK Control
HotkeyGuide.RegisterHotkey("AHK Control", "␣l", "ListActiveScripts")
HotkeyGuide.RegisterHotkey("AHK Control", "␣r", "ReloadAllScripts")
HotkeyGuide.RegisterHotkey("AHK Control", "␣k", "KillActiveScripts")
HotkeyGuide.RegisterHotkey("AHK Control", "~","Layer Switch (Hold)")
HotkeyGuide.RegisterHotkey("AHK Control", "Esc&Space", "␣ (Leader)")
HotkeyGuide.RegisterHotkey("AHK Control", "␣Space", "Open Action Menu")

; Navigation
HotkeyGuide.RegisterHotkey("Navigation", "^!+Up/Down", "Cycle between applications")
HotkeyGuide.RegisterHotkey("Navigation", "^!+Left/Right", "Select application window")
HotkeyGuide.RegisterHotkey("Navigation", "␣Arrow", "Win + Arrow")


; Misc
; HotkeyGuide.RegisterHotkey("Misc", "^!+#F1", "Edit Registry for Neovim defaults")
HotkeyGuide.RegisterHotkey("Misc", "F24", "Toggle Numpad Mouse")
HotkeyGuide.RegisterHotkey("Misc", "F14","Convert to UPPER")
HotkeyGuide.RegisterHotkey("Misc", "F21","Read from tmp.txt")

; Layer 2
HotkeyGuide.RegisterHotkey("Layer 2", "Numpad 1-9","F21, F22, F13-19")
HotkeyGuide.RegisterHotkey("Layer 2", "x","Copy whole line")
HotkeyGuide.RegisterHotkey("Layer 2", "c","Cut whole line")
HotkeyGuide.RegisterHotkey("Layer 2", "d","Delete whole line")
HotkeyGuide.RegisterHotkey("Layer 2", "d","Delete whole line")
HotkeyGuide.RegisterHotkey("Layer 2", "Left","Previous application")
HotkeyGuide.RegisterHotkey("Layer 2", "Right","Next Song")
HotkeyGuide.RegisterHotkey("Layer 2", "Up/Down","Volume Up/Down")

; Macro record
; HotkeyGuide.RegisterHotkey("Macros", "F1{short hold}", "Record")
; HotkeyGuide.RegisterHotkey("Macros", "F1{long hold}", "Inspect recording")



; Leader
~Esc & Space:: {
    SetScrollLockState 1
    ; Waits for the user to press any key.
    KeyWaitAny()
    SetScrollLockState 0
}


#HotIf GetKeyState("ScrollLock", "T")
; Everything is passed through with ~ and then eaten by KeyWaitAny to toggle off ScrollLock
~Space:: Menu_Main()
~h:: HotkeyGuide.Show() ; Show help poppup
~x:: WinClose("A")

; Window Control
*~Left:: Send "{Blind}#{Left}"
*~Up:: Send "{Blind}#{Up}"
*~Down:: Send "{Blind}#{Down}"
*~Right:: Send "{Blind}#{Right}"
#HotIf


