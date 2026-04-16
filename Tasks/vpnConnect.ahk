#SingleInstance
#Requires AutoHotkey v2.0
SetTitleMatchMode 3

vpn_name := "Cisco Secure Client"

Run("C://Program Files (x86)/Cisco/Cisco Secure Client/UI/csc_ui.exe", , "Hide")

sleep 100
ControlClick("Button1",vpn_name,,,,"NA")
if WinWaitActive(vpn_name,"Accept",10) {
	ControlClick("Button1",vpn_name,,,,"NA")
}

Exit