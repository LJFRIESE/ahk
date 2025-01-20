#Requires AutoHotkey v2.0
#SingleInstance

; Global variables
global currentWindowIndex := Map()

; Show tooltip with class info and window titles
ShowInfo(windows, currentClass) {
    text := ""

    ; Build tooltip text
    for class in windows {
        hwndList := windows[class]
        if (class = currentClass) {
            text .= ">> " class " [" hwndList.Length "]`n"
            ; Show titles for current class
            for hwnd in hwndList {
                title := WinGetTitle(hwnd)
                if StrLen(title) > 60
                    title := SubStr(title, 1, 57) . "..."
                
                if (hwnd = WinGetID("A"))
                    text .= "      → " title "`n"
                else
                    text .= "          " title "`n"
            }
        } else {
            text .= "      " class " [" hwndList.Length "]`n"
        }
    }
    
    ToolTip text
    SetTimer () => ToolTip(), -1500
}

; Get windows grouped by class
GetWindowsByClass() {
    windows := Map()
    for hwnd in WinGetList() {
        ; Skip if no title
        title := WinGetTitle(hwnd)
        if (!title || title = "Program Manager")
            continue
            
        ; Skip AutoHotkey windows
        procName := WinGetProcessName(hwnd)
        if (procName = "AutoHotkey64.exe")
            continue
            
        if !windows.Has(procName)
            windows[procName] := []
            
        windows[procName].Push(hwnd)
    }
    return windows
}

; Cycle between classes
CycleClasses(direction) {
    windows := GetWindowsByClass()
    if !windows.Count
        return
        
    ; Get sorted list of classes
    classes := []
    for class in windows
        classes.Push(class)
      
    ; Find current class index
    currentClass := WinGetProcessName("A")
    currentIdx := 1
    for i, class in classes {
        if (class = currentClass) {
            currentIdx := i
            break
        }
    }
    
    ; Calculate next class
    if (direction = "next")
        nextIdx := currentIdx = classes.Length ? 1 : currentIdx + 1
    else
        nextIdx := currentIdx = 1 ? classes.Length : currentIdx - 1
        
    ; Switch to first window of next class
    nextClass := classes[nextIdx]
    WinActivate windows[nextClass][1]
    
    ShowInfo(windows, nextClass)
}

; Cycle windows within current class
CycleWindows(direction) {
    windows := GetWindowsByClass()
    currentClass := WinGetProcessName("A")
    
    if !windows.Has(currentClass)
        return
        
    if !currentWindowIndex.Has(currentClass)
        currentWindowIndex[currentClass] := 1
        
    classWindows := windows[currentClass]
    currentIdx := currentWindowIndex[currentClass]
    
    if (direction = "next")
        currentWindowIndex[currentClass] := currentIdx = classWindows.Length ? 1 : currentIdx + 1
    else
        currentWindowIndex[currentClass] := currentIdx = 1 ? classWindows.Length : currentIdx - 1
        
    WinActivate classWindows[currentWindowIndex[currentClass]]
    ShowInfo(windows, currentClass)
}

; Hotkeys
^+Up::CycleClasses("prev")
^+Down::CycleClasses("next")
^+Left::CycleWindows("prev")
^+Right::CycleWindows("next")