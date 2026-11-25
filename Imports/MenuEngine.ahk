; Shared input engine for menu trees (F24 leader and the action menu).
;
; A session owns one node stack and a single InputHook at a time. Text and
; non-text keys are swallowed until an action runs or an exit key is pressed.
; Unknown keys keep the menu open; Backspace walks up one level.

class MenuEngine {
    static Active := false
    static Id := ""
    static ih := 0
    static stack := []
    static opts := {}
    static TT := 0

    static Open(node, opts := 0) {
        global gActionMenuDepth
        if this.Active || gActionMenuDepth > 0
            return
        if !IsObject(opts)
            opts := {}

        this.opts := {
            id: opts.HasOwnProp("id") ? opts.id : "Menu",
            timeout: opts.HasOwnProp("timeout") ? opts.timeout : 0,
            exitKeys: opts.HasOwnProp("exitKeys") ? opts.exitKeys : "{Esc}",
            backKey: opts.HasOwnProp("backKey") ? opts.backKey : "{Backspace}",
            backName: opts.HasOwnProp("backName") ? opts.backName : "Backspace",
            footer: opts.HasOwnProp("footer") ? opts.footer : "Backspace: back · Esc: exit"
        }

        this.Active := true
        this.Id := this.opts.id
        gActionMenuDepth += 1
        this.stack := [node]

        ; Start listening before building the tooltip. A key pressed while F24
        ; is still held can arrive during Gui creation; with the old ordering
        ; that character had no InputHook to receive it.
        this.StartInput()
        this.Render()
    }

    static Close() {
        global gActionMenuDepth
        if !this.Active
            return

        ; Clear state before Stop(): Stop fires OnEnd, which must be a no-op.
        this.Active := false
        this.Id := ""
        this.stack := []
        this.StopInput()
        this.HideTooltip()
        gActionMenuDepth -= 1
    }

    static StartInput() {
        options := "L0"
        if this.opts.timeout > 0
            options .= " T" . this.opts.timeout

        ih := InputHook(options, this.opts.exitKeys . this.opts.backKey)
        ih.VisibleText := false
        ih.VisibleNonText := false
        ih.OnChar := ObjBindMethod(this, "OnChar")
        ih.OnEnd := ObjBindMethod(this, "OnEnd")

        ; Store the hook before Start(): a rolled-over key can fire OnChar
        ; immediately, and Close() needs this.ih in order to stop the hook.
        this.ih := ih
        ih.Start()
    }

    static StopInput() {
        ih := this.ih
        this.ih := 0
        if IsObject(ih)
            ih.Stop()
    }

    static OnChar(ih, char) {
        if !this.Active
            return

        ; Assigning Timeout while the Input is in progress restarts the window.
        if this.opts.timeout > 0
            ih.Timeout := this.opts.timeout

        node := this.stack[this.stack.Length]
        for entry in node.entries {
            if !entry.HasOwnProp("key")
                continue
            if StrLower(entry.key) != StrLower(char)
                continue

            if entry.HasOwnProp("children") {
                this.stack.Push(this.Resolve(entry.children))
                this.Render()
            } else {
                ; Leave the menu before running the action.
                this.Close()
                if entry.HasOwnProp("action")
                    entry.action.Call()
            }
            return
        }
        ; Unrecognised keys are swallowed; the menu stays open.
    }

    static Resolve(target) {
        return IsObject(target) ? target : target.Call()
    }

    static OnEnd(ih) {
        if !this.Active
            return

        if ih.EndReason = "Timeout" {
            this.Close()
            return
        }
        if ih.EndReason != "EndKey"
            return

        if ih.EndKey = this.opts.backName {
            if this.stack.Length > 1
                this.stack.Pop()
            this.Render()
            this.StopInput()
            this.StartInput()
            return
        }
        this.Close()
    }

    static Render() {
        stack := this.stack
        breadcrumb := ""
        for node in stack
            breadcrumb .= (breadcrumb ? " > " : "") . node.label

        text := breadcrumb . "`n"
        node := stack[stack.Length]
        for entry in node.entries {
            if !entry.HasOwnProp("key") {
                text .= entry.label . "`n"
                continue
            }
            text .= entry.key . ": " . entry.label . "`n"
        }
        text .= "----------------`n" . this.opts.footer
        if this.opts.timeout > 0
            text .= " · " . this.opts.timeout . "s"

        ; AutoSize fits the window to its controls, and a Text control keeps the
        ; size it was created with. Rebuild the Gui from the current text.
        this.HideTooltip()
        this.TT := Gui("+AlwaysOnTop -Caption +ToolWindow")
        this.TT.Name := "MenuTooltip"
        this.TT.SetFont("s10", "Segoe UI")
        this.TT.BackColor := "F0F0F0"
        this.TT.Add("Text", , text)
        this.TT.Show("NoActivate AutoSize")
    }

    static HideTooltip() {
        if IsObject(this.TT) {
            this.TT.Destroy()
            this.TT := 0
        }
    }
}
