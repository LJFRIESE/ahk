#Requires AutoHotkey v2.0
#SingleInstance
#Warn

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
class StatusGui {
    static StatusGui := false

    static Show(message, location:= "corner", duration := 3000) {
        if this.StatusGui {
            this.StatusGui.Destroy()
            this.StatusGui := false
        }
        this.CreateStatusGui(message, location, duration)
        this.StatusGui.Show()
    }

    static Hide() {
        if this.StatusGui
            this.StatusGui.Hide()
    }

   static CreateStatusGui(message, location, duration) {
	this.StatusGui := true
        this.statusGui := Gui("+AlwaysOnTop -Caption +ToolWindow")
        this.statusGui.OnEvent('Escape', (*) => this.statusGui.destroy())

        this.statusGui.SetFont("s10", "Segoe UI")
        this.statusGui.Add("Text", , message)
        this.statusGui.BackColor := "F0F0F0"

        if (location = "corner") {
            ; Position at bottom right of primary monitor
            MonitorGetWorkArea(1, &left, &top, &right, &bottom)
            this.statusGui.Show("NoActivate x" . (right - 300) . " y" . (bottom - 100) . " w280")
            }
            ; Add cursor maybe for else
            if (location = "center"){
                this.statusGui.Show("NoActivate")
            } else {
                this.statusGui.Show("NoActivate")
            }
        }
    }


; Help popup
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
        WinSetTransparent(250, this.overlayGui)

        ; Calculate column widths and positions
        columnWidth := windowWidth / 4

        leftColumnX := "XM"
        rightColumnX := "XS" . columnWidth . " YS"

        ; Track which column we're in (0 = left, 1 = right)
        currentColumn := 0

        for scriptName, hotkeys in this.globalRegistry {
            ; Determine X position based on current column
            xPos := currentColumn = 0 ? leftColumnX : rightColumnX

            ; Add section title
            this.overlayGui.SetFont("s12 w600")
            this.overlayGui.Add("Text", "Section " . xPos . " cFFFFFF", scriptName)

            ; Add hotkeys and descriptions
            for key, desc in hotkeys {
                this.overlayGui.SetFont("s10 w600")
                ; Key
                this.overlayGui.Add("Text", "XS cCCCCCC", this.FormatHotkeyString(key))
                ; Description
                this.overlayGui.SetFont("s10 w400")
                this.overlayGui.Add("Text", "YP cCCCCCC", desc)
            }

            ; Toggle column for next section
            currentColumn := currentColumn = 0 ? 1 : 0
        }

        this.overlayGui.Add("Text", "YP+50 Center cFFFFFF", "Press Escape to Close")
}

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

; AHK Control
RunAllScripts() {
    scriptCount := 0
    startedScripts := []

    Loop Files A_WorkingDir "\*.ahk" {
        if (A_LoopFilePath = A_ScriptFullPath)
            continue
        if (InStr(A_LoopFilePath, "HotkeyGuide"))
            continue

        try {
            Run A_LoopFilePath
            scriptCount++
            startedScripts.Push(A_LoopFileName)
        } catch Error as e {
            StatusGui.Show("Failed to run: " . A_LoopFilePath . "`nError: " . e.Message)
        }

        Sleep(100)
    }

    ; Show status popup
    if scriptCount > 0 {
        message := "Started " scriptCount " scripts:`n"
        message .= Join(startedScripts, "`n")
        StatusGui.Show(message)
    } else {
        StatusGui.Show("No new scripts started")
    }

}

; Show active scripts
ListActiveScripts() {
    DetectHiddenWindows(true)
    winList := WinGetList("ahk_class AutoHotkey")
    activeScripts := []

    for hwnd in winList {
        windowTitle := WinGetTitle("ahk_id " hwnd)
        if InStr(windowTitle, " - AutoHotkey") {
            scriptPath := SubStr(windowTitle, 1, InStr(windowTitle, " - AutoHotkey") - 1)
            SplitPath(scriptPath, &scriptName)
            activeScripts.Push(scriptName)
        }
    }

    if activeScripts.Length > 0 {
        message := "Active Scripts:`n"
        message .= Join(activeScripts, "`n")
    } else {
        message := "No active scripts found"
    }

    StatusGui.Show(message)
}

KillActiveScripts() {
    DetectHiddenWindows(true)
    AHKList := WinGetList("ahk_exe AutoHotkey.exe")
    killedScripts := []
    for ID in AHKList {
        if (A_ScriptHwnd != ID)
            WinClose("ahk_id " ID)
    }

    if killedScripts.Length > 0 {
        message := "Terminated Scripts:`n"
        message .= Join(killedScripts, "`n")
    } else {
        message := "No other scripts found to terminate"
    }

    StatusGui.Show(message)
    ExitApp()
}



; Function to reload all running AHK scripts
ReloadAllScripts() {
    DetectHiddenWindows(true)
    winList := WinGetList("ahk_class AutoHotkey")

    if !winList.Length {
        StatusGui("No AutoHotkey scripts found running")
        return
    }

    reloadedScripts := []
    failedScripts := []
    currentScript := A_ScriptFullPath

    for hwnd in winList {
        try {
            windowTitle := WinGetTitle("ahk_id " hwnd)

            if InStr(windowTitle, " - AutoHotkey") {
                scriptPath := SubStr(windowTitle, 1, InStr(windowTitle, " - AutoHotkey") - 1)
            } else {
                scriptPath := windowTitle
            }

            SplitPath(scriptPath, &scriptName)

            PostMessage(0x111, 65400, 0, , "ahk_id " hwnd)
            reloadedScripts.Push(scriptName)
            Sleep(100)
        } catch Error as e {
            failedScripts.Push(scriptName)
        }
    }

    ; Show status popup
    message := "Reloaded Scripts:`n"
    message .= Join(reloadedScripts, "`n")
    if failedScripts.Length > 0 {
        message .= "`n`nFailed Scripts:`n"
        message .= Join(failedScripts, "`n")
    }
    StatusGui.Show(message)
}
