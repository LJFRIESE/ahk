#Requires AutoHotkey v2.0
#SingleInstance
#Warn

#Include Functions.ahk


; Macro record
HotkeyGuide.RegisterHotkey("Macros", "F1{short hold}", "Record")
HotkeyGuide.RegisterHotkey("Macros", "F1{long hold}", "Inspect recording")

; AHK Control
HotkeyGuide.RegisterHotkey("AHK Control", "<^<!<+s", "RunAllScripts")
HotkeyGuide.RegisterHotkey("AHK Control", "<^<!<+l", "ShowActiveScripts")
HotkeyGuide.RegisterHotkey("AHK Control", "<^<!<+r", "ReloadAllScripts")

; Misc
HotkeyGuide.RegisterHotkey("Hotkeys", "^+S", "SnippingTool")

; Example default usage
; HotkeyGuide.RegisterHotkey("Help", "^h", "Show Hotkey Guide")
; HotkeyGuide.RegisterHotkey("Help", "Esc", "Hide Hotkey Guide")

; Numpad Mouse
HotkeyGuide.RegisterHotkey("Numpad Mouse", "ScrollLock", "Enable/disable Numpad Mouse")
HotkeyGuide.RegisterHotkey("Numpad Mouse", "NumLock", "Activate NumpadMouse")

