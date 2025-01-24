#Requires AutoHotkey v2.0
#WinActivateForce
#SingleInstance
#Warn
#HotIfTimeout 250

Persistent

#Include Functions.ahk


; AHK Control
#Include Functions.ahk
HotkeyGuide.RegisterHotkey("AHK Control", "{leader}l", "ShowActiveScripts")
HotkeyGuide.RegisterHotkey("AHK Control", "{leader}k", "KillActiveScripts")

; Nav
HotkeyGuide.RegisterHotkey("Navigation", "+!Up", "Cylce between applications")
HotkeyGuide.RegisterHotkey("Navigation", "+!Down", "Cylce between applications")
HotkeyGuide.RegisterHotkey("Navigation", "+!Left", "Select application windo")
HotkeyGuide.RegisterHotkey("Navigation", "+!Right", "Select application window")

HotkeyGuide.RegisterHotkey("Navigation", "{leader}Arrow", "Win + Arrow")

; Numpad Mouse
#Include NumpadMouse.ahk
HotkeyGuide.RegisterHotkey("Numpad Mouse", "ScrollLock", "Enable/disable Numpad Mouse")
HotkeyGuide.RegisterHotkey("Numpad Mouse", "NumLock", "Activate NumpadMouse")

; Misc
; #Include openWith.ahk
; HotkeyGuide.RegisterHotkey("Misc", "<^<!<+#F1", "Edit Registry for Neovim defaults")

; Macro record
HotkeyGuide.RegisterHotkey("Macros", "F1{short hold}", "Record")
HotkeyGuide.RegisterHotkey("Macros", "F1{long hold}", "Inspect recording")

; Hotkeys
#Include ActionMenu.ahk
HotkeyGuide.RegisterHotkey("Hotkeys", "Esc Space", "Leader")
HotkeyGuide.RegisterHotkey("Hotkeys", "{leader}Space", "Open Action Menu")
HotkeyGuide.RegisterHotkey("Hotkeys", "^+S", "SnippingTool")


#Include windowCycler.ahk

; Block Win keys
#^!Shift:: Send "{Blind}{vk07}"
#^+Alt:: Send "{Blind}{vk07}"
#!+Ctrl:: Send "{Blind}{vk07}"
^!+LWin:: Send "{Blind}{vk07}"
^!+RWin:: Send "{Blind}{vk07}"

; Always active
^+S::Run "SnippingTool"

+!Up::CycleClasses("prev")
+!Down::CycleClasses("next")
+!Left::CycleWindows("prev")
+!Right::CycleWindows("next")

; Leader
~Esc & Space::{
    SetScrollLockState 1
    Sleep 500
    SetScrollLockState 0
}

F2::ScrollLock

#HotIf GetKeyState("ScrollLock", "T")
    w:: KeyWait("Esc", "d") ; Keep leader {scrolllock} active
    Space:: Menu_Main()
    h::HotkeyGuide.Show() ; Show help pndopup

    ; AHK Control
    ; r:: ReloadAllScripts()
    ; s:: RunAllScripts()
    l:: ShowActiveScripts()
    k:: KillActiveScripts()

    ; Applications
    e:: Run "explorer"
    c:: Run "chrome"

    ; Window Control
    *Left::Send "{blind}#{Left}"
    *Up::Send "blind#{Up}"
    *Down::Send "blind#{Down}"
    *Right::Send "blind#{Right}"
#HotIf

