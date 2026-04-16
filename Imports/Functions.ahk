#Requires AutoHotkey v2.0
#SingleInstance
#Warn

InstallKeybdHook
InstallMouseHook

#h::  ; Win+H hotkey
{
    ; Get the text currently selected. The clipboard is used instead of
    ; EditGetSelectedText because it works in a greater variety of editors
    ; (namely word processors). Save the current clipboard contents to be
    ; restored later. Although this handles only plain text, it seems better
    ; than nothing:
    ClipboardOld := A_Clipboard
    A_Clipboard := "" ; Must start off blank for detection to work.
    Send "^c"
    if !ClipWait(1)  ; ClipWait timed out.
    {
        A_Clipboard := ClipboardOld ; Restore previous contents of clipboard before returning.
        return
    }
    ; Replace CRLF and/or LF with `n for use in a "send-raw" hotstring:
    ; The same is done for any other characters that might otherwise
    ; be a problem in raw mode:
    ClipContent := StrReplace(A_Clipboard, "``", "````")  ; Do this replacement first to avoid interfering with the others below.
    ClipContent := StrReplace(ClipContent, "`r`n", "``n")
    ClipContent := StrReplace(ClipContent, "`n", "``n")
    ClipContent := StrReplace(ClipContent, "`t", "``t")
    ClipContent := StrReplace(ClipContent, "`;", "```;")
    A_Clipboard := ClipboardOld  ; Restore previous contents of clipboard.
    ShowInputBox(":T:::" ClipContent)
}

ShowInputBox(DefaultValue)
{
    ; This will move the input box's caret to a more friendly position:
    SetTimer MoveCaret, 10
    ; Show the input box, providing the default hotstring:
    IB := InputBox("
    (
    Type your abbreviation at the indicated insertion point. You can also edit the replacement text if you wish.

    Example entry: :T:btw::by the way
    )", "New Hotstring",, DefaultValue)
    if IB.Result = "Cancel"  ; The user pressed Cancel.
        return

    if RegExMatch(IB.Value, "(?P<Label>:.*?:(?P<Abbreviation>.*?))::(?P<Replacement>.*)", &Entered)
    {
        if !Entered.Abbreviation
            MsgText := "You didn't provide an abbreviation"
        else if !Entered.Replacement
            MsgText := "You didn't provide a replacement"
        else
        {
            Hotstring Entered.Label, Entered.Replacement  ; Enable the hotstring now.
            FileAppend "`n" IB.Value, A_ScriptFullPath  ; Save the hotstring for later use.
        }
    }
    else
        MsgText := "The hotstring appears to be improperly formatted"

    if IsSet(MsgText)
    {
        Result := MsgBox(MsgText ". Would you like to try again?",, 4)
        if Result = "Yes"
            ShowInputBox(DefaultValue)
    }
    
    MoveCaret()
    {
        WinWait "New Hotstring"
        ; Otherwise, move the input box's insertion point to where the user will type the abbreviation.
        Send "{Home}{Right 3}"
        SetTimer , 0
    }
}

;Image search
findImage(){
	CoordMode "Pixel"  ; Interprets the coordinates below as relative to the screen rather than the active window's client area.
	VirtualWidth := SysGet(78)
	VirtualHeight := SysGet(79)
	
	try
	{
		if ImageSearch(&FoundX, &FoundY, 0, 0, VirtualWidth, VirtualHeight, "C:\Users\LUCASFRI\Microsoft\Pictures\Capture.png")
			MsgBox "The icon was found at " FoundX "x" FoundY
		else
			MsgBox "Icon could not be found on the screen."
	}
	catch as exc
		MsgBox "Could not conduct the search due to the following error:`n" exc.Message
}
	
Komorebic(cmd) {
     Run(format("komorebic.exe {}", cmd), , "Hide")
}

; If application is already running, focus it. Otherwise, launch it.
runOrActivate(name){
  	if ProcessExist(name) = 0 {
		Run(name)
		WinWaitActive("ahk_exe " . name)
	} else {
		if WinExist("Omnissa Horizon - Google Chrome") {
			Run(name)
			WinWaitActive("A")	
		}
	}
	
	if ProcessExist("komorebi.exe") > 0 {
		Komorebic("eager-focus " . name) ; Going twice gets hidden floats in focus. 
		Komorebic("eager-focus " . name)
	} else {
		WinWaitActive("ahk_exe " . name)
	}
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
