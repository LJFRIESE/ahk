#Requires AutoHotkey v2.0
#WinActivateForce
#SingleInstance
#Warn
#HotIfTimeout 250

#Include Functions.ahk

; Block Win keys
#^!Shift:: Send "{Blind}{vk07}"
#^+Alt:: Send "{Blind}{vk07}"
#!+Ctrl:: Send "{Blind}{vk07}"
^!+LWin:: Send "{Blind}{vk07}"
^!+RWin:: Send "{Blind}{vk07}"

; AHK Control
#Include Functions.ahk
; HotkeyGuide.RegisterHotkey("AHK Control", "<^<!<+s", "RunAllScripts")
HotkeyGuide.RegisterHotkey("AHK Control", "{leader}l", "ShowActiveScripts")
HotkeyGuide.RegisterHotkey("AHK Control", "<^<!<+r", "ReloadAllScripts")
; <^<!<+s:: RunAllScripts()     ; Meh + S to run all scripts


; Hotkeys
#Include ActionMenu.ahk
HotkeyGuide.RegisterHotkey("Hotkeys", "Esc Space", "Leader")
HotkeyGuide.RegisterHotkey("Hotkeys", "{leader}Space", "Open Action Menu")
HotkeyGuide.RegisterHotkey("Hotkeys", "<!<+", "Win key rebind")
HotkeyGuide.RegisterHotkey("Hotkeys", "{leader}+S", "SnippingTool")
    ; Leader
~Esc & Space::{
    SetScrollLockState 1
    Sleep 1000
    SetScrollLockState 0
}
#HotIf GetKeyState("ScrollLock", "T")
    Space:: Menu_Main()
    h::HotkeyGuide.Show() ; Show help popup
    l:: ShowActiveScripts()
    k:: KillActiveScripts()
    w:: KeyWait("Esc", "d") ; Keep leader {scrolllock} active
#HotIf

    ; Misc
; <!<+::#
^+S::Run "SnippingTool"

; Nav
#Include windowCycler.ahk
HotkeyGuide.RegisterHotkey("Navigation", "^+Up", "Cylce between applications")
HotkeyGuide.RegisterHotkey("Navigation", "^+Down", "Cylce between applications")
HotkeyGuide.RegisterHotkey("Navigation", "^+Left", "Select application windo")
HotkeyGuide.RegisterHotkey("Navigation", "^+Right", "Select application window")
^+Up::CycleClasses("prev")
^+Down::CycleClasses("next")
^+Left::CycleWindows("prev")
^+Right::CycleWindows("next")

; Numpad Mouse
#Include NumpadMouse.ahk
HotkeyGuide.RegisterHotkey("Numpad Mouse", "ScrollLock", "Enable/disable Numpad Mouse")
HotkeyGuide.RegisterHotkey("Numpad Mouse", "NumLock", "Activate NumpadMouse")

; Misc
#Include openWith.ahk
HotkeyGuide.RegisterHotkey("Misc", "<^<!<+#F1", "Edit Registry for Neovim defaults")

; Macro record
HotkeyGuide.RegisterHotkey("Macros", "F1{short hold}", "Record")
HotkeyGuide.RegisterHotkey("Macros", "F1{long hold}", "Inspect recording")
#Include Recorder.ahk
