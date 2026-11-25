; Leader mode driven by the ZMK F24 key.
;
; One InputHook lives for the whole leader session. Text and non-text keys are
; swallowed until an action runs, F24 toggles off, Esc cancels, or 3s of idle
; time elapses. Menu nodes are data, so new options can be added without
; touching the input loop.

class Leader {
    static Timeout := 3
    static Active := false
    static ih := 0
    static TT := 0
    static TTText := 0
    static stack := []

    ; An entry is {key, label} plus either `action` (callable) or `children`
    ; (another node). Existing ActionMenu methods can be wrapped as actions:
    ;   {"key": "r", "label": "Reporting", "action": () => ActionMenu.Menu_Reporting()}
    static Root := {
        label: "Leader",
        entries: [
            {key: "b", label: "Previous window", action: ActivatePreviousWindow}
        ]
    }

    static Toggle() {
        if this.Active
            this.Close()
        else
            this.Open()
    }

    static Open() {
        global gActionMenuDepth
        if this.Active || gActionMenuDepth > 0
            return

        this.Active := true
        gActionMenuDepth += 1
        this.stack := [this.Root]
        this.ShowMenu()

        ; vk87 = F24. EndKeys are processed before suppression, so F24 and Esc
        ; still terminate the Input while every other key is swallowed.
        ih := InputHook("L0 T" . this.Timeout, "{Esc}{vk87}")
        ih.VisibleText := false
        ih.VisibleNonText := false
        ih.OnChar := ObjBindMethod(this, "OnChar")
        ih.OnEnd := ObjBindMethod(this, "OnEnd")
        ih.Start()
        this.ih := ih
    }

    static Close() {
        global gActionMenuDepth
        if !this.Active
            return

        ; Clear state before Stop(): Stop fires OnEnd, which must be a no-op.
        this.Active := false
        this.stack := []
        this.HideMenu()

        ih := this.ih
        this.ih := 0
        if IsObject(ih)
            ih.Stop()

        gActionMenuDepth -= 1
    }

    static OnChar(ih, char) {
        if !this.Active
            return

        ; Assigning Timeout while the Input is in progress restarts the window.
        ih.Timeout := this.Timeout

        node := this.stack[this.stack.Length]
        for entry in node.entries {
            if StrLower(entry.key) != StrLower(char)
                continue

            if entry.HasOwnProp("children") {
                this.stack.Push(entry.children)
                this.ShowMenu()
            } else {
                ; Leave leader before running the action: WinActivate and
                ; friends should not run under a live InputHook.
                this.Close()
                if entry.HasOwnProp("action")
                    entry.action.Call()
            }
            return
        }
        ; Unrecognised keys are swallowed; leader stays active.
    }

    static OnEnd(ih) {
        if !this.Active
            return
        if ih.EndReason = "Timeout" || ih.EndReason = "EndKey"
            this.Close()
    }

    static ShowMenu() {
        node := this.stack[this.stack.Length]
        text := node.label . "`n"
        for entry in node.entries
            text .= entry.key . ": " . entry.label . "`n"
        text .= "----------------`nF24/Esc: exit · " . this.Timeout . "s"

        if !IsObject(this.TT) {
            this.TT := Gui("+AlwaysOnTop -Caption +ToolWindow")
            this.TT.Name := "LeaderTooltip"
            this.TT.SetFont("s10", "Segoe UI")
            this.TT.BackColor := "F0F0F0"
            this.TTText := this.TT.Add("Text", , "")
        }
        this.TTText.Value := text
        this.TT.Show("NoActivate AutoSize")
    }

    static HideMenu() {
        if IsObject(this.TT)
            this.TT.Hide()
    }
}
