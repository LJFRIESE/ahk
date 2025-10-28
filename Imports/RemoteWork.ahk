class RemoteWork {
	static amCheckedIn := false
	static checkIn() {
		Run("go run . -action Check-in", "C:\Users\LUCASFRI\git\go", "")
	}
	
	static checkOut() {
		Run("go run . -action Check-out", "C:\Users\LUCASFRI\git\go", "")
	}
	
	static toggleAware360() {
		if this.amCheckedIn {
			this.checkOut()
			this.amCheckedIn := false
		} else {  
			this.checkIn()	
			this.amCheckedIn := true
		}
		msg := ScriptStatusGui("Aware360 toggle complete", "corner")
		SetTimer(() => msg.Destroy(), -2000)
	}
	
	static vpnConnected := 0

	static toggleVPN() {
		SetTitleMatchMode 3
		vpn_name := "Cisco Secure Client"
	
		Run("C://Program Files (x86)/Cisco/Cisco Secure Client/UI/csc_ui.exe", , "Hide")

		; Connect or Disconnect? 
		if RemoteWork.vpnConnected = 0 {
			sleep 100
			ControlClick("Button1",vpn_name,,,,"NA")
			if WinWaitActive(vpn_name,"Accept",10) {
				ControlClick("Button1",vpn_name,,,,"NA")
				RemoteWork.vpnConnected := 1
				msg := ScriptStatusGui("VPN Connected - Check-in to Aware360?", "corner")
			} else {
				msg := ScriptStatusGui("VPN Connection timeout", "corner")
			}
		} else {
			Run("C://Program Files (x86)/Cisco/Cisco Secure Client/vpncli.exe disconnect", , "Hide")
			msg := ScriptStatusGui("VPN Disconnected - Check-out from Aware360?", "corner")
			RemoteWork.vpnConnected := 0

		}
		SetTimer(() => msg.Destroy(), -2000)
	}
}

 