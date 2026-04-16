class RemoteWork {
	static vpnConnected := 0

	static toggleVPN() {
		SetTitleMatchMode 3
		vpn_name := "Cisco Secure Client"
	
		Run("C://Program Files (x86)/Cisco/Cisco Secure Client/UI/csc_ui.exe", , "Hide")

		; Connect or Disconnect? 
		if RemoteWork.vpnConnected = 0 {
			sleep 500
			ControlClick("Button1",vpn_name,,,,"NA")
			if WinWaitActive(vpn_name,"Accept",10) {
				ControlClick("Button1",vpn_name,,,,"NA")
				RemoteWork.vpnConnected := 1
			}
		} else {
			Run("C://Program Files (x86)/Cisco/Cisco Secure Client/vpncli.exe disconnect", , "Hide")
			RemoteWork.vpnConnected := 0

		}
	}
}
