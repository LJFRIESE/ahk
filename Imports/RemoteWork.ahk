class RemoteWork {
	static amCheckedIn := false
	static checkIn() {
		Run("go run . -action Check-in", "C:\Users\LUCASFRI\git\go")
		this.amCheckedIn := true
	}
	
	static checkOut() {
		Run("go run . -action Check-out", "C:\Users\LUCASFRI\git\go")
		this.amCheckedIn := false
	}
	
	static toggleAware360() {
		if this.amCheckedIn {
			this.checkOut()
		} else {
			this.checkIn()
		}
	}

	static toggleVPN() {
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
				msg := ScriptStatusGui("VPN Connected - Check-in to Aware360?", "corner")
			} else {
				msg := ScriptStatusGui("VPN Connection timeout", "corner")
			}
		}
		if mode = "Disconnect" {
			;Sleep 5000
			WinWaitNotActive("Cisco AnyConnect Secure Mobility Client")
			WinKill("Cisco AnyConnect Secure Mobility Client") 
			msg := ScriptStatusGui("VPN Disconnected - Check-out from Aware360?", "corner")
		}
		SetTimer(() => msg.Destroy(), -2000)
	}
}

