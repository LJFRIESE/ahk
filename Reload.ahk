#Requires AutoHotkey v2.0
#NoTrayIcon
#SingleInstance

#Include Functions.ahk

; Function to reload all running AHK scripts
ReloadAllScripts() {
    DetectHiddenWindows(true)
    winList := WinGetList("ahk_class AutoHotkey")
    
    if !winList.Length {
        ScriptStatusGui.Show("No AutoHotkey scripts found running")
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
            
            if (scriptPath = currentScript || InStr(scriptPath, "master.ahk"))
                continue
            
            PostMessage(0x111, 65400, 0,, "ahk_id " hwnd)
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
    ScriptStatusGui.Show(message, 3500)
}

<^<!<+r::ReloadAllScripts()