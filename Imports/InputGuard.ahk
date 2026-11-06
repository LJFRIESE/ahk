; Guard against modifier keys that get left logically down ("stuck") by a hotkey
; or by an interrupted/failed Send. If Ctrl, Shift, Alt or Win stays down while
; its physical key is up for longer than a short grace period, it is released
; and the event is written to a log so the trigger can be identified.
;
; Start() installs the keyboard hook if needed, because GetKeyState(..., "P")
; only reports the true physical state while the hook is installed.

class InputGuard {
    static Interval := 150          ; ms between checks
    static Threshold := 5           ; consecutive mismatches before releasing (~750 ms)
    static Notify := true           ; show a short tooltip when a key is released
    static LogPath := A_AppData "\ahk\input-guard.log"

    static Keys := ["Ctrl", "Shift", "Alt", "LWin", "RWin"]

    static Releases := Map(
        "Ctrl",  "{Ctrl up}{LCtrl up}{RCtrl up}",
        "Shift", "{Shift up}{LShift up}{RShift up}",
        "Alt",   "{Alt up}{LAlt up}{RAlt up}",
        "LWin",  "{LWin up}",
        "RWin",  "{RWin up}")

    static _state := Map()
    static _timer := 0
    static _lastError := ""

    static Start() {
        InstallKeybdHook()
        if this._timer
            return
        this._timer := ObjBindMethod(this, "Check")
        SetTimer(this._timer, this.Interval)
    }

    static Stop() {
        if this._timer {
            SetTimer(this._timer, 0)
            this._timer := 0
        }
    }

    static Check() {
        try {
            for name in this.Keys {
                st := this._state.Has(name)
                    ? this._state[name]
                    : (this._state[name] := {count: 0, since: 0, logged: false})

                ; AltGr is reported as Ctrl down while neither Ctrl key is
                ; physically down. Ignore it so AltGr keeps working.
                if (name = "Ctrl" && GetKeyState("RAlt", "P")) {
                    this.Clear(st)
                    continue
                }

                physical := GetKeyState(name, "P")
                logical := GetKeyState(name)

                ; Normal: physically held, or logically up. Nothing stuck.
                if physical || !logical {
                    if st.logged
                        this.Log("cleared", name, A_TickCount - st.since)
                    this.Clear(st)
                    continue
                }

                if !st.count
                    st.since := A_TickCount
                st.count += 1

                if !st.logged {
                    st.logged := true
                    this.Log("detected", name, 0)
                }

                if st.count >= this.Threshold {
                    elapsed := A_TickCount - st.since
                    SendInput("{Blind}" this.Releases[name])
                    this.Log("released", name, elapsed)
                    if this.Notify {
                        ToolTip("Released stuck " name)
                        SetTimer(() => ToolTip(), -2000)
                    }
                    this.Clear(st)
                }
            }
        } catch Error as e {
            ; Never let a guard error pop a dialog or kill the timer.
            if (e.Message != this._lastError) {
                this._lastError := e.Message
                this.Log("error", e.Message, 0)
            }
        }
    }

    static Clear(st) {
        st.count := 0
        st.since := 0
        st.logged := false
    }

    static Log(kind, name, elapsed) {
        try {
            SplitPath(this.LogPath, , &dir)
            if (dir && !DirExist(dir))
                DirCreate(dir)
            if (FileExist(this.LogPath) && FileGetSize(this.LogPath) > 1048576)
                FileMove(this.LogPath, this.LogPath ".old", true)

            line := FormatTime(, "yyyy-MM-dd HH:mm:ss") "." Format("{:03}", A_MSec)
            line .= "  " kind "  " name
            if (kind = "released" || kind = "cleared")
                line .= " after " elapsed " ms"

            try line .= "  win=" WinGetProcessName("A")
            try line .= "  title=" WinGetTitle("A")
            try line .= "  class=" WinGetClass("A")
            if A_PriorKey != ""
                line .= "  priorKey=" A_PriorKey
            if A_PriorHotkey != ""
                line .= "  priorHotkey=" A_PriorHotkey

            FileAppend(line "`n", this.LogPath)
        }
    }
}
