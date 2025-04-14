#SingleInstance

MacroRecorder.__New()
^Esc::MacroRecorder.Quit()

class MacroRecorder {
    static LogFile := A_ScriptDir . "\MacroRecorder\macro1.ahk"
    static Recording := false
    static Playing := false
    static ActionKey := "F1"
    static LogArr := []

    static id := ""
    static title := ""
    static oldid := ""
    static oldtitle := ""
    static RelativeX := 0
    static RelativeY := 0

	static Quit() {
		ExitApp()
	}

    static __New() {
        Thread("NoTimers")
        CoordMode("ToolTip")
        SetTitleMatchMode(2)
        DetectHiddenWindows(true)

        this.UpdateSettings()

        Hotkey(this.ActionKey, this.KeyAction.Bind(this))
    }


    static ShowTip(s := "", pos := "y35", color := "Red|00FFFF") {
        static bak := "", idx := 0, ShowTip := Gui(), RecordingControl
        if (bak = color "," pos "," s) {
            return
        }

        bak := color "," pos "," s
        SetTimer(ShowTip_ChangeColor, 0)
        ShowTip.Destroy()
        if (s = "") {
            return
        }

        ShowTip := Gui("+LastFound +AlwaysOnTop +ToolWindow -Caption +E0x08000021", "ShowTip")
        WinSetTransColor("FFFFF0 150")
        ShowTip.BackColor := "cFFFFF0"
        ShowTip.MarginX := 11
        ShowTip.MarginY := 5
        ShowTip.SetFont("q3 s20 bold cRed")
        RecordingControl := ShowTip.Add("Text", , s)
        ShowTip.Show("NA " . pos)

        SetTimer(ShowTip_ChangeColor, 1000)

        ShowTip_ChangeColor() {
            r := StrSplit(SubStr(bak, 1, InStr(bak, ",") - 1), "|")
            RecordingControl.SetFont("q3 c" r[idx := Mod(Round(idx), r.Length) + 1])
            return
        }
    }

    ;============ Hotkey =============

    static KeyAction(HotkeyName) {
        if (this.Recording) {
            this.Stop()
            return
        }

        KeyDown := A_TickCount
        loop {
            Duration := A_TickCount - KeyDown
            if (Duration < 400) {
                this.ShowTip()
                if (!GetKeyState(this.ActionKey)) {
                    this.ShowTip()
                    this.PlayKeyAction()
                    break
                }
            } else if (Duration < 1400) {
                this.ShowTip("RECORD")
                if (!GetKeyState(this.ActionKey)) {
                    this.ShowTip()
                    this.RecordKeyAction()
                    break
                }
            } else {
                this.ShowTip("SHOW SOURCE")
                if (!GetKeyState(this.ActionKey)) {
                    this.ShowTip()
                    this.EditKeyAction()
                    break
                }
            }
        }
    }

    static RecordKeyAction() {
        if (this.Recording) {
            this.Stop()
            return
        }
        #SuspendExempt
        this.RecordScreen()
    }

    static RecordScreen() {
        this.Recording := false

        if (this.Recording || this.Playing)
            return
        this.UpdateSettings()
        this.LogArr := []
        this.oldid := ""
        this.Log()
        this.Recording := true
        this.SetHotkey(1)
        CoordMode("Mouse", "Screen")
        MouseGetPos(&RelativeX, &RelativeY)
        this.ShowTip("Recording")
        return
    }

    static UpdateSettings() {
        if (FileExist(this.LogFile)) {
            this.LogFileObject := FileOpen(this.LogFile, "r")

            Loop 3 {
                this.LogFileObject.ReadLine()
            }
            this.MouseMode := RegExReplace(this.LogFileObject.ReadLine(), ".*=")

            this.LogFileObject.ReadLine()
            this.RecordSleep := RegExReplace(this.LogFileObject.ReadLine(), ".*=")

            this.LogFileObject.Close()
        } else {
            this.MouseMode := "screen"
            this.RecordSleep := "false"
        }

        if (this.MouseMode != "screen" && this.MouseMode != "window" && this.MouseMode != "relative")
            this.MouseMode := "screen"

        if (this.RecordSleep != "true" && this.RecordSleep != "false")
            this.RecordSleep := "false"
    }

    static Stop() {
        #SuspendExempt
        if (this.Recording) {
            if (this.LogArr.Length > 0) {
                this.UpdateSettings()

                s := ";Press " this.ActionKey " to play. Hold to record. Long hold to edit`n;#####SETTINGS#####`n;What is the preferred method of recording mouse coordinates (screen,window,relative)`n;MouseMode=" this.MouseMode "`n;Record sleep between input actions (true,false)`n;RecordSleep=" this.RecordSleep "`nLoop(1)`n{`n`nStartingValue := 0`ni := RegRead(`"HKEY_CURRENT_USER\SOFTWARE\`" A_ScriptName, `"i`", StartingValue)`nRegWrite(i + 1, `"REG_DWORD`", `"HKEY_CURRENT_USER\SOFTWARE\`" A_ScriptName, `"i`")`n`nSetKeyDelay(30)`nSendMode(`"Event`")`nSetTitleMatchMode(2)"

                if (this.MouseMode == "window") {
                    s .= "`n;CoordMode(`"Mouse`", `"Screen`")`nCoordMode(`"Mouse`", `"Window`")`n"
                } else {
                    s .= "`nCoordMode(`"Mouse`", `"Screen`")`n;CoordMode(`"Mouse`", `"Window`")`n"
                }

                For k, v in this.LogArr
                    s .= "`n" v "`n"
                s .= "`n`n}`nExitApp()`n`n" this.ActionKey "::ExitApp()`n"
                s := RegExReplace(s, "\R", "`n")
                if (FileExist(this.LogFile))
                    FileDelete(this.LogFile)
                FileAppend(s, this.LogFile, "UTF-16")
                s := ""
            }
            this.Recording := 0
            this.LogArr := []
            this.SetHotkey(0)
        }

        this.ShowTip()
        Suspend(false)
        Pause(false)
        isPaused := false
        return
    }

    static PlayKeyAction() {
        #SuspendExempt
        if (this.Recording || this.Playing)
            this.Stop()
        ahk := A_AhkPath
        if (!FileExist(ahk))
        {
            MsgBox("Can't Find " ahk " !", "Error", 4096)
            Exit()
        }

        if (A_IsCompiled) {
            Run(ahk " /script /restart `"" this.LogFile "`"")
        } else {
            Run(ahk " /restart `"" this.LogFile "`"")
        }
        return
    }

    static EditKeyAction() {
        #SuspendExempt
        this.Stop()
        SplitPath(this.LogFile, &LogFileName)
        try {
            RegDelete("HKEY_CURRENT_USER\SOFTWARE\" LogFileName, "i")
        } catch OSError as err {

        }
        Run("Notepad++.exe " . this.LogFile)
        return
    }

    ;============ Functions =============

    static SetHotkey(f := false) {
        f := f ? "On" : "Off"
        Loop 254
        {
            k := GetKeyName(vk := Format("vk{:X}", A_Index))
            if (!(k ~= "^(?i:|Control|Alt|Shift)$"))
                Hotkey("~*" vk, this.LogKey.Bind(this), f)
        }
        For i, k in StrSplit("NumpadEnter|Home|End|PgUp" . "|PgDn|Left|Right|Up|Down|Delete|Insert", "|")
        {
            sc := Format("sc{:03X}", GetKeySC(k))
            if (!(k ~= "^(?i:|Control|Alt|Shift)$"))
                Hotkey("~*" sc, this.LogKey.Bind(this), f)
        }

        if (f = "On") {
            SetTimer(this.LogWindow.Bind(this))
            this.LogWindow()
        } else
            SetTimer(this.LogWindow.Bind(this), 0)
    }

    static LogKey(HotkeyName) {
        Critical()
        k := GetKeyName(vksc := SubStr(A_ThisHotkey, 3))
        k := StrReplace(k, "Control", "Ctrl"), r := SubStr(k, 2)
        if (r ~= "^(?i:Alt|Ctrl|Shift|Win)$")
            this.LogKey_Control(k)
        else if (k ~= "^(?i:LButton|RButton|MButton)$")
            this.LogKey_Mouse(k)
        else {
            if (k = "NumpadLeft" || k = "NumpadRight") && !GetKeyState(k, "P")
                return
            k := StrLen(k) > 1 ? "{" k "}" : k ~= "\w" ? k : "{" vksc "}"
            this.Log(k, 1)
        }
    }

    static LogKey_Control(key) {
        k := InStr(key, "Win") ? key : SubStr(key, 2)
        this.Log("{" k " Down}", 1)
        Critical("Off")
        ErrorLevel := !KeyWait(key)
        Critical()
        this.Log("{" k " Up}", 1)
    }

    static LogKey_Mouse(key) {
        k := SubStr(key, 1, 1)

        ;screen
        CoordMode("Mouse", "Screen")
        MouseGetPos(&X, &Y, &id)
        this.Log((this.MouseMode == "window" || this.MouseMode == "relative" ? ";" : "") "MouseClick(`"" k "`", " X ", " Y ",,, `"D`") `;screen")

        ;window
        CoordMode("Mouse", "Window")
        MouseGetPos(&WindowX, &WindowY, &id)
        this.Log((this.MouseMode != "window" ? ";" : "") "MouseClick(`"" k "`", " WindowX ", " WindowY ",,, `"D`") `;window")

        ;relative
        CoordMode("Mouse", "Screen")
        MouseGetPos(&tempRelativeX, &tempRelativeY, &id)
        this.Log((this.MouseMode != "relative" ? ";" : "") "MouseClick(`"" k "`", " (tempRelativeX - this.RelativeX) ", " (tempRelativeY - this.RelativeY) ",,, `"D`", `"R`") `;relative")
        this.RelativeX := tempRelativeX
        this.RelativeY := tempRelativeY

        ;get dif
        CoordMode("Mouse", "Screen")
        MouseGetPos(&X1, &Y1)
        t1 := A_TickCount
        Critical("Off")
        ErrorLevel := !KeyWait(key)
        Critical()
        t2 := A_TickCount
        if (t2 - t1 <= 200)
            X2 := X1, Y2 := Y1
        else
            MouseGetPos(&X2, &Y2)

        ;log screen
        i := this.LogArr.Length - 2
        r := this.LogArr[i]
        if (InStr(r, ",,, `"D`")") && Abs(X2 - X1) + Abs(Y2 - Y1) < 5)
            this.LogArr[i] := SubStr(r, 1, -16) ") `;screen", this.Log()
        else
            this.Log((this.MouseMode == "window" || this.MouseMode == "relative" ? ";" : "") "MouseClick(`"" k "`", " (X + X2 - X1) ", " (Y + Y2 - Y1) ",,, `"U`") `;screen")

        ;log window
        i := this.LogArr.Length - 1
        r := this.LogArr[i]
        if (InStr(r, ",,, `"D`")") && Abs(X2 - X1) + Abs(Y2 - Y1) < 5)
            this.LogArr[i] := SubStr(r, 1, -16) ") `;window", this.Log()
        else
            this.Log((this.MouseMode != "window" ? ";" : "") "MouseClick(`"" k "`", " (WindowX + X2 - X1) ", " (WindowY + Y2 - Y1) ",,, `"U`") `;window")

        ;log relative
        i := this.LogArr.Length
        r := this.LogArr[i]
        if (InStr(r, ",,, `"D`", `"R`")") && Abs(X2 - X1) + Abs(Y2 - Y1) < 5)
            this.LogArr[i] := SubStr(r, 1, -23) ",,,, `"R`") `;relative", this.Log()
        else
            this.Log((this.MouseMode != "relative" ? ";" : "") "MouseClick(`"" k "`", " (X2 - X1) ", " (Y2 - Y1) ",,, `"U`", `"R`") `;relative")
    }

    static LogWindow() {
        this.id := WinExist("A")
        this.title := WinGetTitle()
        _class := WinGetClass()
        if (this.title = "" && _class = "")
            return
        if (this.id = this.oldid && this.title = this.oldtitle)
            return
        this.oldid := this.id
        this.oldtitle := this.title
        this.title := SubStr(this.title, 1, 50)
        this.title .= _class ? " ahk_class " _class : ""
        this.title := RegExReplace(Trim(this.title), "[``%;]", "``$0")
        static CommentString := ""
        if (this.MouseMode != "window")
            this.CommentString := ";"
        s := this.CommentString . "tt := `"" this.title "`"`n" . this.CommentString . "WinWait(tt)" . "`n" . this.CommentString . "if (!WinActive(tt))`n" . this.CommentString . "  WinActivate(tt)"
        i := this.LogArr.Length
        r := i = 0 ? "" : this.LogArr[i]
        if (InStr(r, "tt = ") = 1)
            this.LogArr[i] := s, this.Log()
        else
            this.Log(s)
    }

    static Log(str := "", Keyboard := false) {
        LastTime := 0
        t := A_TickCount
        Delay := (LastTime ? t - LastTime : 0)
        LastTime := t
        if (str = "")
            return
        i := this.LogArr.Length
        r := i = 0 ? "" : this.LogArr[i]
        if (Keyboard && InStr(r, "Send") && Delay < 1000) {
            this.LogArr[i] := SubStr(r, 1, -1) . str "`""
            return
        }

        if (Delay > 200)
            this.LogArr.Push((this.RecordSleep == "false" ? ";" : "") "Sleep(" (Delay // 2) ")")
        this.LogArr.Push(Keyboard ? "Send `"{Blind}" str "`"" : str)
    }

}
