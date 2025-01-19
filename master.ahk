#Requires AutoHotkey v2.0
#WinActivateForce
#SingleInstance
#Warn
#HotIfTimeout 250

#Include Functions.ahk

#^!Shift:: Send "{Blind}{vk07}"
#^+Alt:: Send "{Blind}{vk07}"
#!+Ctrl:: Send "{Blind}{vk07}"
^!+LWin:: Send "{Blind}{vk07}"
^!+RWin:: Send "{Blind}{vk07}"

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
            ScriptStatusGui("Failed to run: " . A_LoopFilePath . "`nError: " . e.Message)
        }

        Sleep(100)
    }

    ; Show status popup
    if scriptCount > 0 {
        message := "Started " scriptCount " scripts:`n"
        message .= Join(startedScripts, "`n")
        ScriptStatusGui(message, 3000)
    } else {
        ScriptStatusGui("No new scripts started")
    }

}

; Show active scripts
ShowActiveScripts() {
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

    ScriptStatusGui(message)
}

KillActiveScripts() {
    DetectHiddenWindows(true)
    winList := WinGetList("ahk_class AutoHotkey")
    killedScripts := []
    currentScriptId := WinGetID("A")  ; Get current script's window ID

    for hwnd in winList {
        ; Skip the current script to avoid self-termination
        if (hwnd = currentScriptId)
            continue

        windowTitle := WinGetTitle("ahk_id " hwnd)
        if InStr(windowTitle, " - AutoHotkey") {
            scriptPath := SubStr(windowTitle, 1, InStr(windowTitle, " - AutoHotkey") - 1)
            SplitPath(scriptPath, &scriptName)

            ; Attempt to close the script
            WinClose("ahk_id " hwnd)
            killedScripts.Push(scriptName)
        }
    }

    if killedScripts.Length > 0 {
        message := "Terminated Scripts:`n"
        message .= Join(killedScripts, "`n")
    } else {
        message := "No other scripts found to terminate"
    }

    ScriptStatusGui(message)
}

; Hotkeys
<^<!<+s:: RunAllScripts()     ; Meh + S to run all scripts
<^<!<+l:: ShowActiveScripts() ; Meh + L to list active scripts
<^<!<+k:: KillActiveScripts()     ; Meh + K to kill all scripts
