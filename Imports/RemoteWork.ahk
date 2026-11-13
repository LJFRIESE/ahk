class RemoteWork {
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

	; Find a "Cisco Secure Client" dialog that actually owns Button1. The client
	; creates transient windows with the same title and class, so skip any that
	; have no button. Prefer a visible one; fall back to a hidden one, because
	; the client minimizes itself once the tunnel is up. Requires
	; DetectHiddenWindows to be on.
	static findDialog() {
		hidden := 0
		for win in WinGetList(RemoteWork.dialog) {
			try {
				if (ControlGetText("Button1", "ahk_id " win) = "")
					continue
			} catch {
				continue
			}
			if DllCall("IsWindowVisible", "ptr", win)
				return win
			if !hidden
				hidden := win
		}
		return hidden
	}

	; Read Button1 and click it, waiting for a usable dialog to exist. The client
	; hides the dialog as soon as the tunnel is up, so the window may be invisible
	; by the time we get here, and it can be replaced while the state changes.
	; With onlyIf set, the click happens only when the label matches it.
	; Returns the label that was read (clicked or not), or "" on timeout.
	static clickDialogButton(onlyIf := "", timeout := 6000) {
		end := A_TickCount + timeout * 1000
		DetectHiddenWindows(true)
		try {
			Loop {
				if (hwnd := RemoteWork.findDialog()) {
					label := ControlGetText("Button1", "ahk_id " hwnd)
					if (onlyIf = "" || label = onlyIf)
						ControlClick("Button1", "ahk_id " hwnd, , , , "NA")
					return label
				}
				if (A_TickCount > end)
					return ""
				Sleep(100)
			}
		} catch {
			return ""
		} finally {
			DetectHiddenWindows(false)
		}
	}

	static toggleVPN() {
		SetTitleMatchMode 3
		if !(dlg := RemoteWork.openDialog()) {
			RemoteWork.notify("VPN window not found")
			return
		}
		try WinActivate("ahk_id " dlg)

		; The button reflects the real tunnel state, so trust its label instead
		; of a flag that resets whenever this script reloads.
		button := RemoteWork.clickDialogButton()
		if (button = "") {
			RemoteWork.notify("VPN window not found")
			return
		}
		if (button = "Disconnect")
			return

		; Connecting may raise a banner/certificate prompt with an Accept button.
		if (prompt := WinWaitActive(RemoteWork.vpnName, "Accept", 10))
			ControlClick("Button1", "ahk_id " prompt, , , , "NA")
	}
}
