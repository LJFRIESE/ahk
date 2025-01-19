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
    scripts := WinGetList("ahk_class AutoHotkey")
    ; Loop through each script window
    for hwnd in scripts {
        ; Get the process ID of the script
        pid := WinGetPID(hwnd)

        ; Get the process name to verify it's an AHK script
        procName := WinGetProcessName(hwnd)

        ; Only close if it's actually an AutoHotkey process
        if (InStr(procName, "AutoHotkey")) {
            ; Skip the current script
            if (pid != ProcessExist()) {
                killedScripts.Push(pid)
                ProcessClose(pid)
            }
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
