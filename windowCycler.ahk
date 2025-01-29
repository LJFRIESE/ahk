; Global variables
global currentWindowIndex := Map()
; Show tooltip with class info and window titles
ShowInfo(windows, currentClass) {
    text := ""

    ; Build tooltip text
    for _class in windows {
        hwndList := windows[_class]
        if (_class = currentClass) {
            text .= ">> " _class " [" hwndList.Length "]`n"
            ; Show titles for current class
            for hwnd in hwndList {
                title := WinGetTitle(hwnd)
                if StrLen(title) > 60
                    title := SubStr(title, 1, 57) . "..."

                if (title = WinGetTitle("A"))
                    text .= "      → " title "`n"
                else
                    text .= "          " title "`n"
            }
        } else {
            text .= "      " _class " [" hwndList.Length "]`n"
        }
    }

    ScriptStatusGui(text, "cursor", 2000)
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

        ; initialize a blank string instead of array
        if !windows.Has(procName)
           windows[procName] := ''

        ; hwnd is no longer an Integer, so it needs winTitle criteria
        ; newline is the default delimiter for Sort
        windows[procName] .= 'ahk_id ' . hwnd . '`n'
    }
    ; sort the strings, trim the final newline, and split into array
    for procName, hwnds in windows {
        windows[procName] := StrSplit(Trim(Sort(hwnds),'`n'), '`n')
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
    for _class in windows {
        classes.Push(_class)
    }

    ; Find current class index
    currentClass := WinGetProcessName("A")
    currentIdx := 1
    for i, _class in classes {
        if (_class = currentClass) {
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
