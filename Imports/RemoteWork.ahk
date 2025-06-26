class RemoteWork {
	static amCheckedIn := false
	static checkIn() {
		Run("go run . -action Check-in", "C:\Users\LUCASFRI\git\go", "hide")
		this.amCheckedIn := true
	}
	
	static checkOut() {
		Run("go run . -action Check-out", "C:\Users\LUCASFRI\git\go", "hide")
		this.amCheckedIn := false
	}
	
	static toggleAware360() {
		if this.amCheckedIn {
			this.checkOut()
		} else {
			this.checkIn()
		}
		msg := ScriptStatusGui("Aware360 toggle complete", "corner")
		SetTimer(() => msg.Destroy(), -2000)
	}

	static toggleVPN() {
		SetTitleMatchMode 3
		SetControlDelay -1
		DetectHiddenWindows true
		vpn_name := "Cisco Secure Client"
		mode := ControlGetText("Button1", vpn_name)
		WinActivate(vpn_name)
		; Connect or Disconnect?
		ControlClick("Button1",vpn_name,,,,"NA")
		if mode = "Connect" {
			if WinWaitActive(vpn_name,"Accept",10) {
				ControlClick("Button1",vpn_name,,,,"NA")
				msg := ScriptStatusGui("VPN Connected - Check-in to Aware360?", "corner")
			} else {
				msg := ScriptStatusGui("VPN Connection timeout", "corner")
			}
		}
		if mode = "Disconnect" {
			;Sleep 5000
			WinWaitNotActive(vpn_name)
			WinKill(vpn_name) 
			msg := ScriptStatusGui("VPN Disconnected - Check-out from Aware360?", "corner")
		}
		SetTimer(() => msg.Destroy(), -2000)
	}
}

 