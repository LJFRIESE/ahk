#Requires AutoHotkey v2.0
#NoTrayIcon
#SingleInstance
#Warn

; Macro record
HotkeyGuide.RegisterHotkey("Macros", "F1{short hold}", "Record")
HotkeyGuide.RegisterHotkey("Macros", "F1{long hold}", "Inspect recording")

; AHK Control
HotkeyGuide.RegisterHotkey("AHK Control", "<^<!<+s", "RunAllScripts")
HotkeyGuide.RegisterHotkey("AHK Control", "<^<!<+l", "ShowActiveScripts")
HotkeyGuide.RegisterHotkey("AHK Control", "<^<!<+r", "ReloadAllScripts")

; Misc
HotkeyGuide.RegisterHotkey("Hotkeys", "^+S", "SnippingTool")
HotkeyGuide.RegisterHotkey("Misc", "<^<!<+#F1", "Edit Registry for Neovim defaults")

; Example default usage
; HotkeyGuide.RegisterHotkey("Help", "^h", "Show Hotkey Guide")

; Numpad Mouse
HotkeyGuide.RegisterHotkey("Numpad Mouse", "ScrollLock", "Enable/disable Numpad Mouse")
HotkeyGuide.RegisterHotkey("Numpad Mouse", "NumLock", "Activate NumpadMouse")


^+Left::#Left
^+Right::#Right
^+Up::#Up
^+Down::#Down

^+S::Run "SnippingTool"

; Utility function
Join(arr, delimiter := ",") {
    result := ""
    for index, value in arr {
        if index > 1
            result .= delimiter
        result .= value
    }
    return result
}

; Create GUI for status popup
ScriptStatusGui(message, duration := 3000)
{
    statusGui := Gui("+AlwaysOnTop -Caption +ToolWindow")
    statusGui.SetFont("s10", "Segoe UI")
    statusGui.Add("Text", , message)
    statusGui.BackColor := "F0F0F0"

    ; Position at bottom right of primary monitor
    MonitorGetWorkArea(1, &left, &top, &right, &bottom)
    statusGui.Show("NoActivate x" . (right - 300) . " y" . (bottom - 100) . " w280")

    statusGui.Show()

    SetTimer(() => statusGui.Destroy(), -duration)

}

    global windowWidth := A_ScreenWidth*.7
    global windowHight := A_ScreenHeight*.7

class HotkeyGuide {
    static overlayGui := false
    static globalRegistry := Map()

    static RegisterHotkey(script, hotkeyStr, description) {
        if !this.globalRegistry.Has(script)
            this.globalRegistry[script] := Map()
        this.globalRegistry[script][hotkeyStr] := description
    }

    static Show() {
        if this.overlayGui {
            this.overlayGui.Destroy()
            this.overlayGui := false
        }
        this.CreateOverlay()
        this.overlayGui.Show("AutoSize")

    }

    static Hide() {
        if this.overlayGui
            this.overlayGui.Hide()
    }

    static CreateOverlay() {
        this.overlayGui := Gui("+AlwaysOnTop -Caption +E0x20 +Owner")
        this.overlayGui.BackColor := "222222"
        this.overlayGui.MarginY := 10
        this.overlayGui.OnEvent('Escape', (*) => this.overlayGui.Hide())
        WinSetTransparent(200, this.overlayGui)

        itemsPerRow := 5

	groups := this.globalRegistry.Count

        for scriptName, hotkeys in this.globalRegistry {
	    this.overlayGui.SetFont("s10 w600")
		; Title
	    this.overlayGui.Add("Text", "Section XM YP+40 cFFFFFF", scriptName)
		item := 0

            for key, desc in hotkeys {
    		this.overlayGui.SetFont("s10 w400")
		; Key
		this.overlayGui.Add("Text", "XM cFFFFFF", this.FormatHotkeyString(key))
        	; Description
		this.overlayGui.Add("Text", "YP cCCCCCC", desc)
                item += 1
	   }
        }

        this.overlayGui.Add("Text", "YP+50 Center cFFFFFF", "Press Escape to Close")
    }

   ; static AddSection(title, items) {
    ;
    ;}

    static FormatHotkeyString(hotkeyStr) {
	formatted := StrReplace(hotkeyStr, "<^<!<+#", "Hyper-")
	formatted := StrReplace(formatted, "<^<!<+", "Meh-")
        formatted := StrReplace(formatted, "<", "L") ;Has to happen after Meh/Hyper
        formatted := StrReplace(formatted, ">", "R") ;Has to happen after Meh/Hyper
        formatted := StrReplace(formatted, "+", "Shift+") ;Has to happen after Meh/Hyper
        formatted := StrReplace(formatted, "^", "Ctrl+")
        formatted := StrReplace(formatted, "!", "Alt+")
        formatted := StrReplace(formatted, "#", "Win+")
        formatted := StrReplace(formatted, "-", "+") ; Clean up the Meh/Hyper
        return formatted
    }
}


^h::HotkeyGuide.Show()
