CiscoConnectToggle() {

    SetTitleMatchMode 3
    SetControlDelay -1
    DetectHiddenWindows true
    mode := ControlGetText("Button1", "Cisco AnyConnect Secure Mobility Client")
    WinActivate("Cisco AnyConnect Secure Mobility Client")
    ; Connect or Disconnect?
    ControlClick("Button1","Cisco AnyConnect Secure Mobility Client",,,,"NA")
    if mode = "Connect" {
        if WinWaitActive("Cisco AnyConnect",,10) {
            ControlClick("Button1","Cisco AnyConnect",,,,"NA")
            msg := ScriptStatusGui("VPN Connected", "corner", 3000)
        } else {
            msg := ScriptStatusGui("VPN Connection timeout", "corner", 3000)
        }
    }
    if mode = "Disconnect" {
        msg := ScriptStatusGui("VPN Disconnected", "corner", 3000)
    }
}
