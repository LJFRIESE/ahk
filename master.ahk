#Requires AutoHotkey v2.0
#WinActivateForce
#SingleInstance
#Warn
#HotIfTimeout 250

Persistent

#Include Functions.ahk


; AHK Control
HotkeyGuide.RegisterHotkey("AHK Control", "{leader}l", "ListActiveScripts")
HotkeyGuide.RegisterHotkey("AHK Control", "{leader}r", "ReloadAllScripts")
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
; HotkeyGuide.RegisterHotkey("Hotkeys", "^+S", "SnippingTool")


#Include windowCycler.ahk

; Always active

 +!Up::Tabber.CycleClasses("prev")
 +!Down::Tabber.CycleClasses("next")
 +!Left::Tabber.CycleWindows("prev")
 +!Right::Tabber.CycleWindows("next")

F13::ScrollLock

KeyWaitAny(Options:="")
{
    ih := InputHook(Options)
    if !InStr(Options, "V")
        ih.VisibleNonText := false
    ih.KeyOpt("{All}", "E")  ; End
    ih.KeyOpt("{LCtrl}{RCtrl}{LAlt}{RAlt}{LShift}{RShift}{LWin}{RWin}", "-E")
    ih.Start()
    ih.Wait()
    return ih.EndKey  ; Return the key name
}

; Leader
~Esc & Space::{
    SetScrollLockState 1
    ; Waits for the user to press any key.
    KeyWaitAny()
    SetScrollLockState 0
}


#HotIf GetKeyState("ScrollLock", "T")
    ; Everything is passed through with ~ and then eaten by KeyWaitAny to toggle off ScrollLock
    ~Space:: Menu_Main()
    ~h::HotkeyGuide.Show() ; Show help poppup
    ~x::WinClose("A")

    ; Window Control
    *Left::Send "{Blind}#{Left}"
    *Up::Send "{Blind}#{Up}"
    *Down::Send "{Blind}#{Down}"
    *Right::Send "{Blind}#{Right}"

#HotIf

