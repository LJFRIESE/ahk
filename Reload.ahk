#Requires AutoHotkey v2.0
#NoTrayIcon
#SingleInstance

#Include Functions.ahk

<^<!<+r::ReloadAllScripts()
; Function to reload all running AHK scripts
ReloadAllScripts() {
    ; Enable detection of hidden windows since AHK windows might be hidden
    DetectHiddenWindows(true)
    
    ; Get all windows with AutoHotkey class
    winList := WinGetList("ahk_class AutoHotkey")
    
    if !winList.Length {
        FlashMessage("No AutoHotkey scripts found running.")
        return
    }
    
    reloadedCount := 0
    failedCount := 0
    
    ; Get the full path of the current script
    currentScript := A_ScriptFullPath
    
    ; Process each AHK window
    for hwnd in winList {
        try {
            ; Get the window's title (which starts with the script path)
            windowTitle := WinGetTitle("ahk_id " hwnd)
            
            ; Extract the script path from the window title
            ; The title usually contains the path followed by " - AutoHotkey v2"
            if (InStr(windowTitle, " - AutoHotkey")) {
                scriptPath := SubStr(windowTitle, 1, InStr(windowTitle, " - AutoHotkey") - 1)
            } else {
                scriptPath := windowTitle  ; Fallback if title format is different
            }
            
            ; Skip the current script to avoid self-termination
            if (scriptPath = currentScript) {
                continue
            }
             ; Skip the master cause it breaks
            if (InStr(scriptPath,"master.ahk")) {
                continue
            }           
            PostMessage(0x111, 65400, 0,, "ahk_id " hwnd)  ; 65400 is the Reload command
            reloadedCount++
            Sleep(100)  ; Give each script time to reload
        } catch Error as e {
            failedCount++
            MsgBox("Failed to reload script: " scriptPath "`nError: " e.Message)
        }
    }
    
    ; Show results
    resultMsg := "Successfully reloaded: " reloadedCount "`n"
    if (failedCount > 0)
        resultMsg .= "Failed to reload: " failedCount
   
   FlashMessage(resultMsg)
    ;MsgBox(resultMsg)
}