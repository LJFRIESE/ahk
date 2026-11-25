#Requires AutoHotkey v2.0
#Warn

; Standalone regression check for the leader rollover race.
;
; It uses F23 instead of F24 so it can run while master.ahk is active.
; SlowMenuEngine delays Render() after the tooltip is built, making the
; ordering between StartInput() and Render() deterministically observable:
; a `b` sent during that delay must still reach the InputHook and fire the
; action while F23 is physically held.

global gActionMenuDepth := 0
global RolloverCount := 0
global RolloverLog := A_ScriptDir "\leader-rollover-test.log"

#Include ..\Imports\MenuEngine.ahk

class SlowMenuEngine extends MenuEngine {
    static RenderDelay := 400

    static Render() {
        super.Render()
        Sleep this.RenderDelay
    }
}

RecordRollover() {
    global RolloverCount
    RolloverCount += 1
}

global RolloverNode := {
    label: "Rollover",
    entries: [
        { key: "b", label: "Record rollover", action: RecordRollover }
    ]
}

F23:: {
    SlowMenuEngine.Open(RolloverNode, {
        id: "RolloverTest",
        timeout: 3,
        exitKeys: "{Esc}{vk86}",
        footer: "Backspace: back · F23/Esc: exit"
    })
}

RunRolloverTest() {
    global RolloverCount, RolloverLog

    if FileExist(RolloverLog)
        FileDelete(RolloverLog)

    SendEvent("{F23 down}")
    Sleep 80            ; let the hotkey reach the delayed Render()
    SendEvent("{b}")    ; b arrives while F23 is still held
    Sleep 500           ; let the delayed Render() finish
    SendEvent("{F23 up}")
    Sleep 100

    passed := (RolloverCount = 1 && !SlowMenuEngine.Active)
    result := passed ? "PASS" : "FAIL"
    detail := "RolloverCount=" RolloverCount " Active=" SlowMenuEngine.Active
    FileAppend(result "  " detail "`n", RolloverLog)
    ToolTip("Leader rollover: " result " (" detail ")")
    SetTimer(() => ExitApp(), -1500)
}

SetTimer(RunRolloverTest, -300)
