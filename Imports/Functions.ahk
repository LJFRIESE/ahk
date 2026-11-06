global WinHistory := []
global PendingHwnd := 0
global gLastWinTitle := ""
global WinHook := 0
global WinHookCb := 0
global WinWalkIndex := 1
global WinWalkUntil := 0

InitWindowTracking() {
    global WinHook, WinHookCb
    EVENT_SYSTEM_FOREGROUND := 0x0003
    WINEVENT_OUTOFCONTEXT := 0x0000
    WinHookCb := CallbackCreate(WinEventProc, , 7)
    WinHook := DllCall("SetWinEventHook"
        , "UInt", EVENT_SYSTEM_FOREGROUND
        , "UInt", EVENT_SYSTEM_FOREGROUND
        , "Ptr", 0
        , "Ptr", WinHookCb
        , "UInt", 0
        , "UInt", 0
        , "UInt", WINEVENT_OUTOFCONTEXT)
}

WinEventProc(hHook, event, hwnd, idObject, idChild, idThread, dwmsEventTime) {
    if (idObject != 0 || !hwnd)
        return
    global PendingHwnd
    PendingHwnd := hwnd
    SetTimer(FlushPendingWindow, -50)
}

FlushPendingWindow() {
    global PendingHwnd
    hwnd := PendingHwnd
    PendingHwnd := 0
    if hwnd
        TrackActiveWindow(hwnd)
}

IsTrackableWindow(hwnd) {
    static skipClasses := [
        "Shell_TrayWnd",
        "Shell_SecondaryTrayWnd",
        "Windows.UI.Core.CoreWindow",
        "WinUIDesktopWin32WindowClass",
        "TopLevelWindowForOverflowXamlIsland",
        "XamlExplorerHostIslandWindow",
        "Windows.UI.Composition.DesktopWindowContentBridge",
        "NotifyIconOverflowWindow",
        "TrayNotifyWnd",
        "TaskListThumbnailWnd",
        "MultitaskingViewFrame",
        "Xaml_WindowedPopupClass",
        "#32768"
    ]
    static skipTitles := [
        "justin_prod - DO NOT CLOSE"
    ]
    if !hwnd
        return false
    if !DllCall("IsWindow", "ptr", hwnd)
        return false
    if !DllCall("IsWindowVisible", "ptr", hwnd)
        return false
    cloaked := 0
    if !DllCall("dwmapi\DwmGetWindowAttribute", "ptr", hwnd, "uint", 14, "int*", &cloaked, "int", 4) {
        if cloaked
            return false
    }
    if DllCall("GetWindow", "ptr", hwnd, "uint", 4)
        return false
    try {
        winClass := WinGetClass("ahk_id " hwnd)
        winTitle := WinGetTitle("ahk_id " hwnd)
        if (winTitle = "")
            return false
        for title in skipTitles {
            if (winTitle = title)
                return false
        }
        for cls in skipClasses {
            if (winClass = cls)
                return false
        }
        ex := WinGetExStyle("ahk_id " hwnd)
        if (ex & 0x80) && !(ex & 0x40000)
            return false
    } catch {
        return false
    }
    return true
}

TrackActiveWindow(hNewWin) {
    global WinHistory, gLastWinTitle, WinWalkUntil
    if !IsTrackableWindow(hNewWin)
        return
    try {
        gLastWinTitle := WinGetTitle("ahk_id " hNewWin)
    } catch {
        return
    }
    if A_TickCount < WinWalkUntil
        return
    for i, hwnd in WinHistory {
        if hwnd = hNewWin {
            WinHistory.RemoveAt(i)
            break
        }
    }
    WinHistory.InsertAt(1, hNewWin)
    if WinHistory.Length > 20
        WinHistory.Length := 20
}

CommitWinWalk() {
    global WinWalkUntil, WinWalkIndex
    WinWalkUntil := 0
    WinWalkIndex := 1
    TrackActiveWindow(WinExist("A"))
}

ActivatePreviousWindow() {
    global WinHistory, WinWalkIndex, WinWalkUntil
    if !WinHistory.Length {
        tooltip("hPrevWin not assigned to valid window")
        SetTimer(() => ToolTip(), -500)
        return
    }
    if A_TickCount < WinWalkUntil
        WinWalkIndex++
    else
        WinWalkIndex := 2
    n := WinHistory.Length
    loop n {
        if WinWalkIndex > n
            WinWalkIndex := 1
        hwnd := WinHistory[WinWalkIndex]
        if IsTrackableWindow(hwnd) {
            try {
                WinWalkUntil := A_TickCount + 1200
                SetTimer(CommitWinWalk, -1200)
                WinActivate("ahk_id " hwnd)
                CenterMouse()
                return
            } catch {
            }
        }
        WinWalkIndex++
    }
    tooltip("hPrevWin not assigned to valid window")
    SetTimer(() => ToolTip(), -1000)
}

InitWindowTracking()
TrackActiveWindow(WinExist("A"))

GetGroupWindows(groupName) {
	result := ""

    groupList := WinGetList("ahk_group " groupName)
    for hWnd in groupList {
		result .= WinGetTitle("ahk_id " hWnd) "`n"
		}
		
	;tooltip groupList.length
	;MsgBox(result ? result : "No windows found")	
	return groupList.length
	}

runOrActivateGroup(groupName){
	res := GroupActivate(groupName)
	if (!res and GetGroupWindows(groupName) = 0) {
		return false
    }
	try {
		CenterMouse()
	}
	return true
}

teamsRestore() {
	source := "C:\Users\LUCASFRI\misc\gifs"
	destination := "C:\Users\LUCASFRI\AppData\Local\Packages\MSTeams_8wekyb3d8bbwe\LocalCache\Microsoft\MSTeams\Backgrounds\Uploads"

	if !DirExist(destination)
		DirCreate(destination)
	Loop Files, source "\*.jpg", "F"
		FileCopy(A_LoopFileFullPath, destination "\" A_LoopFileName, true)
	}	
	
RunMSYS2(command) {
    Run(
        'wt C:\Users\LUCASFRI\scoop\apps\msys2\current\msys2_shell.cmd '
        . '-ucrt64 -defterm -here -no-start -shell zsh -ic "' command '"'
    )
}

	
Komorebic(cmd) {
    Run(format("komorebic.exe {}", cmd), , "Hide")
	try {
		CenterMouse()
	}
}


; If application is already running, focus it. Otherwise, launch it.
runOrActivate(name){
  	;if (ProcessExist(name) > 0) & (ProcessExist("komorebi.exe") > 0){
	;	try {
	;		Komorebic("eager-focus " . name)
	;	} catch {
	;		Run(name)
	;	}
	;} else {
		if WinExist("ahk_exe " . name){
			WinActivate()
		} else {
			Run(name)
		}
	;}	
	WinWaitActive("ahk_exe " . name ,,0.1)
	;CenterMouse()
}

CenterMouse() {
    CoordMode("Mouse", "Screen")
    WinGetPos(&OutX, &OutY, &OutWidth, &OutHeight, "A")
    MouseMove(OutX + (OutWidth / 2), OutY + (OutHeight / 2))
}

; Join an array into a string.
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
ScriptStatusGui(message, location := "corner", show := true)
{
    statusGui := Gui("+AlwaysOnTop -Caption +ToolWindow")
    statusGui.Name := "StatusGui"
    statusGui.SetFont("s10", "Segoe UI")
    statusGui.Add("Text", , message)
    statusGui.BackColor := "F0F0F0"

    if (location = "corner") {
    ; Position at bottom right of primary monitor
    MonitorGetWorkArea(1, &left, &top, &right, &bottom)
        statusGui.Show("NoActivate AutoSize x" . (right - 300) . " y" . (bottom - 100))
    }

    if (location = "center"){
        statusGui.Show("NoActivate AutoSize")
    }

    if (location = "cursor"){
        CoordMode "Mouse", "Screen"
        MouseGetPos(&xpos, &ypos)
		if show {
			statusGui.Show("NoActivate x" . xpos . " y" . ypos . " w450")
		}
    }

    return statusGui
}

; AHK Control

KillActiveScripts() {
    DetectHiddenWindows(true)
    AHKList := WinGetList("ahk_exe AutoHotkey.exe")
    closedScripts := []
    for ID in AHKList {
        if (A_ScriptHwnd != ID) {
            closedScripts.Push(WinGetTitle("ahk_id " ID))
            WinClose("ahk_id " ID)
        }
    }

    if closedScripts.Length > 0 {
        message := "Terminated Scripts:`n"
        message .= Join(closedScripts, "`n")
    } else {
        message := "No other scripts found to terminate"
    }

    ScriptStatusGui(message)
    ExitApp()
}



; Function to reload all running AHK scripts
ReloadAllScripts() {
    DetectHiddenWindows(true)
    winList := WinGetList("ahk_class AutoHotkey")

    if !winList.Length {
        ScriptStatusGui("No AutoHotkey scripts found running")
        return
    }

    reloadedScripts := []
    failedScripts := []

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
    ScriptStatusGui(message)
}

GetMonitorInfo(){
	MonitorCount := MonitorGetCount()
	MonitorPrimary := MonitorGetPrimary()
	MsgBox "Monitor Count:`t" MonitorCount "`nPrimary Monitor:`t" MonitorPrimary
	Loop MonitorCount
	{
		MonitorGet A_Index, &L, &T, &R, &B
		MonitorGetWorkArea A_Index, &WL, &WT, &WR, &WB
		MsgBox
		(
			"Monitor:`t#" A_Index "
			Name:`t" MonitorGetName(A_Index) "
			Left:`t" L " (" WL " work)
			Top:`t" T " (" WT " work)
			Right:`t" R " (" WR " work)
			Bottom:`t" B " (" WB " work)"
		)
	}
}
