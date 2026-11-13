class RemoteWork {
	static vpnConnected := 0

	static vpnName  := "Cisco Secure Client"
	; The connect/disconnect dialog is a #32770 window. The Preferences window
	; (class CSCUI) has the same title and its own Button1, so always qualify it.
	static dialog   := "Cisco Secure Client ahk_class #32770"
	static uiExe    := "csc_ui.exe"
	static uiPath   := "C://Program Files (x86)/Cisco/Cisco Secure Client/UI/csc_ui.exe"
	static cliPath  := "C://Program Files (x86)/Cisco/Cisco Secure Client/vpncli.exe"

	; A hung client UI ignores ControlClick and blocks a fresh launch, so kill it
	; (and any stale duplicates) before connecting or disconnecting. The VPN
	; agent/service is untouched, so the tunnel state itself is preserved.
	static killClientUI(timeout := 5000) {
		deadline := A_TickCount + timeout
		while (pid := ProcessExist(RemoteWork.uiExe)) {
			try ProcessClose(pid)
			if (A_TickCount > deadline)
				break
			Sleep(50)
		}
	}

	static notify(message) {
		ToolTip(message)
		SetTimer () => ToolTip(), -3000
	}

	; Kill a stale UI, start a fresh one and make its dialog visible. csc_ui
	; usually starts with the dialog hidden; launching it again asks the running
	; instance to show the window (the same thing the Start menu icon does).
	static openDialog() {
		RemoteWork.killClientUI()
		Run(RemoteWork.uiPath)
		if (hwnd := RemoteWork.awaitDialog(3))
			return hwnd
		Run(RemoteWork.uiPath)
		if (hwnd := RemoteWork.awaitDialog(8))
			return hwnd
		; Last resort: the window exists but refuses to show itself.
		DetectHiddenWindows(true)
		hwnd := WinExist(RemoteWork.dialog)
		DetectHiddenWindows(false)
		if hwnd
			WinShow("ahk_id " hwnd)
		return hwnd
	}

	; Wait for the visible dialog. Callers keep DetectHiddenWindows off (the
	; master script's default), so a hidden dialog is not picked up here.
	static awaitDialog(timeout) {
		end := A_TickCount + timeout * 1000
		Loop {
			if (hwnd := WinExist(RemoteWork.dialog))
				return hwnd
			if (A_TickCount > end)
				return 0
			Sleep(100)
		}
	}

	static toggleVPN() {
		SetTitleMatchMode 3
		if !(dlg := RemoteWork.openDialog()) {
			RemoteWork.notify("VPN window not found")
			return
		}
		try WinActivate("ahk_id " dlg)
		; Let a freshly surfaced dialog refresh its label before reading it.
		Sleep(250)

		; The button reflects the real tunnel state, so trust its label instead
		; of a flag that resets whenever this script reloads.
		button := ControlGetText("Button1", "ahk_id " dlg)
		ControlClick("Button1", "ahk_id " dlg, , , , "NA")

		if (button = "Disconnect") {
			RemoteWork.vpnConnected := 0
			return
		}

		; Connecting may raise a banner/certificate prompt with an Accept button.
		if (prompt := WinWaitActive(RemoteWork.vpnName, "Accept", 10))
			ControlClick("Button1", "ahk_id " prompt, , , , "NA")
		RemoteWork.vpnConnected := 1
	}
}
