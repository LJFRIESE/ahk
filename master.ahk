#WinActivateForce
#SingleInstance force
#Warn
#HotIfTimeout 250

#^!Shift::Send "{Blind}{vk07}"
#^+Alt::Send "{Blind}{vk07}"
#!+Ctrl::Send "{Blind}{vk07}"
^!+LWin::Send "{Blind}{vk07}"
^!+RWin::Send "{Blind}{vk07}"

RunAllScripts() {
    Loop Files A_WorkingDir "\*.ahk" {
        if (A_LoopFilePath = A_ScriptFullPath){
            continue
        }
            
        try Run A_LoopFilePath
        catch Error as e
            MsgBox "Failed to run: " A_LoopFilePath "`nError: " e.Message
            
        Sleep(100)
    }
}

; Hotkey using hyper key
<^<!<+<#s::RunAllScripts()  ; Hyper + A